# Style With Us - Complete Backend Architecture & Technical Overview

## EXECUTIVE SUMMARY

**Language:** Python 3.11  
**Framework:** FastAPI (async REST API)  
**Architecture Pattern:** Microservices-ready with async background task processing  
**Status:** Production-ready foundation with demo/mock ML implementations

---

## 1. LANGUAGE & FRAMEWORK DETAILS

### Primary Language: Python 3.11
- **Why Python?**
  - Rich ML/AI ecosystem (PyTorch, TensorFlow, scikit-learn)
  - Rapid development and prototyping
  - Excellent async support with asyncio
  - Strong data processing libraries
  - Active community and libraries

### Framework: FastAPI
- **Async-first:** Built on Starlette, supports async/await
- **Auto-generated API docs:** Swagger UI at `/docs`, ReDoc at `/redoc`
- **Type hints:** Full Pydantic v2 integration for request/response validation
- **Performance:** One of the fastest Python web frameworks
- **Production-ready:** Used by companies like Netflix, Microsoft, Uber

### Server: Uvicorn
- **ASGI server** for running FastAPI applications
- **Production-grade** HTTP server
- **Supports:** WebSockets, HTTP/2, SSL/TLS

---

## 2. COMPLETE TECHNOLOGY STACK

### Core Web Infrastructure
```
FastAPI 0.115.2          ← Modern async web framework
├── Uvicorn 0.30.6       ← ASGI application server
├── Starlette            ← Underlying ASGI toolkit
├── Pydantic 2.9.2       ← Data validation (type hints)
├── pydantic-settings    ← Environment config management
├── python-dotenv        ← Load .env files
└── orjson 3.10.7        ← Fast JSON serialization
```

### Database Layer
```
SQLAlchemy 2.0.36        ← ORM & query builder
├── PostgreSQL           ← Primary database
├── psycopg 3.2.3        ← PostgreSQL adapter (modern, supports async)
├── Alembic 1.13.2       ← Database migrations & versioning
└── python-multipart     ← Form data handling for uploads
```

### Task Queue & Caching
```
Celery 5.3.6             ← Distributed task queue
├── Redis 5.2.0          ← Message broker & result backend
├── celery[redis]        ← Redis transport for Celery
└── Task serialization   ← JSON format
```

### Machine Learning & Vision
```
Optional ML Stack:
├── MediaPipe 0.10.14    ← Pose estimation for virtual try-on
├── PyTorch 2.0.1        ← Deep learning framework
├── TorchVision 0.15.2   ← Pre-trained models (ResNet50)
├── skin-tone-classifier ← STONE library for skin tone analysis
├── OpenCV 4.8.1.78      ← Image processing & computer vision
├── Pillow 10.0.0        ← Image manipulation
├── NumPy 1.24.3         ← Numerical computing
├── colormath 3.0.0      ← Color calculations
└── httpx 0.27.2         ← Async HTTP for downloading images
```

### Payment & Checkout
```
Stripe 11.2.0            ← Premium payment processing
└── PaymentIntent API    ← Async payment flows

Razorpay 1.4.2           ← Indian payment gateway
└── Order management
```

### Firebase & Cloud Services
```
firebase-admin 6.5.0     ← Firebase Admin SDK
├── Authentication       ← Firebase Auth JWT verification
├── Cloud Messaging      ← FCM for push notifications
└── google-cloud-firestore 2.23.0 ← Document database
```

### Rate Limiting & Security
```
slowapi 0.1.9            ← Rate limiting middleware
├── Sliding window algorithm
├── Per-endpoint configuration
└── HTTP 429 responses for exceeded limits
```

---

## 3. PROJECT STRUCTURE & LAYOUT

```
backend/
│
├── app/
│   ├── main.py                    # ← FastAPI app factory & router includes
│   ├── models.py                  # ← SQLAlchemy ORM models (User, Brand, Product, Order, etc.)
│   ├── schemas.py                 # ← Pydantic request/response schemas
│   ├── auth.py                    # ← Firebase JWT token verification
│   ├── db.py                      # ← SQLAlchemy engine, session factory
│   ├── config.py                  # ← Pydantic settings for configuration
│   ├── firebase.py                # ← Firebase Admin initialization
│   ├── ml_utils.py                # ← Utility functions for ML (body classification, etc.)
│   ├── dependencies.py            # ← FastAPI dependency injection helpers
│   │
│   ├── core/
│   │   ├── celery_app.py          # ← Celery initialization with Redis broker
│   │   ├── config.py              # ← Core configuration constants
│   │   ├── firebase.py            # ← Firebase setup & credentials
│   │   ├── limiter.py             # ← slowapi rate limiter instance
│   │   └── ...
│   │
│   ├── routers/                   # ← API endpoint modules (FastAPI routers)
│   │   ├── ml.py                  # POST /ml/analyze, /ml/recommend, /ml/virtual-tryon
│   │   ├── payments.py            # POST /orders/create, /orders/confirm, /webhooks/stripe
│   │   ├── inventory.py           # GET /inventory/check, POST /inventory/reserve
│   │   ├── brands.py              # GET /brands, POST /brands
│   │   ├── photos.py              # POST /photos/upload
│   │   └── notifications.py       # POST /notifications/send, GET /notifications/history
│   │
│   └── tasks/
│       └── ml_tasks.py            # ← Celery background tasks for ML processing
│
├── alembic/                       # ← Database migration system
│   ├── env.py
│   ├── alembic.ini
│   └── versions/                  # ← Migration scripts
│       ├── 20260226_add_brand_id_and_photos.py
│       └── 20260226_add_firebase_uid.py
│
├── nginx/
│   └── nginx.conf                 # ← Reverse proxy configuration (for production)
│
├── scripts/
│   └── seed_users.py              # ← Database seeding script
│
├── requirements.txt               # ← Core Python dependencies
├── requirements-ml.txt            # ← Optional ML dependencies
├── Dockerfile                     # ← Docker containerization
├── docker-compose.yml             # ← Multi-container orchestration
├── setup.sh                       # ← Linux/Mac setup script
├── run_backend.bat                # ← Windows startup script
├── ML_INTEGRATION.md              # ← ML integration documentation
├── test_ml.py                     # ← ML testing script
└── uploads/                       # ← Directory for user-uploaded files (images, photos)
```

---

## 4. DATABASE SCHEMA (SQLAlchemy ORM Models)

### Core Tables & Relationships

#### `users` Table
```python
id (PK)                 # Primary key (auto-increment)
email (UNIQUE)          # User email address
firebase_uid (UNIQUE)   # Firebase authentication UID
fcm_token               # Firebase Cloud Messaging token for push notifications
password_hash           # Hashed password (nullable, Firebase-only if not set)
name                    # User display name
role                    # 'USER', 'BRAND', 'ADMIN'
brand_id (FK→brands)    # Foreign key to brands (for brand admins)
created_at              # Account creation timestamp
last_login_at           # Last login timestamp
```

#### `brands` Table
```python
id (PK)                 # Primary key
name (UNIQUE)           # Brand name
logo_url                # Brand logo image URL
banner_url              # Banner image URL
description             # Brand description/bio
website_url             # Official website
tier                    # 'free', 'premium', 'enterprise' (subscription level)
```

#### `products` Table
```python
id (PK)
brand_id (FK→brands)    # Foreign key linking to brand
name                    # Product name
slug                    # URL-friendly identifier
description             # Product description
main_image_url          # Primary product image
price                   # Numeric price
currency                # ISO 4217 code (USD, INR, etc.)
style_type              # e.g., 'casual', 'formal', 'sportswear'
style_tags (JSON)       # Array of tags: ["denim", "comfortable"]
color_tone              # e.g., 'warm', 'cool', 'neutral'
color_tags (JSON)       # Color metadata
occasion                # e.g., 'everyday', 'wedding', 'formal'
season                  # e.g., 'summer', 'winter', 'all-season'
gender                  # 'M', 'W', 'U' (unisex)
is_active               # Soft delete flag
created_at / updated_at # Timestamps
```

#### `inventory` Table
```python
id (PK)
product_id (FK→products)
sku_id (STRING)         # Stock keeping unit
location_id (STRING)    # Warehouse/store location
stock_available         # Available units
stock_reserved          # Reserved/pending units
stock_sold              # Total sold
updated_at              # Timestamp

UNIQUE CONSTRAINT: (sku_id, location_id)
```

#### `orders` Table
```python
id (PK)
user_id (FK→users)
amount_subtotal         # Sum of item prices
amount_shipping         # Shipping cost
amount_total            # Total amount due
currency                # ISO 4217 code
status                  # Enum: PENDING_PAYMENT, PAID, FAILED, REFUNDED, PARTIALLY_REFUNDED, CANCELLED
payment_gateway         # 'stripe' or 'razorpay'
payment_intent_id       # External payment provider ID
failure_reason          # Error message if failed
metadata_json           # Additional payment metadata
created_at / updated_at # Timestamps
```

#### `transactions` Table
```python
id (PK)
order_id (FK→orders)
user_id (FK→users)
gateway                 # 'stripe' or 'razorpay'
type                    # 'AUTH', 'CAPTURE', 'REFUND', 'VOID'
amount                  # Transaction amount
currency                # ISO 4217 code
status                  # 'PENDING', 'SUCCEEDED', 'FAILED'
raw_payload (JSON)      # Full response from payment provider
created_at              # Timestamp
```

#### `scraped_products` Table
```python
id (PK)
brand_id (FK→brands)
external_id             # ID from scraping source
name                    # Product name
url                     # Source URL
image_url               # Product image
price / currency        # Price information
raw_attributes (JSON)   # Structured product metadata
hash                    # Deduplication hash
status                  # 'ACTIVE' or 'INACTIVE'
last_scraped_at         # Last update timestamp
```

#### `price_history` Table
```python
id (PK)
scraped_product_id (FK→scraped_products)
# Additional price tracking fields
```

---

## 5. API ENDPOINTS BREAKDOWN

### Authentication Pattern
```
All requests require Firebase JWT token in Authorization header:
Authorization: Bearer <firebase_jwt_token>
```

### ML Endpoints (`/ml`)

#### `POST /ml/analyze`
- **Purpose:** Analyze user's body type and skin tone
- **Rate Limit:** 10 requests/minute
- **Request Body:**
  ```json
  {
    "user_id": 123,
    "image_url": "https://..."
  }
  ```
- **Response:**
  ```json
  {
    "analysis_id": "uuid",
    "body_type": "hourglass",
    "body_confidence": 0.92,
    "skin_tone": "warm",
    "skin_confidence": 0.88,
    "created_at": "2026-06-02T10:00:00Z"
  }
  ```
- **Current Implementation:** Mock results for demo (bypasses Celery for smooth UX)
- **Real Implementation:** Would use ResNet50 + STONE library via Celery

#### `POST /ml/recommend`
- **Purpose:** Get personalized product recommendations
- **Rate Limit:** 20 requests/minute
- **Request Body:**
  ```json
  {
    "user_id": 123,
    "analysis_id": "uuid",
    "target_occasion": "casual",
    "limit": 20
  }
  ```
- **Response:**
  ```json
  {
    "recommendation_id": "uuid",
    "products": [
      {
        "product_id": 1,
        "brand_id": 1,
        "score": 0.95,
        "scores": {
          "body": 0.95,
          "color": 0.92,
          "occasion": 0.98,
          "brand": 0.90
        },
        "explanation": "This silhouette flatters your body type...",
        "rank": 1
      }
    ],
    "top_brands": [
      {"brand_id": 1, "brand_score": 0.92}
    ]
  }
  ```
- **Implementation:** Database queries + algorithmic scoring based on style attributes

#### `POST /ml/virtual-tryon`
- **Purpose:** Generate virtual try-on image overlay
- **Rate Limit:** Custom (Celery async task)
- **Request Body:**
  ```json
  {
    "user_id": 123,
    "product_id": 456,
    "image_url": "https://..."
  }
  ```
- **Response:**
  ```json
  {
    "session_id": "uuid",
    "product_id": 456,
    "result_image_url": "https://cdn.../tryon_result.jpg",
    "explanation": "Garment overlaid based on pose detection...",
    "created_at": "2026-06-02T10:00:00Z"
  }
  ```
- **Implementation:** MediaPipe Pose Estimation + PIL/OpenCV compositing
- **Processing:** Asynchronous Celery task to prevent blocking

### Payment Endpoints (`/orders`)

#### `POST /orders/create`
- **Purpose:** Create order and initialize payment
- **Authentication:** Required
- **Request Body:**
  ```json
  {
    "user_id": 123,
    "items": [
      {
        "product_id": 1,
        "sku_id": "SKU-001",
        "quantity": 2,
        "unit_price": 99.99
      }
    ],
    "currency": "USD",
    "payment_gateway": "stripe"
  }
  ```
- **Response:**
  ```json
  {
    "order_id": 789,
    "amount_total": 199.98,
    "currency": "USD",
    "payment_gateway": "stripe",
    "stripe_client_secret": "pi_test_...",
    "razorpay_order_id": null
  }
  ```
- **Implementation:**
  - Creates Order record in database
  - Calls Stripe PaymentIntent API with order amount
  - Returns client secret for frontend payment sheet

#### `POST /orders/confirm`
- **Purpose:** Confirm order after successful payment
- **Request Body:**
  ```json
  {
    "order_id": 789,
    "payment_status": "succeeded",
    "gateway_reference": "pi_..."
  }
  ```
- **Implementation:** Updates order status, reserves inventory

#### `POST /webhooks/stripe`
- **Purpose:** Handle Stripe webhook events
- **Trigger Events:** payment_intent.succeeded, payment_intent.payment_failed
- **Implementation:** Updates order status via webhook verification

### Inventory Endpoints (`/inventory`)

#### `GET /inventory/check`
- **Purpose:** Check stock availability
- **Query Parameters:** `sku_id`, `location_id` (optional)
- **Response:**
  ```json
  {
    "sku_id": "SKU-001",
    "location_id": "warehouse-1",
    "available": 15,
    "reserved": 2,
    "total": 17
  }
  ```

#### `POST /inventory/reserve`
- **Purpose:** Reserve inventory for order
- **Request Body:**
  ```json
  {
    "sku_id": "SKU-001",
    "location_id": "warehouse-1",
    "quantity": 2
  }
  ```
- **Response:** Confirmation with updated stock

### Brand Endpoints (`/brands`)

#### `GET /brands`
- **Purpose:** List all brands
- **Response:** Array of brand objects

#### `GET /brands/{brand_id}`
- **Purpose:** Get brand details with products
- **Response:** Brand object with product list

#### `POST /brands` (Admin only)
- **Purpose:** Create new brand
- **Request Body:** Brand creation form

### Photo Endpoints (`/photos`)

#### `POST /photos/upload`
- **Purpose:** Upload and store user photos
- **Implementation:** Multipart form data, stores in `/uploads` directory

### Notification Endpoints (`/notifications`)

#### `POST /notifications/send`
- **Purpose:** Send push notification via Firebase Cloud Messaging
- **Implementation:** Uses FCM token from user record

#### `GET /notifications/history`
- **Purpose:** Get user's notification history

### Health Check

#### `GET /health`
- **Purpose:** Service health status
- **Response:** `{"status": "ok"}`
- **Use:** Load balancer health checks, monitoring

---

## 6. AUTHENTICATION & SECURITY

### Firebase Authentication Flow
```
Client (Flutter App)
    ↓ [Login/Signup]
Firebase Auth (Email/Password, Google Sign-In, etc.)
    ↓ [Returns Firebase JWT token]
Client [Stores token in secure storage]
    ↓ [Includes token in Authorization header]
FastAPI Backend
    ↓ verify_firebase_token() dependency
Firebase Admin SDK [Verifies JWT signature]
    ↓
Request proceeds OR returns 401 Unauthorized
```

### Token Verification Details
```python
# Location: app/auth.py

def verify_firebase_token(authorization: str) -> dict:
    """
    Extracts Bearer token from Authorization header
    Verifies signature using Firebase Admin SDK
    Returns decoded token with uid, claims, etc.
    """
```

### Demo Mode Override
- **Development:** `ENVIRONMENT=dev` + `token=dummy-dev-token` bypasses Firebase
- **Production:** Strict verification required (no bypass)

### Security Features
1. **JWT Token Verification:** Firebase Admin SDK validates signature
2. **Rate Limiting:** slowapi prevents brute force attacks
3. **CORS Configuration:** Configurable allowed origins
4. **Input Validation:** Pydantic models reject invalid data types
5. **SQL Injection Prevention:** SQLAlchemy ORM parameterized queries
6. **Environment Variables:** Sensitive data (API keys) never committed to git

---

## 7. BACKGROUND TASK PROCESSING (Celery + Redis)

### Architecture
```
FastAPI Request Handler (Fast)
    ↓
Submit task to Celery/Redis queue
    ↓ (Async processing)
Redis message broker receives task
    ↓
Celery Worker processes long-running task
    ↓
Results stored in Redis (expires in 1 hour)
    ↓ (Polling/WebSocket)
Client retrieves result when ready
```

### Configuration (celery_app.py)
```python
broker_url = "redis://localhost:6379/0"
result_backend = "redis://localhost:6379/0"
task_serializer = "json"
result_expires = 3600  # 1 hour
```

### Task Example: Virtual Try-On Processing
```python
@celery.task
def process_virtual_tryon(user_id, product_id, image_url):
    # 1. Download image from URL
    # 2. Run MediaPipe pose estimation
    # 3. Load garment image
    # 4. Overlay garment on detected pose
    # 5. Save result image
    # 6. Return result_image_url
```

### Benefits
- Prevents request timeouts for long-running operations
- Scalable: Multiple worker processes can handle tasks in parallel
- Reliable: Tasks persist in queue if worker crashes
- Monitoring: Track task status and history

---

## 8. MACHINE LEARNING COMPONENTS

### ML Stack Overview
```
Optional (can be installed separately):
├── MediaPipe 0.10.14        → Pose detection for try-on
├── PyTorch 2.0.1            → Deep learning framework
├── TorchVision 0.15.2       → Pre-trained models
├── skin-tone-classifier     → STONE library
├── OpenCV 4.8.1.78          → Image processing
└── Pillow 10.0.0            → Image manipulation
```

### 1. Body Type Classification
- **Model:** ResNet50 (pre-trained on ImageNet)
- **Output Categories:**
  - `pear` - Wider hips than shoulders
  - `apple` - Wider midsection
  - `hourglass` - Balanced curves
  - `rectangle` - Straight frame
  - `inverted` - Wider shoulders than hips
  - `diamond` - Wide midsection with full bust/hips
  - `oval` - Rounded overall shape
- **Output:** Category + confidence score (0-1)

### 2. Skin Tone Classification
- **Library:** skin-tone-classifier (STONE)
- **Categories:** warm, cool, neutral
- **Output:** Category + confidence score

### 3. Virtual Try-On (Lightweight Implementation)
- **Method:** MediaPipe Pose Estimation + PIL/OpenCV
- **Process:**
  1. Detect human pose keypoints (17 key body positions)
  2. Estimate garment dimensions and positioning
  3. Load garment image
  4. Apply transformations (scale, rotate, translate)
  5. Composite garment onto body image
  6. Save result
- **Advantage:** Lightweight, CPU-friendly, no GPU required
- **Limitation:** 2D overlay only (not 3D fitting)
- **Future:** Can upgrade to VITON-HD or similar for advanced 3D fitting

### Current ML Implementation Status
- **Analyze Endpoint:** Returns mock results (no actual ML processing)
- **Recommend Endpoint:** Database queries + algorithmic scoring
- **Virtual Try-On:** Full MediaPipe implementation working
- **Note:** Actual ResNet50 & STONE can be enabled by installing requirements-ml.txt

---

## 9. DEPLOYMENT & CONTAINERIZATION

### Docker Setup
```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get install postgresql-client libgl1-mesa-glx libglib2.0-0

# Install Python packages
COPY requirements.txt requirements-ml.txt ./
RUN pip install -r requirements.txt -r requirements-ml.txt

# Copy source
COPY . .

# Create uploads directory
RUN mkdir -p uploads

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose (Multi-Container Orchestration)
```yaml
services:
  backend:        # FastAPI app
  postgres:       # PostgreSQL database
  redis:          # Redis cache & message broker
  celery-worker:  # Background task processor
  nginx:          # Reverse proxy & static file serving
```

### Production Deployment
- **Server:** EC2 instance (AWS) or similar
- **Load Balancer:** Nginx reverse proxy
- **Database:** Managed PostgreSQL (RDS recommended)
- **Cache/Queue:** Managed Redis (ElastiCache recommended)
- **CI/CD:** GitHub Actions for automated testing and deployment
- **Monitoring:** Application performance monitoring (APM) tools

---

## 10. ENVIRONMENT CONFIGURATION

### .env File Structure
```
# App
APP_NAME=Style With Us Backend
ENVIRONMENT=production

# Database
DATABASE_URL=postgresql+psycopg://user:password@db:5432/style_with_us

# Redis
REDIS_URL=redis://redis:6379/0

# Stripe
STRIPE_API_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Razorpay
RAZORPAY_KEY_ID=rzp_live_...
RAZORPAY_KEY_SECRET=...

# Firebase
FIREBASE_PROJECT_ID=style-with-us-prod
GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json

# CORS
ALLOWED_ORIGINS=https://app.domain.com,https://admin.domain.com
```

### Configuration Hierarchy
```
1. .env file (highest priority)
2. Environment variables
3. Default values in code (lowest priority)
```

---

## 11. DEVELOPMENT & TESTING

### Local Development Setup
```bash
# 1. Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Setup PostgreSQL locally
createdb style_with_us

# 4. Run migrations
alembic upgrade head

# 5. Start Redis (separate terminal)
redis-server

# 6. Start Celery worker (separate terminal)
celery -A app.tasks.celery_app worker --loglevel=info

# 7. Start FastAPI dev server
uvicorn app.main:app --reload --port 8000
```

### Testing
```bash
# Run pytest suite
pytest tests/

# With coverage report
pytest --cov=app tests/
```

### Database Migrations
```bash
# Create new migration
alembic revision --autogenerate -m "Add new column"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

---

## 12. PERFORMANCE METRICS & OPTIMIZATION

### Current Optimizations
1. **Async/Await:** Non-blocking I/O operations
2. **Connection Pooling:** SQLAlchemy connection pool (default: 5 connections)
3. **Caching:** Redis for temporary results and session storage
4. **Rate Limiting:** Prevent abuse and ensure fair resource usage
5. **Database Indexing:** Keys indexed on frequently queried fields
6. **Fast JSON:** orjson for faster serialization than standard json

### Recommendations
1. **Database:** Add query result caching layer (Redis)
2. **Images:** CDN (CloudFront, Cloudflare) for image delivery
3. **Monitoring:** Datadog, New Relic for APM
4. **Scaling:** Horizontal scaling via load balancer + multiple instances
5. **ML:** GPU acceleration for real-time pose estimation at scale

---

## 13. API DOCUMENTATION

### Auto-Generated Docs
- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`
- **OpenAPI JSON:** `http://localhost:8000/openapi.json`

### Interactive Testing
- All endpoints can be tested directly from Swagger UI
- Request/response examples automatically generated from Pydantic models

---

## 14. SUMMARY FOR GEMINI / AI ASSISTANTS

### Key Technical Characteristics
1. **Language:** Python 3.11 (highly pythonic, type-annotated)
2. **Framework:** FastAPI (async, modern, type-safe)
3. **Architecture:** RESTful API with background task processing
4. **Database:** PostgreSQL (relational) with SQLAlchemy ORM
5. **Queue:** Celery + Redis (async task processing)
6. **ML:** MediaPipe for pose estimation, optional ResNet50 & STONE
7. **Payments:** Stripe & Razorpay integration
8. **Auth:** Firebase JWT tokens
9. **Deployment:** Docker + docker-compose + Nginx

### Codebase Characteristics
- **Type-safe:** Full Pydantic data validation
- **Well-organized:** Clear separation of concerns (models, schemas, routers, tasks)
- **Scalable:** Async architecture supports high concurrency
- **Cloud-ready:** Environment configuration, containerization, microservices pattern
- **Production-ready:** Security, rate limiting, error handling, logging

### AI Integration Points
- Skin tone classification (STONE library)
- Body type classification (ResNet50)
- Style recommendations (algorithmic scoring)
- Virtual try-on (pose estimation + image compositing)
- All future expansions have clear integration paths

---

## 15. QUICK START FOR NEW DEVELOPERS

```bash
# 1. Clone repository
git clone <repo-url>

# 2. Setup Python environment
python -m venv venv && source venv/bin/activate

# 3. Install packages
pip install -r requirements.txt

# 4. Setup database
# Update DATABASE_URL in .env
alembic upgrade head

# 5. Setup Redis
# Ensure Redis server running locally or update REDIS_URL

# 6. Start development server
uvicorn app.main:app --reload

# 7. Test API
curl http://localhost:8000/health
# Response: {"status":"ok"}
```

---

## 16. CONTACT & DOCUMENTATION

- **README:** [README.md](../README.md)
- **ML Integration:** [ML_INTEGRATION.md](./ML_INTEGRATION.md)
- **API Docs:** `http://localhost:8000/docs` (when running)
- **Docker:** See [docker-compose.yml](./docker-compose.yml)
