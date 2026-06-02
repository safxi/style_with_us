import stripe
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from ..auth import verify_firebase_token

from .. import models
from ..core.config import settings
from ..db import get_db
from ..schemas import CreateOrderRequest, CreateOrderResponse, ConfirmOrderRequest
from .notifications import send_push_notification

router = APIRouter(prefix="/orders", tags=["orders"])


@router.post("/create", response_model=CreateOrderResponse)
def create_order(
    payload: CreateOrderRequest, 
    db: Session = Depends(get_db),
    auth_token: dict = Depends(verify_firebase_token)
) -> CreateOrderResponse:
    """
    Create an order and initialize payment with Stripe or Razorpay.
    This is intentionally simplified: real implementation would integrate stripe.PaymentIntent.create etc.
    """
    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No items in order")

    amount_subtotal = sum(item.unit_price * item.quantity for item in payload.items)
    amount_shipping = 0.0
    amount_total = amount_subtotal + amount_shipping

    order = models.Order(
        user_id=payload.user_id,
        amount_subtotal=amount_subtotal,
        amount_shipping=amount_shipping,
        amount_total=amount_total,
        currency=payload.currency,
        status=models.OrderStatusEnum.PENDING_PAYMENT.value,
        payment_gateway=payload.payment_gateway,
    )
    db.add(order)
    db.flush()

    stripe_client_secret = None
    razorpay_order_id = None

    if payload.payment_gateway == "stripe":
        stripe.api_key = settings.stripe_api_key
        try:
            intent = stripe.PaymentIntent.create(
                amount=int(amount_total * 100),  # Cents
                currency=payload.currency.lower(),
                metadata={"order_id": str(order.id)}
            )
            stripe_client_secret = intent.client_secret
            order.payment_intent_id = intent.id
            
            order.metadata_json = order.metadata_json or {}
            order.metadata_json["stripe_payment_intent_id"] = intent.id
            db.commit()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Stripe error: {e}")
    elif payload.payment_gateway == "razorpay":
        # TODO: integrate razorpay client.order.create and save razorpay order id.
        razorpay_order_id = f"rzp_mock_order_{order.id}"
        db.commit()
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported gateway")

    return CreateOrderResponse(
        order_id=order.id,
        amount_total=amount_total,
        currency=payload.currency,
        payment_gateway=payload.payment_gateway,
        stripe_client_secret=stripe_client_secret,
        razorpay_order_id=razorpay_order_id,
    )


@router.post("/confirm")
def confirm_order(payload: ConfirmOrderRequest, db: Session = Depends(get_db)) -> dict:
    """
    Optimistic confirmation from the client.
    The actual source of truth is the payment provider webhook.
    """
    order = db.get(models.Order, payload.order_id)
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

    # Do not fully trust client; only record tentative status.
    order.metadata_json = order.metadata_json or {}
    order.metadata_json["client_reported_status"] = payload.payment_status
    if payload.gateway_reference:
        order.metadata_json["client_gateway_reference"] = payload.gateway_reference

    normalized = payload.payment_status.strip().upper()
    if normalized in {"PAID", "SUCCEEDED", "SUCCESS"}:
        order.status = models.OrderStatusEnum.PAID.value
    elif normalized in {"FAILED", "FAILURE"}:
        order.status = models.OrderStatusEnum.FAILED.value

    db.add(order)
    db.commit()
    return {"status": "ok", "order_status": order.status}


@router.get("/history", response_model=dict)
def get_order_history(
    db: Session = Depends(get_db),
    auth_token: dict = Depends(verify_firebase_token)
):
    uid = auth_token.get("uid")
    user = db.query(models.User).filter(models.User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    orders = db.query(models.Order).filter(models.Order.user_id == user.id).order_by(models.Order.created_at.desc()).all()
    
    # In a real app, we would join with OrderItems. 
    # For now, return the basic order info.
    return {
        "orders": [
            {
                "id": o.id,
                "total_price": o.amount_total,
                "currency": o.currency,
                "status": o.status,
                "created_at": o.created_at,
                "items": [] # Simplified
            }
            for o in orders
        ]
    }


@router.post("/webhooks/stripe")
async def stripe_webhook(request: Request, db: Session = Depends(get_db)) -> dict:
    """
    Stripe webhook entrypoint.
    In a real implementation, verify the signature with stripe.Webhook.
    """
    payload = await request.body()
    sig_header = request.headers.get("Stripe-Signature")

    if not sig_header or not payload:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid webhook")

    stripe.api_key = settings.stripe_api_key
    try:
        event = stripe.Webhook.construct_event(
            payload=payload,
            sig_header=sig_header,
            secret=settings.stripe_webhook_secret,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid Stripe webhook signature: {e}",
        )

    event_type = event.get("type", "")
    data_object = event.get("data", {}).get("object", {}) or {}
    metadata = data_object.get("metadata", {}) or {}
    intent_id = data_object.get("id")

    order = None
    order_id = metadata.get("order_id")
    if order_id is not None:
        try:
            order = db.get(models.Order, int(order_id))
        except (TypeError, ValueError):
            order = None
    if order is None and intent_id:
        order = db.query(models.Order).filter(models.Order.payment_intent_id == intent_id).first()

    if order is None:
        return {"received": True}

    order.metadata_json = order.metadata_json or {}
    order.metadata_json["last_webhook_event"] = event_type

    if event_type == "payment_intent.succeeded":
        order.status = models.OrderStatusEnum.PAID.value
        send_push_notification(order.user_id, "Order Confirmed! 🎉", f"Your order #{order.id} has been paid successfully.", db)
    elif event_type == "payment_intent.payment_failed":
        order.status = models.OrderStatusEnum.FAILED.value
        error_info = data_object.get("last_payment_error", {}) or {}
        order.failure_reason = error_info.get("message")

    db.add(order)
    db.commit()
    return {"received": True}

