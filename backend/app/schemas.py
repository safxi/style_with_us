from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class OrderItemIn(BaseModel):
    product_id: int
    sku_id: str
    quantity: int = Field(gt=0)
    unit_price: float


class CreateOrderRequest(BaseModel):
    user_id: int
    items: List[OrderItemIn]
    currency: str = "USD"
    payment_gateway: str = "stripe"
    target_occasion: Optional[str] = None


class CreateOrderResponse(BaseModel):
    order_id: int
    amount_total: float
    currency: str
    payment_gateway: str
    stripe_client_secret: Optional[str] = None
    razorpay_order_id: Optional[str] = None


class ConfirmOrderRequest(BaseModel):
    order_id: int
    payment_status: str
    gateway_reference: Optional[str] = None


class AnalyzeRequest(BaseModel):
    user_id: int
    image_url: str


class AnalyzeResponse(BaseModel):
    analysis_id: str
    body_type: str
    body_confidence: float
    skin_tone: str
    skin_confidence: float
    created_at: datetime


class ProductRecommendation(BaseModel):
    product_id: int
    brand_id: int
    score: float
    scores: dict
    explanation: str
    rank: int


class BrandRecommendation(BaseModel):
    brand_id: int
    brand_score: float


class RecommendRequest(BaseModel):
    user_id: int
    analysis_id: Optional[str] = None
    target_occasion: Optional[str] = None
    limit: int = 20


class RecommendResponse(BaseModel):
    recommendation_id: str
    products: List[ProductRecommendation]
    top_brands: List[BrandRecommendation]


class VirtualTryOnRequest(BaseModel):
    user_id: int
    product_id: int
    image_url: str


class VirtualTryOnResponse(BaseModel):
    session_id: str
    product_id: int
    result_image_url: str
    explanation: str
    created_at: datetime


# --- new schemas for brand-uploaded images ---
class BrandPhotoCreate(BaseModel):
    brand_id: int
    product_id: Optional[int] = None
    image_url: str


class BrandPhotoRead(BrandPhotoCreate):
    id: int
    uploader_id: int
    created_at: datetime


# ---- new schemas for brand/product browsing ----
class BrandRead(BaseModel):
    id: int
    name: str
    logo_url: Optional[str] = None
    banner_url: Optional[str] = None
    description: Optional[str] = None


class ProductRead(BaseModel):
    id: int
    brand_id: int
    name: str
    main_image_url: Optional[str] = None
    price: float
    currency: str


class OrderItemRead(BaseModel):
    sku_id: str
    quantity: int
    price: float


class OrderRead(BaseModel):
    id: int
    amount_total: float
    currency: str
    status: str
    created_at: datetime
    items: List[OrderItemRead] = []


class AsyncJobResponse(BaseModel):
    job_id: str
    status: str


