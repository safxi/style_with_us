#!/bin/bash
# Setup script for Style With Us Backend

echo "================================================"
echo "Style With Us - Backend Setup"
echo "================================================"
echo ""

# Install base requirements
echo "Step 1: Installing base dependencies..."
pip3 install --break-system-packages -q fastapi uvicorn sqlalchemy pydantic httpx firebase-admin
echo "✓ Base dependencies installed"
echo ""

# Optional: Install ML dependencies
echo "Step 2: ML Dependencies (Optional)"
echo "To use ML features (body shape & skin tone classification):"
echo ""
echo "Option A - System packages (larger download, may take time):"
echo "  pip3 install --break-system-packages -r requirements-ml.txt"
echo ""
echo "Option B - Lighter ML setup (CPU only, no GPU):"
echo "  pip3 install --break-system-packages -q opencv-python pillow requests"
echo "  pip3 install --break-system-packages -q skin-tone-classifier"
echo ""
echo "Option C - Skip ML for now and test API endpoints first"
echo ""

# Check Python version
echo "Step 3: Verifying setup..."
python3 -c "import fastapi; print(f'✓ FastAPI {fastapi.__version__} installed')" 2>/dev/null || echo "⚠ FastAPI not yet installed"

echo ""
echo "================================================"
echo "Next steps:"
echo "================================================"
echo ""
echo "1. Start the backend server:"
echo "   cd /home/saif/Desktop/saif\\ fyp/backend"
echo "   uvicorn app.main:app --reload --port 8000"
echo ""
echo "2. Test an endpoint:"
echo "   curl http://localhost:8000/health"
echo ""
echo "3. To enable ML features, install ML dependencies:"
echo "   pip3 install --break-system-packages -r requirements-ml.txt"
echo ""
echo "4. View full documentation:"
echo "   cat ML_INTEGRATION.md"
echo ""
