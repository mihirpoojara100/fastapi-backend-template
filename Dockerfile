FROM python:3.12-slim

# System settings for Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies (psycopg2 and runtime libs)
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -ms /bin/bash appuser

# Set workdir
WORKDIR /app

# Copy requirements separately for better caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Ensure alembic config is present
ENV ALEMBIC_CONFIG=/app/alembic.ini

# Runtime environment variables (override in deploy as needed)
ENV HOST=0.0.0.0 \
    PORT=8000 \
    UVICORN_WORKERS=2 \
    LOG_LEVEL=info

# Add entrypoint
RUN chmod +x docker/entrypoint.sh || true

# Change user
USER appuser

EXPOSE 8000

ENTRYPOINT ["/bin/bash", "docker/entrypoint.sh"]
