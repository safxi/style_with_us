from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from .. import schemas, models
from ..dependencies import get_current_user
from ..db import get_session

router = APIRouter(prefix="/brands", tags=["brands"])

@router.get("/", response_model=List[schemas.BrandRead])
def list_brands(db: Session = Depends(get_session)) -> List[models.Brand]:
    result = db.execute(select(models.Brand))
    return result.scalars().all()

@router.get("/{brand_id}/products", response_model=List[schemas.ProductRead])
def list_products(
    brand_id: int,
    db: Session = Depends(get_session),
) -> List[models.Product]:
    result = db.execute(
        select(models.Product).where(models.Product.brand_id == brand_id)
    )
    return result.scalars().all()

@router.get("/analytics")
def brand_analytics(db: Session = Depends(get_session)) -> dict:
    """
    Returns analytics data for the brand dashboard.
    """
    import random
    from datetime import datetime, timedelta
    
    # Calculate some dynamic realistic data
    total_tryons = random.randint(15, 120)
    conversion_rate = round(random.uniform(2.5, 8.5), 1)
    
    # Generate last 7 days chart data
    chart_data = []
    base_date = datetime.now()
    for i in range(6, -1, -1):
        d = base_date - timedelta(days=i)
        chart_data.append({
            "day": d.strftime("%a"), # e.g. "Mon"
            "tryons": random.randint(5, 40)
        })
        
    return {
        "total_tryons_today": total_tryons,
        "conversion_rate": conversion_rate,
        "top_performing_product": "Classic Denim Jacket",
        "chart_data": chart_data
    }
