from typing import List, Optional
import os
import uuid

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session

from .. import schemas, models
from ..dependencies import get_current_user, require_brand
from ..db import get_session

router = APIRouter(prefix="/photos", tags=["photos"])

BASE_URL = os.getenv('BASE_URL', 'http://localhost:8000')


@router.post("/", response_model=schemas.BrandPhotoRead)
def upload_photo(
    brand_id: int = Form(...),
    product_id: Optional[int] = Form(None),
    file: UploadFile = File(...),
    current_user: models.User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    # only brand accounts may upload
    require_brand(current_user)

    # save file to uploads/ and build accessible URL
    filename = f"{uuid.uuid4().hex}_{file.filename}"
    upload_dir = os.path.abspath(os.path.join(os.getcwd(), 'uploads'))
    os.makedirs(upload_dir, exist_ok=True)
    save_path = os.path.join(upload_dir, filename)
    with open(save_path, 'wb') as f:
        content = file.file.read()
        f.write(content)

    image_url = f"{BASE_URL}/uploads/{filename}"

    photo = models.BrandPhoto(
        uploader_id=current_user.id,
        brand_id=brand_id,
        product_id=product_id,
        image_url=image_url,
    )
    session.add(photo)
    session.commit()
    session.refresh(photo)
    return photo


@router.get("/", response_model=List[schemas.BrandPhotoRead])
def list_photos(session: Session = Depends(get_session)):
    result = session.execute(models.BrandPhoto.__table__.select())
    photos = result.scalars().all()
    return photos
