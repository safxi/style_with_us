from datetime import datetime

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    JSON,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship, Mapped, mapped_column
from enum import Enum as PyEnum

from .db import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    firebase_uid: Mapped[str | None] = mapped_column(String(128), unique=True, index=True, nullable=True)
    fcm_token: Mapped[str | None] = mapped_column(String(512))
    password_hash: Mapped[str | None] = mapped_column(String(255))
    name: Mapped[str | None] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(32), default="USER", index=True)
    brand_id: Mapped[int | None] = mapped_column(ForeignKey("brands.id"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime)


class Brand(Base):
    __tablename__ = "brands"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    logo_url: Mapped[str | None] = mapped_column(String(512))
    banner_url: Mapped[str | None] = mapped_column(String(512))
    description: Mapped[str | None] = mapped_column(String(1024))
    website_url: Mapped[str | None] = mapped_column(String(512))
    tier: Mapped[str] = mapped_column(String(32), default="free", index=True)


class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    brand_id: Mapped[int] = mapped_column(ForeignKey("brands.id"), index=True)
    name: Mapped[str] = mapped_column(String(255), index=True)
    slug: Mapped[str | None] = mapped_column(String(255), unique=True)
    description: Mapped[str | None] = mapped_column(String)
    main_image_url: Mapped[str | None] = mapped_column(String(512))
    price: Mapped[float] = mapped_column(Float)
    currency: Mapped[str] = mapped_column(String(8), default="USD")
    style_type: Mapped[str | None] = mapped_column(String(64), index=True)
    style_tags: Mapped[dict | None] = mapped_column(JSON)
    color_tone: Mapped[str | None] = mapped_column(String(32), index=True)
    color_tags: Mapped[dict | None] = mapped_column(JSON)
    occasion: Mapped[str | None] = mapped_column(String(64), index=True)
    season: Mapped[str | None] = mapped_column(String(32), index=True)
    gender: Mapped[str | None] = mapped_column(String(32), index=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    brand: Mapped[Brand] = relationship("Brand")


class Inventory(Base):
    __tablename__ = "inventory"
    __table_args__ = (UniqueConstraint("sku_id", "location_id", name="uq_inventory_sku_loc"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), index=True)
    sku_id: Mapped[str] = mapped_column(String(64), index=True)
    location_id: Mapped[str] = mapped_column(String(64), default="default", index=True)
    stock_available: Mapped[int] = mapped_column(Integer, default=0)
    stock_reserved: Mapped[int] = mapped_column(Integer, default=0)
    stock_sold: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class OrderStatusEnum(str, PyEnum):
    PENDING_PAYMENT = "PENDING_PAYMENT"
    PAID = "PAID"
    FAILED = "FAILED"
    REFUNDED = "REFUNDED"
    PARTIALLY_REFUNDED = "PARTIALLY_REFUNDED"
    CANCELLED = "CANCELLED"


class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    amount_subtotal: Mapped[float] = mapped_column(Float)
    amount_shipping: Mapped[float] = mapped_column(Float, default=0)
    amount_total: Mapped[float] = mapped_column(Float)
    currency: Mapped[str] = mapped_column(String(8), default="USD")
    status: Mapped[str] = mapped_column(String(32), default=OrderStatusEnum.PENDING_PAYMENT.value)
    payment_gateway: Mapped[str | None] = mapped_column(String(32))
    payment_intent_id: Mapped[str | None] = mapped_column(String(128), index=True)
    failure_reason: Mapped[str | None] = mapped_column(String(512))
    metadata_json: Mapped[dict | None] = mapped_column("metadata", JSON)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class Transaction(Base):
    __tablename__ = "transactions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    order_id: Mapped[int] = mapped_column(ForeignKey("orders.id"), index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    gateway: Mapped[str] = mapped_column(String(32))
    type: Mapped[str] = mapped_column(String(32))  # AUTH, CAPTURE, REFUND, VOID
    amount: Mapped[float] = mapped_column(Float)
    currency: Mapped[str] = mapped_column(String(8), default="USD")
    status: Mapped[str] = mapped_column(String(32))  # PENDING, SUCCEEDED, FAILED
    raw_payload: Mapped[dict | None] = mapped_column(JSON)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class ScrapedProduct(Base):
    __tablename__ = "scraped_products"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    brand_id: Mapped[int] = mapped_column(ForeignKey("brands.id"), index=True)
    external_id: Mapped[str] = mapped_column(String(255), index=True)
    name: Mapped[str] = mapped_column(String(255))
    url: Mapped[str] = mapped_column(String(512))
    image_url: Mapped[str | None] = mapped_column(String(512))
    price: Mapped[float | None] = mapped_column(Float)
    currency: Mapped[str | None] = mapped_column(String(8))
    raw_attributes: Mapped[dict | None] = mapped_column(JSON)
    hash: Mapped[str | None] = mapped_column(String(64), index=True)
    status: Mapped[str] = mapped_column(String(32), default="ACTIVE")
    last_scraped_at: Mapped[datetime | None] = mapped_column(DateTime)


class PriceHistory(Base):
    __tablename__ = "price_history"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    scraped_product_id: Mapped[int] = mapped_column(ForeignKey("scraped_products.id"), index=True)
    price: Mapped[float] = mapped_column(Float)
    currency: Mapped[str] = mapped_column(String(8))
    scraped_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class ArAsset(Base):
    __tablename__ = "ar_assets"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), index=True)
    brand_id: Mapped[int] = mapped_column(ForeignKey("brands.id"), index=True)
    model_url: Mapped[str] = mapped_column(String(512))
    texture_urls: Mapped[dict | None] = mapped_column(JSON)
    skeleton_type: Mapped[str] = mapped_column(String(32), default="arkit")
    lod_level: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), index=True)
    event_type: Mapped[str] = mapped_column(String(64), index=True)
    product_id: Mapped[int | None] = mapped_column(ForeignKey("products.id"), index=True)
    brand_id: Mapped[int | None] = mapped_column(ForeignKey("brands.id"), index=True)
    order_id: Mapped[int | None] = mapped_column(ForeignKey("orders.id"), index=True)
    metadata_json: Mapped[dict | None] = mapped_column("metadata", JSON)
    occurred_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)


class BrandPhoto(Base):
    __tablename__ = "brand_photos"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    uploader_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    brand_id: Mapped[int] = mapped_column(ForeignKey("brands.id"), index=True)
    product_id: Mapped[int | None] = mapped_column(ForeignKey("products.id"), index=True)
    image_url: Mapped[str] = mapped_column(String(512))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserStyleProfile(Base):
    __tablename__ = "user_style_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    dominant_body_type: Mapped[str | None] = mapped_column(String(32))
    dominant_skin_tone: Mapped[str | None] = mapped_column(String(32))
    style_vector: Mapped[dict | None] = mapped_column(JSON)
    color_vector: Mapped[dict | None] = mapped_column(JSON)
    occasion_distribution: Mapped[dict | None] = mapped_column(JSON)
    brand_affinity: Mapped[dict | None] = mapped_column(JSON)
    last_updated: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class RecommendationHistory(Base):
    __tablename__ = "recommendation_history"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), index=True)
    brand_id: Mapped[int] = mapped_column(ForeignKey("brands.id"), index=True)
    score: Mapped[float] = mapped_column(Float)
    scores_breakdown: Mapped[dict | None] = mapped_column(JSON)
    action: Mapped[str | None] = mapped_column(String(32))  # viewed, clicked, saved, purchased
    shown_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)

