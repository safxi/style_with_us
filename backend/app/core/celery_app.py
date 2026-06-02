import os
from celery import Celery

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

# Initialize Celery connected to Redis
celery_app = Celery(
    "style_tasks",
    broker=REDIS_URL,
    backend=REDIS_URL,
    include=["app.tasks.ml_tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    result_expires=3600, # Expire results after 1 hour
)
