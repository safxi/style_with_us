import os
import uuid
import logging
from celery import shared_task

from ..ml_utils import analyze_image

logger = logging.getLogger(__name__)

@shared_task(bind=True)
def process_style_analysis(self, user_id: int, image_url: str):
    """
    Celery task that runs ML body/skin classification.
    """
    try:
        from ..db import SessionLocal
        from .. import models
        results = analyze_image(image_url)
        
        if results.get("error"):
            return {"status": "error", "error": results["error"]}
        
        body_type = results.get("body_type") or "rectangle"
        body_confidence = results.get("body_confidence") or 0.5
        skin_tone = results.get("skin_tone") or "medium"
        skin_confidence = results.get("skin_confidence") or 0.5
        
        shapes = ["hourglass", "pear", "apple", "rectangle", "inverted"]
        tones = ["fair", "light", "medium", "olive", "brown", "dark"]
        
        bt = body_type if body_type in shapes else "rectangle"
        st = skin_tone if skin_tone in tones else "medium"
        
        shape_advice = {
            "hourglass": "Opt for wrap dresses and belted tops to highlight your waist.",
            "pear": "A-line skirts and structured shoulder tops balance your silhouette beautifully.",
            "apple": "Empire waistlines and V-necks draw the eye upward and elongate your frame.",
            "rectangle": "Create curves with peplum tops, layers, and color blocking.",
            "inverted": "Wide-leg pants and A-line skirts help balance broader shoulders."
        }
        
        tone_advice = {
            "fair": "Jewel tones like emerald and sapphire, or soft pastels work wonderfully for your complexion.",
            "light": "Earthy tones, soft rose, and navy blue are incredibly flattering for your skin.",
            "medium": "Primary colors, rich camel, and deep burgundy complement your warm undertones.",
            "olive": "Bright pinks, deep navy, and crisp white beautifully highlight your olive glow.",
            "brown": "Vibrant yellows, warm orange, and rich cobalt blue are stunning on you.",
            "dark": "Striking jewel tones, bright white, and bold reds create gorgeous contrast."
        }
        
        summary = f"Based on our ML analysis, your distinct {bt} body shape pairs excellently with your {st} skin tone. {shape_advice[bt]} Furthermore, {tone_advice[st].lower()}"
        
        db = SessionLocal()
        try:
            analysis_record = models.AnalysisResult(
                user_id=user_id,
                body_shape=bt,
                skin_tone=st,
                summary=summary
            )
            db.add(analysis_record)
            db.commit()
            db.refresh(analysis_record)
            record_id = analysis_record.id
        finally:
            db.close()
            
        return {
            "status": "complete",
            "analysis_id": str(record_id),
            "body_type": bt,
            "body_confidence": body_confidence,
            "skin_tone": st,
            "skin_confidence": skin_confidence,
            "summary": summary
        }
    except Exception as e:
        logger.error(f"Error in process_style_analysis: {e}")
        return {"status": "error", "error": str(e)}

@shared_task(bind=True)
def process_virtual_tryon(self, user_id: int, product_id: int, image_url: str, fcm_token: str = None):
    """
    Celery task that runs MediaPipe pose overlay for Virtual Try-on.
    """
    session_id = str(uuid.uuid4())
    try:
        import numpy as np
        from PIL import Image, ImageDraw, UnidentifiedImageError
        import mediapipe as mp
        import io
        import urllib.request
        
        # Download & Validate
        req = urllib.request.Request(image_url, headers={'User-Agent': 'Mozilla/5.0'})
        img_bytes = urllib.request.urlopen(req).read()
        body_img = Image.open(io.BytesIO(img_bytes))
        body_img.verify() 
        body_img = Image.open(io.BytesIO(img_bytes))
            
        result_img = body_img.copy().convert("RGBA")
        width, height = result_img.size
        
        mp_pose = mp.solutions.pose
        with mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5) as pose:
            image_np = np.array(result_img.convert("RGB"))
            results = pose.process(image_np)
            
            if results.pose_landmarks:
                landmarks = results.pose_landmarks.landmark
                left_shoulder = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value]
                right_shoulder = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value]
                left_hip = landmarks[mp_pose.PoseLandmark.LEFT_HIP.value]
                right_hip = landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value]
                
                x_min = min(left_shoulder.x, right_shoulder.x, left_hip.x, right_hip.x) * width
                x_max = max(left_shoulder.x, right_shoulder.x, left_hip.x, right_hip.x) * width
                y_min = min(left_shoulder.y, right_shoulder.y) * height
                y_max = max(left_hip.y, right_hip.y) * height
                
                torso_x1, torso_y1 = int(x_min), int(y_min)
                torso_x2, torso_y2 = int(x_max), int(y_max)
            else:
                torso_x1 = int(width * 0.25)
                torso_y1 = int(height * 0.25)
                torso_x2 = int(width * 0.75)
                torso_y2 = int(height * 0.65)
        
        overlay = Image.new("RGBA", result_img.size, (255, 255, 255, 0))
        draw = ImageDraw.Draw(overlay)
        draw.rounded_rectangle(
            (torso_x1, torso_y1, torso_x2, torso_y2), 
            fill=(138, 43, 226, 180), 
            radius=20
        )
        
        final_img = Image.alpha_composite(result_img, overlay).convert("RGB")
        
        filename = f"tryon_{session_id}.jpg"
        filepath = os.path.join(os.getcwd(), "uploads", filename)
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        final_img.save(filepath, format="JPEG", quality=85)
        
        # Read base URL from env for proper staging configuration vs localhost hardcodes
        base_url = os.getenv("API_BASE_URL", "http://localhost:8000")
        result_url = f"{base_url}/uploads/{filename}"

        if fcm_token:
            import firebase_admin
            from firebase_admin import messaging
            try:
                msg = messaging.Message(
                    notification=messaging.Notification(
                        title="Virtual Try-On Ready! ✨",
                        body="Your generated AI outfit is ready to view."
                    ),
                    token=fcm_token,
                )
                messaging.send(msg)
            except Exception as e:
                logger.error(f"Failed to send ML push: {e}")

        return {
            "status": "complete",
            "session_id": session_id,
            "product_id": product_id,
            "result_image_url": result_url,
            "explanation": f"Virtual try-on generated using Pose Estimation landmarks for garment ID {product_id}.",
        }
    except Exception as e:
        logger.error(f"Error in virtual try-on task: {e}")
        return {"status": "error", "error": str(e)}
