from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from . import models, db
from . import firebase

# initialize firebase admin when the module is imported
firebase.init_firebase()

# placeholder oauth2 scheme -- clients should send Firebase ID token here
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

def get_current_user(token: str = Depends(oauth2_scheme), session: Session = Depends(db.get_session)) -> models.User:
    """Verify a Firebase ID token and return a User from the SQL database.

    If we don't yet have a row for the Firebase UID we automatically create one
    using the email/name/role data contained in the token or default values.
    """
    try:
        decoded = firebase.verify_id_token(token)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Firebase token")

    uid = decoded.get("uid")
    if not uid:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token missing uid")

    # lookup user by firebase_uid in relational table
    user = session.query(models.User).filter(models.User.firebase_uid == uid).first()
    if not user:
        user = models.User(
            firebase_uid=uid,
            email=decoded.get("email"),
            name=decoded.get("name"),
            role=decoded.get("role", "user"),
        )
        session.add(user)
        session.commit()
        session.refresh(user)
    return user


def require_shopper(user: models.User = Depends(get_current_user)):
    if user.role.lower() not in ("user", "shopper"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Shopper access only")


def require_brand(user: models.User = Depends(get_current_user)):
    if user.role.lower() != "brand":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Brand access only")


def require_admin(user: models.User = Depends(get_current_user)):
    if user.role.lower() != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access only")
