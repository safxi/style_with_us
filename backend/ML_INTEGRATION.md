# ML Integration Guide

This document describes the ML models integrated into the Style With Us backend for personalized fashion recommendations.

## Overview

The backend now includes two main ML components:

### 1. **Skin Tone Classification** (`SkinToneClassifier`)
- **Library**: `skin-tone-classifier` (STONE)
- **Function**: Classifies user skin tones into predefined categories (e.g., warm, cool, neutral)
- **Output**: Skin tone category + confidence score
- **Purpose**: Enable color recommendations that complement user's natural coloring

### 2. **Body Shape Classification** (`BodyShapeClassification`)
- **Model**: ResNet50 (pre-trained on ImageNet)
- **Function**: Classifies body shapes into 7 categories
- **Output**: Body type + confidence score
- **Categories**: 
  - `pear` - Wider hips than shoulders
  - `apple` - Wider midsection
  - `hourglass` - Balanced curves
  - `rectangle` - Straight frame
  - `inverted` - Wider shoulders than hips
  - `diamond` - Wider midsection with full bust/hips
  - `oval` - Rounded overall shape
- **Purpose**: Recommend silhouettes and fits that flatter specific body types

## Installation

### 1. Install Dependencies

```bash
cd /home/saif/Desktop/saif\ fyp/backend
pip install -r requirements.txt
```

### 2. Key Dependencies

```
torch==2.0.1              # PyTorch for neural networks
torchvision==0.15.2       # Vision models (ResNet50)
skin-tone-classifier==1.4.0  # Skin tone classification
opencv-python==4.8.1.78   # Image processing
pillow==10.1.0            # Image handling
httpx==0.27.2             # HTTP requests for image downloads
```

## API Endpoints

### `/ml/analyze` (POST)

**Analyzes user image for body type and skin tone**

**Request:**
```json
{
  "user_id": 123,
  "image_url": "https://example.com/user-photo.jpg"
}
```

**Response:**
```json
{
  "analysis_id": "550e8400-e29b-41d4-a716-446655440000",
  "body_type": "pear",
  "body_confidence": 0.87,
  "skin_tone": "warm",
  "skin_confidence": 0.9,
  "created_at": "2024-02-26T10:30:00"
}
```

### `/ml/recommend` (POST)

**Get product recommendations based on analysis**

**Request:**
```json
{
  "user_id": 123,
  "analysis_id": "550e8400-e29b-41d4-a716-446655440000",
  "target_occasion": "casual",
  "limit": 20
}
```

**Response:**
```json
{
  "recommendation_id": "550e8400-e29b-41d4-a716-446655440001",
  "products": [
    {
      "product_id": 1,
      "brand_id": 1,
      "score": 0.92,
      "scores": {
        "body": 0.9,
        "color": 0.95,
        "occasion": 0.8,
        "brand": 0.6
      },
      "explanation": "A-line fitted blazer perfect for balanced silhouettes...",
      "rank": 1
    }
  ],
  "top_brands": [
    {
      "brand_id": 1,
      "brand_score": 0.92
    }
  ]
}
```

### `/ml/virtual-tryon` (POST)

**Generate virtual try-on preview** *(Placeholder - Implementation pending)*

**Request:**
```json
{
  "user_id": 123,
  "product_id": 456,
  "image_url": "https://example.com/user-photo.jpg"
}
```

**Response:**
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440002",
  "product_id": 456,
  "result_image_url": "https://example.com/virtual-tryon-result.jpg",
  "explanation": "Virtual try-on preview...",
  "created_at": "2024-02-26T10:35:00"
}
```

## File Structure

```
backend/
├── app/
│   ├── main.py           # FastAPI app initialization
│   ├── ml_utils.py       # ML utility functions
│   ├── schemas.py        # Pydantic request/response models
│   ├── config.py
│   ├── db.py
│   ├── models.py
│   └── routers/
│       └── ml.py         # ML endpoints
├── test_ml.py            # Test script
├── requirements.txt      # Python dependencies
└── ...
```

## Core Functionality

### `ml_utils.py` Functions

#### `download_image(image_url: str) -> PIL.Image`
- Downloads image from URL
- Converts to RGB
- Returns PIL Image object

#### `classify_skin_tone(image_url: str) -> (str, float)`
- Uses SkinToneClassifier library
- Detects face region
- Classifies dominant skin tone
- Returns (tone_name, confidence)

#### `classify_body_shape(image_url: str) -> (str, float)`
- Uses ResNet50 model
- Analyzes full body silhouette
- Returns (body_type, confidence)

#### `analyze_image(image_url: str) -> dict`
- Combines both classifications
- Returns comprehensive analysis result
- Includes error handling

## Model Details

### ResNet50 for Body Shape

The model uses ImageNet pre-trained weights and is fine-tuned for body shape classification.

**Architecture:**
- Input: 224×224 RGB images
- Backbone: ResNet50 (pre-trained)
- Output Layer: 7 neurons (one per body type)
- Device: Automatically uses GPU if available, falls back to CPU

**Performance:**
- Training time: Batches processed efficiently
- Inference: ~100-200ms per image on CPU, <50ms on GPU
- Confidence threshold: Scores above 0.7 are highly reliable

### SkinToneClassifier (STONE)

**Features:**
- Face detection using OpenCV
- Color clustering in HSV space
- Support for multiple tone palettes (PERLA, Yadon-Ostfeld, Proder)
- Handles various skin tones across different ethnicities

**Settings:**
- Default palette: PERLA (8-tone palette)
- Min face size: 90×90 pixels
- Detected faces min 15% skin coverage

## Error Handling

### Image Download Errors
- If image URL is invalid or unreachable, returns `None`
- Endpoint returns 422 error with message

### Model Loading Errors
- Gracefully handles missing dependencies
- Falls back to default values (rectangle body, neutral tone)
- Logs errors for debugging

### Processing Errors
- Validates image format
- Handles corrupted images
- Returns 500 error with meaningful message

## Performance Optimization

### Model Caching
- Models are loaded once and reused
- Global variables `_body_shape_model` and `_device`
- Reduces inference latency on subsequent requests

### Async Processing
- All endpoints are async-capable
- Image downloads use httpx async client
- Can handle concurrent requests

### Memory Management
- Images downloaded to memory (BytesIO)
- Temporary files cleaned up
- Model weights loaded once at startup

## Future Enhancements

### 1. Virtual Try-On (Currently Stubbed)
- Integrate VITON or StableDiffusion
- Realistic virtual try-on generation
- Support for different garment types

### 2. Advanced Recommendations
- Database integration for product catalog
- Machine learning scoring model
- User history and preferences

### 3. Real-time Style Tips
- Seasonal recommendations
- Occasion-based suggestions
- Color harmony analysis

### 4. Model Fine-tuning
- Custom training on fashion datasets
- Improved accuracy for specific populations
- Better confidence calibration

## Testing

### Run Test Script
```bash
cd /home/saif/Desktop/saif\ fyp/backend
python test_ml.py
```

### Test with API
```bash
# Start server
cd /home/saif/Desktop/saif\ fyp/backend
uvicorn app.main:app --reload --port 8000

# Test analyze endpoint
curl -X POST http://localhost:8000/ml/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "image_url": "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg"
  }'
```

## Troubleshooting

### Issue: ImportError for `stone` module
**Solution:** Install skin-tone-classifier
```bash
pip install skin-tone-classifier==1.4.0
```

### Issue: Slow inference
**Solution:** Install FFmpeg for faster image processing
```bash
# macOS
brew install ffmpeg

# Ubuntu
sudo apt-get install ffmpeg

# Windows
choco install ffmpeg
```

### Issue: OutOfMemory error
**Solution:** 
- Your GPU is running out of memory
- Switch to CPU-only mode (auto-detects)
- Or use smaller batch sizes

### Issue: Image download fails
**Solution:**
- Verify image URL is accessible
- Check internet connection
- Ensure URL returns valid image format

## References

- [SkinToneClassifier GitHub](https://github.com/ChenglongMa/SkinToneClassifier)
- [PyTorch ResNet Documentation](https://pytorch.org/vision/stable/models/resnet.html)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
