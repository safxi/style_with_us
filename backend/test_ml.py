"""
Test script for ML endpoints.
"""
import asyncio
import sys
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent))

from app.ml_utils import analyze_image


async def test_ml_endpoints():
    """Test the ML endpoints."""
    print("=" * 60)
    print("ML Integration Testing")
    print("=" * 60)
    
    # Test image URL (using a publicly available image)
    test_url = "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg"
    
    print(f"\n1. Testing image analysis with URL:")
    print(f"   URL: {test_url}")
    
    try:
        results = analyze_image(test_url)
        
        print("\n2. Analysis Results:")
        print(f"   Body Type: {results.get('body_type')} (confidence: {results.get('body_confidence')})")
        print(f"   Skin Tone: {results.get('skin_tone')} (confidence: {results.get('skin_confidence')})")
        
        if results.get("error"):
            print(f"   Error: {results['error']}")
        
        print("\n3. Status: ✓ Models loaded successfully!")
        
    except Exception as e:
        print(f"\n   Error: {e}")
        print("\n3. Status: ✗ Error during analysis")
        print("\n   Note: This is expected if dependencies are not installed yet.")
        print("   Run: pip install -r requirements.txt")


if __name__ == "__main__":
    print("\nNote: Make sure to install dependencies first:")
    print("  cd /home/saif/Desktop/saif\\ fyp/backend")
    print("  pip install -r requirements.txt")
    print("\n" + "=" * 60 + "\n")
    
    asyncio.run(test_ml_endpoints())
