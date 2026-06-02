import logging
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from firebase_admin import messaging

from ..db import get_db
from .. import models
from ..auth import verify_firebase_token

router = APIRouter(prefix="", tags=["notifications"])
logger = logging.getLogger(__name__)

class FCMTokenRequest(BaseModel):
    fcm_token: str

class SendNotificationRequest(BaseModel):
    user_id: int
    title: str
    body: str
    data: dict | None = None

def send_push_notification(user_id: int, title: str, body: str, db: Session, data: dict = None):
    try:
        user = db.query(models.User).filter(models.User.id == user_id).first()
        if not user or not user.fcm_token:
            return False
            
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=user.fcm_token,
        )
        messaging.send(message)
        return True
    except Exception as e:
        logger.error(f"Internal failed to send push: {e}")
        return False

@router.post("/users/fcm-token")
def update_fcm_token(
    payload: FCMTokenRequest,
    db: Session = Depends(get_db),
    auth_token: dict = Depends(verify_firebase_token)
):
    uid = auth_token.get("uid")
    if not uid:
        raise HTTPException(status_code=401, detail="Unauthorized")
        
    user = db.query(models.User).filter(models.User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.fcm_token = payload.fcm_token
    db.commit()
    return {"message": "FCM token updated successfully"}

@router.post("/notifications/send")
def send_notification(
    payload: SendNotificationRequest,
    db: Session = Depends(get_db),
    auth_token: dict = Depends(verify_firebase_token)
):
    role = auth_token.get("role") or ""
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admins only")
        
    user = db.query(models.User).filter(models.User.id == payload.user_id).first()
    if not user or not user.fcm_token:
        raise HTTPException(status_code=404, detail="User or FCM token not found")
        
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=payload.title,
                body=payload.body,
            ),
            data=payload.data or {},
            token=user.fcm_token,
        )
        response = messaging.send(message)
        return {"message": "Notification sent", "message_id": response}
    except Exception as e:
        logger.error(f"Failed to send notification: {e}")
        raise HTTPException(status_code=500, detail="Failed to send push notification")
