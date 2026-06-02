import os
import firebase_admin
from firebase_admin import credentials
import logging

logger = logging.getLogger(__name__)

def initialize_firebase():
    """
    Initializes the Firebase Admin SDK using a service account JSON file.
    The path is provided by the FIREBASE_CREDENTIALS_PATH environment variable.
    """
    if not firebase_admin._apps:
        cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
        try:
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase initialized with credentials file.")
            else:
                firebase_admin.initialize_app()
                logger.info("Firebase initialized with default credentials.")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
