import os
import firebase_admin
from firebase_admin import credentials, auth


import logging


def init_firebase():
    """Initialize Firebase Admin SDK if a service account file is available.

    The path may be provided via the FIREBASE_CREDENTIAL env var or defaults to
    './firebase-service-account.json'.  In development it's fine to run without
    credentials; verification calls will then raise when first used.
    """
    if firebase_admin._apps:
        return

    cred_path = os.getenv("FIREBASE_CREDENTIAL", "./firebase-service-account.json")
    if not os.path.exists(cred_path):
        logging.warning("Firebase credential file not found; authentication will fail until provided: %s", cred_path)
        return
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    except Exception as exc:
        logging.exception("Failed to initialize Firebase Admin SDK")
        raise


# convenience re-export
verify_id_token = auth.verify_id_token
get_user = auth.get_user
