from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Style With Us Backend"
    environment: str = "dev"

    # Database
    database_url: str = "postgresql+psycopg://user:password@localhost:5432/style_with_us"

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # Stripe / Razorpay
    stripe_api_key: str = "sk_test_change_me"
    stripe_webhook_secret: str = "whsec_change_me"
    razorpay_key_id: str = "rzp_test_change_me"
    razorpay_key_secret: str = "rzp_secret_change_me"

    # Firebase
    firebase_project_id: str | None = None

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()

