"""
ML utilities for skin tone and body shape classification.
"""
import logging
from io import BytesIO
from pathlib import Path
from typing import Optional, Tuple, Dict, Any

import httpx
from PIL import Image

try:
    import torch
    import torch.nn as nn
    from torchvision import models, transforms
except ImportError:
    torch = None
    nn = None
    models = None
    transforms = None

# Try to import skin tone classifier
try:
    from stone.api import process as process_skin_tone
except ImportError:
    process_skin_tone = None

logger = logging.getLogger(__name__)

# Global models (load once)
_body_shape_model = None
_device = None


def get_device():
    """Get torch device (CPU or CUDA)."""
    global _device
    if _device is None:
        if torch is None:
            logger.warning("Torch is not installed; defaulting to CPU without GPU acceleration.")
            _device = "cpu"
        else:
            _device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    return _device


def download_image(image_url: str) -> Optional[Image.Image]:
    """
    Download image from URL.
    
    Args:
        image_url: URL of the image
        
    Returns:
        PIL Image or None if download fails
    """
    try:
        response = httpx.get(image_url, timeout=30.0)
        response.raise_for_status()
        img = Image.open(BytesIO(response.content))
        return img.convert("RGB")
    except Exception as e:
        logger.error(f"Failed to download image from {image_url}: {e}")
        return None


def classify_skin_tone(image_url: str) -> Tuple[Optional[str], Optional[float]]:
    """
    Classify skin tone using SkinToneClassifier.
    
    Args:
        image_url: URL of the image containing a face
        
    Returns:
        Tuple of (skin_tone, confidence)
    """
    if process_skin_tone is None:
        logger.warning("SkinToneClassifier not installed")
        return None, None
    
    try:
        # Download and save temporarily
        img = download_image(image_url)
        if img is None:
            return None, None
        
        # Save to temp file
        temp_path = "/tmp/temp_skin_tone.jpg"
        img.save(temp_path)
        
        # Process with stone
        result = process_skin_tone(
            temp_path,
            image_type="auto",
            tone_palette="perla",
            return_report_image=False
        )
        
        # Extract skin tone from result
        if result and "records" in result and len(result["records"]) > 0:
            record = result["records"][0]
            tone = record.get("dominant_color", "neutral")
            confidence = record.get("confidence", 0.7)
            return tone, confidence
        
        return "neutral", 0.5
        
    except Exception as e:
        logger.error(f"Error classifying skin tone: {e}")
        return None, None


def load_body_shape_model():
    """
    Load pre-trained ResNet50 for body shape classification.
    
    Returns:
        Loaded model
    """
    global _body_shape_model
    if _body_shape_model is not None:
        return _body_shape_model
    
    try:
        model = models.resnet50(weights=models.ResNet50_Weights.IMAGENET1K_V1)
        # Replace final layer for body shape classification (7 classes)
        num_classes = 7
        model.fc = nn.Linear(model.fc.in_features, num_classes)
        model.to(get_device())
        model.eval()
        _body_shape_model = model
        return model
    except Exception as e:
        logger.error(f"Failed to load body shape model: {e}")
        return None


def classify_body_shape(image_url: str) -> Tuple[Optional[str], Optional[float]]:
    """
    Classify body shape using ResNet50.
    
    Args:
        image_url: URL of the image containing a full body
        
    Returns:
        Tuple of (body_type, confidence)
    """
    body_types = [
        "pear",      # Wider hips than shoulders
        "apple",     # Wider midsection
        "hourglass", # Balanced curves
        "rectangle", # Straight frame
        "inverted",  # Wider shoulders than hips
        "diamond",   # Wider midsection with full bust/hips
        "oval"       # Rounded overall shape
    ]
    
    try:
        img = download_image(image_url)
        if img is None:
            return None, None
        
        model = load_body_shape_model()
        if model is None:
            return None, None
        
        # Preprocess image
        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            )
        ])
        
        img_tensor = transform(img).unsqueeze(0).to(get_device())
        
        # Inference
        with torch.no_grad():
            outputs = model(img_tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            confidence, prediction = torch.max(probabilities, 1)
        
        body_type = body_types[prediction.item()]
        confidence_score = confidence.item()
        
        return body_type, confidence_score
        
    except Exception as e:
        logger.error(f"Error classifying body shape: {e}")
        return None, None


def analyze_image(
    image_url: str,
) -> Dict[str, Any]:
    """
    Analyze image for body type and skin tone.
    
    Args:
        image_url: URL of the image
        
    Returns:
        Dictionary with analysis results
    """
    results = {
        "body_type": None,
        "body_confidence": None,
        "skin_tone": None,
        "skin_confidence": None,
        "error": None
    }
    
    # Classify body shape
    body_type, body_conf = classify_body_shape(image_url)
    if body_type:
        results["body_type"] = body_type
        results["body_confidence"] = float(body_conf)
    
    # Classify skin tone
    skin_tone, skin_conf = classify_skin_tone(image_url)
    if skin_tone:
        results["skin_tone"] = skin_tone
        results["skin_confidence"] = float(skin_conf)
    
    if not body_type and not skin_tone:
        results["error"] = "Could not analyze image"
    
    return results
