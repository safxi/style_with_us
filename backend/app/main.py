from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from .core.config import settings
from .core.firebase import initialize_firebase
from .core.limiter import limiter
from .routers import payments, inventory, ml, photos, brands, notifications

# Initialize Firebase Admin
initialize_firebase()

def create_app() -> FastAPI:
    app = FastAPI(title="Style With Us Backend", version="0.1.0")
    
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    allowed_origins = settings.allowed_origins.split(",")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(payments.router)
    app.include_router(inventory.router)
    app.include_router(ml.router)
    app.include_router(photos.router)
    app.include_router(brands.router)
    app.include_router(notifications.router)

    # serve uploaded files from /uploads
    upload_dir = os.path.abspath(os.path.join(os.getcwd(), 'uploads'))
    os.makedirs(upload_dir, exist_ok=True)
    app.mount('/uploads', StaticFiles(directory=upload_dir), name='uploads')

    @app.get("/health")
    async def health() -> dict:
        return {"status": "ok"}

    return app


app = create_app()

