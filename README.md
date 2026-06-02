## Style With Us – AI Fashion & Virtual Try‑On

Style With Us is a full‑stack fashion‑tech product built with **Flutter** (mobile app) and **FastAPI** (Python backend).  
Users can discover outfits from partner brands, get **AI style analysis**, and preview **virtual try‑on** experiences before buying.

---

## High‑Level Features

- **Multi‑role platform**
  - **User**: normal shopper, can browse brands, run AI style analysis, try outfits, and checkout.
  - **Brand**: brand partner, can access a brand console and see how products appear in try‑on.
  - **Admin**: platform admin, can access high‑level dashboards for brands, inventory and AI.

- **Authentication & Roles**
  - Email/password auth using **Firebase Auth**.
  - On **Sign Up**, the user chooses a role: **User / Brand / Admin**.
  - Role is stored in Firestore (`users` collection) with fields:
    - `name`, `email`, `role`, `createdAt`, `preferences`.
  - After login/signup:
    - `user` → `/home` (user home)
    - `brand` → `/brand` (brand console)
    - `admin` → `/admin` (admin dashboard)

- **User App**
  - Modern, animated home screen with:
    - Quick actions (AI Style Analysis, Saved Outfits, Trending, My Wardrobe).
    - Featured collections and personalized grid.
  - Brands listing and brand products (mock data but production‑ready UI).
  - Cart + checkout scaffolding wired to backend order APIs (stubbed payments).

- **AI Style Analysis**
  - Screen: `AIAnalysisScreen` (`/ai-analysis`).
  - User uploads or captures an outfit / body photo.
  - The backend (`/ml/analyze`) uses **PyTorch (ResNet50)** for body shape classification and **Stone** for skin tone analysis.
  - Navigates to `ResultsScreen` showing:
    - Real style summary based on ML outputs.
    - Perfect match outfit dynamically queried from the PostgreSQL database (`/ml/recommend`).
    - Similar styles and “Complete the Look” accessories (with cart integration).

- **AI Virtual Try‑On**
  - Backend endpoint: `/ml/virtual-tryon` (FastAPI).
    - Request: `VirtualTryOnRequest { user_id, product_id, image_url }`
    - Response: `VirtualTryOnResponse { session_id, product_id, result_image_url, explanation, created_at }`
    - **Real/Mock Status:** The endpoint is fully functional but uses **MediaPipe Pose Estimation** and **PIL/OpenCV bounding box compositing** to overlay the requested clothing onto the user's torso. It serves as a working lightweight substitute for heavy custom GPU diffusion models (like VITON-HD).
    - Jobs are queued asynchronously in **Celery + Redis** to prevent request blocking.
  - New Flutter screen: `VirtualTryOnScreen` (`/virtual-try-on/:productId`).
    - Lets user pick a **full‑body photo** from gallery.
    - Calls backend using `ApiClient.postJson('/ml/virtual-tryon', …)`.
    - Shows loading state, then the returned `result_image_url` and explanation.
  - Entry points:
    - From **Brand Products**: tap any product card to open `/virtual-try-on/<productId>`.
    - From **Brand Dashboard**: “AI Try‑On” tile opens `/virtual-try-on/1000` as a demo.

- **AR Try‑On (Proof of Concept)**
  - Screen: `ArTryOnScreen` (`/ar-try-on`).
  - Implements a live front-facing **Camera Preview** utilizing Flutter's `camera` and `permission_handler` plugins.
  - Features an `InteractiveViewer` layer for seamlessly pinching, rotating, and dragging digital 2D garments over the live camera feed. 
  - *Note:* This represents a manual 2D overlay rather than a full 3D spatial mapping solution. For deeper AR tracking, Native ARKit/ARCore integration is recommended over Flutter's base camera logic.

- **Backend Commerce & Stripe Payments**
  - `/inventory` router: check stock and reserve SKUs using SQLAlchemy models.
  - `/orders` router: Integrates directly with the **Stripe SDK** to generate `PaymentIntents` and listen to Webhooks (`/webhooks/stripe`) to confirm database orders reliably.
  - Flutter app integrates `flutter_stripe` to securely present the native Stripe Payment Sheet.

- **Production Architecture & Upgrades**
  - **Security & APIs**: Endpoints fortified via Firebase Auth JWT interceptors. Added automated retries, `401/429` global interceptors in Flutter, and `slowapi` rate limiting.
  - **Asynchronous ML**: CPU-heavy ML execution moved to a dedicated Celery worker configured by Redis.
  - **Push Notifications**: Integrated Firebase Cloud Messaging to send direct push alerts to Android/iOS on Order Confirmation or ML Job Completion.
  - **Realtime Dashboards**: Built fully functional notification, history, and brand pages featuring live `fl_chart` analytics.
  - **CI/CD Build System**: Automated GitHub Actions to run Pytest suites and orchestrate EC2 SSH pull-and-deploy sequences.

---

## Tech Stack

- **Frontend (mobile)**
  - Flutter 3 (Dart 3)
  - State management: `flutter_riverpod`
  - Routing: `go_router`
  - Animations & UI: `flutter_animate`, `lottie`, `glassmorphism` style widgets, gradients.
  - Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
  - Media: `image_picker`, `cached_network_image`

- **Backend**
  - Python + **FastAPI**
  - Pydantic models (`schemas.py`)
  - SQLAlchemy models & DB session (`models.py`, `db.py`)
  - Routers:
    - `/ml` – AI analysis, recommendations, virtual try‑on (mock implementations).
    - `/inventory` – stock checks and reservations.
    - `/orders` – order creation, payment stub, and webhook placeholders.

---

## Project Structure (Important Parts)

- `style_with_us/lib/main.dart` – Flutter entrypoint.
- `style_with_us/lib/core/router/app_router.dart`
  - Central `GoRouter` configuration and auth redirect.
  - Routes for:
    - `/` – Onboarding.
    - `/login` – Auth.
    - `/home` – User home.
    - `/brands` + nested `/:brandId` – Brand list and brand products.
    - `/cart`, `/checkout`, `/profile`.
    - `/ai-analysis`, `/results/:analysisId`.
    - `/virtual-try-on/:productId`.
    - `/ar-try-on`, `/admin`, `/brand`.
- `style_with_us/lib/core/services/auth_service.dart`
  - `signUp(name, email, password, role)` – creates Firebase user + Firestore doc with `role`.
  - `login(email, password)`.
  - `getCurrentUserRole()` – reads `role` from Firestore and defaults to `user`.
- `style_with_us/lib/features/auth/auth_screen.dart`
  - Login / Sign Up with **role selection chips** (User / Brand / Admin).
  - After auth, redirects to correct dashboard based on role.
- `style_with_us/lib/features/home/home_screen.dart`
  - Main home UI for shoppers.
- `style_with_us/lib/features/brands/brands_screen.dart`
  - Brand discovery screen.
- `style_with_us/lib/features/brands/brand_products_screen.dart`
  - Brand products grid; product tap → virtual try‑on.
- `style_with_us/lib/features/brands/brand_dashboard_screen.dart`
  - Brand console for brand partners.
- `style_with_us/lib/features/admin/admin_dashboard_screen.dart`
  - Admin overview dashboard.
- `backend/app/main.py`
  - FastAPI app factory, CORS, and router registration.
- `backend/app/routers/*.py`
  - `ml.py`, `inventory.py`, `payments.py` (orders).
- `backend/app/schemas.py`
  - Pydantic models for all request/response payloads.

---

## Running the App

### Prerequisites

- Flutter SDK installed and configured.
- Dart 3 compatible environment.
- Firebase project set up with:
  - Email/Password sign‑in enabled.
  - `google-services.json` / `GoogleService-Info.plist` already present in the project.
- Python 3.10+ with virtualenv (recommended) for the backend.

### 1. Run the Backend (FastAPI via Docker)

The recommended way for a production-ready environment is using **Docker Compose**. The YAML file natively provides PostgreSQL, Redis, Celery Workers, a background `pg_dump` backup cron, Nginx reverse proxy, and FastAPI nodes automatically.

From the project root:

```bash
cd backend
# Create the environment file based on the example
cp .env.example .env

# Optional: Edit .env to add your Firebase path and Stripe secrets
nano .env

# Spin up the entire infrastructure
docker compose up --build -d

# Run Database Migrations to initialize the newest Alembic structures
docker compose exec api alembic upgrade head
```

The backend will be available at `http://localhost:8000` and exposes:

- `GET /health`
- `POST /ml/analyze`
- `POST /ml/recommend`
- `POST /ml/virtual-tryon`
- `GET /inventory/sku/{sku_id}`
- `POST /inventory/reserve`
- `POST /orders/create`
- `POST /orders/confirm`

### 2. Run the Flutter App

Once the backend is running you can use the app to:

- sign up as **User**, **Brand**, or **Admin** (roles are stored in Firestore).
- if you create brand/admin accounts you may also want to run the
  `backend/scripts/seed_users.py` script or insert corresponding records into
  the backend database so that the API recognizes them.  For **brand** users,
  also add a `brandId` field to their Firestore document (matching an ID from
  your `brands` table) so the mobile UI can pre‑select the correct brand in the
  upload flow.

The app now includes a **Photo Gallery** screen (`/brands/gallery`) that
shows all brand‑uploaded pictures, and a full **Upload Photo** flow under the
brand dashboard.

The rest of the README steps remain the same.

From `style_with_us`:

```bash
flutter pub get
flutter run
```

The default `ApiClient` base URL is `http://localhost:8000`, so if you run on a real device you may need to change it to your machine IP (e.g. `http://192.168.1.10:8000`) in `lib/core/network/api_client.dart`.

---

## User Flows

- **User**
  1. Open app → onboarding (`/`).
  2. Sign up as **User** (or login).
  3. Land on `/home`.
  4. Browse brands/products, run AI analysis, optionally use virtual try‑on.
  5. Add items to cart and proceed to checkout (payments currently stubbed).

- **Brand**
  1. Sign up as **Brand**.
  2. Land on `/brand` (BrandDashboard).
  3. Open “My Products” or “AI Try‑On”.
  4. Use `/virtual-try-on/:productId` to preview mocked AI try‑on for chosen SKUs.

-- **Admin**
  1. Sign up as **Admin**.
  2. Land on `/admin` (AdminDashboard).
  3. Use dashboard cards as entry points to manage brands, inventory and AI (wiring to backend can be expanded).

---

## Extending the AI & Try‑On

- Replace stub logic inside:
  - `backend/app/routers/ml.py` (`analyze`, `recommend`, `virtual-tryon`) with real model calls.
- For realistic try‑on:
  - Upload user body images and product assets to cloud storage (e.g. Firebase Storage, S3).
  - Pass secure URLs to the backend via `image_url`.
  - Run your generative / diffusion model and return the composed image URL as `result_image_url`.

The Flutter app is already structured to consume these real endpoints without major UI changes.
#   u b a i d - f y p  
 