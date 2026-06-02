FROM python:3.11-slim

WORKDIR /app

# Install system dependencies (for PostgreSQL, OpenCV, MediaPipe, and Image processing)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies (including ML environments)
COPY requirements.txt requirements-ml.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-ml.txt

# Copy source code
COPY . .

# Ensure the uploads directory exists for VTO images
RUN mkdir -p uploads

# Expose the API port
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
