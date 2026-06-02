from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from .. import models
from ..db import get_db
from ..auth import verify_firebase_token

router = APIRouter(prefix="/inventory", tags=["inventory"])


class ReserveItem(BaseModel):
    sku_id: str
    quantity: int = Field(gt=0)


class ReserveRequest(BaseModel):
    user_id: int
    items: list[ReserveItem]


@router.get("/sku/{sku_id}")
def get_sku_stock(
    sku_id: str, 
    db: Session = Depends(get_db),
    auth_token: dict = Depends(verify_firebase_token)
) -> dict:
    inv = db.execute(
        select(models.Inventory).where(models.Inventory.sku_id == sku_id)
    ).scalar_one_or_none()
    if not inv:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="SKU not found")
    return {
        "skuId": sku_id,
        "stockAvailable": inv.stock_available,
        "stockReserved": inv.stock_reserved,
        "stockSold": inv.stock_sold,
    }


@router.post("/reserve")
def reserve_stock(
    payload: ReserveRequest, 
    db: Session = Depends(get_db),
    auth_token: dict = Depends(verify_firebase_token)
) -> dict:
    """
    Reserve stock atomically for a checkout flow.
    This is a simplified version using a single transaction and row locking.
    """
    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No items to reserve")

    for item in payload.items:
        inv = (
            db.execute(
                select(models.Inventory)
                .where(models.Inventory.sku_id == item.sku_id)
                .with_for_update()
            ).scalar_one_or_none()
        )
        if not inv:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"SKU {item.sku_id} not found",
            )
        if inv.stock_available < item.quantity:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Insufficient stock for {item.sku_id}",
            )
        inv.stock_available -= item.quantity
        inv.stock_reserved += item.quantity

    return {"status": "reserved"}

