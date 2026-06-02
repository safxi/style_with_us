from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "Style With Us Backend"
    environment: str = "dev"

    database_url: str = "postgresql+psycopg://user:password@localhost:5432/style_with_us"
    redis_url: str = "redis://localhost:6379/0"
    
    firebase_credentials_path: str = ""
    
    stripe_api_key: str = "sk_test_change_me"
    stripe_webhook_secret: str = "whsec_change_me"
    
    allowed_origins: str = "http://localhost:3000"
    secret_key: str = "supersecret_default_key"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"

settings = Settings()
