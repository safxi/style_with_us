FROM python:3.11-slim

WORKDIR /app

# Install system dependencies (for PostgreSQL, OpenCV, MediaPipe, and Image processing)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements files first to leverage Docker caching
COPY requirements.txt requirements-ml.txt ./

# Step 1: Install core backend dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Step 2: Install CPU-only PyTorch (avoids CUDA bloat on CPU-only EC2 instances)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Step 3: Install remaining ML dependencies
RUN pip install --no-cache-dir -r requirements-ml.txt

# Copy source code
COPY . .

# Ensure the uploads directory exists for VTO images
RUN mkdir -p uploads

# Expose the API port
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
