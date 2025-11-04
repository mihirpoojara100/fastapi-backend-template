#!/usr/bin/env bash
set -euo pipefail

# Wait for database if DATABASE_URL is provided and points to Postgres
if [[ -n "${DATABASE_URL:-}" && "${DATABASE_URL}" == postgresql* ]]; then
  echo "Waiting for PostgreSQL to be ready..."
  python - <<'PY'
import os, time
import psycopg2
from urllib.parse import urlparse

url = urlparse(os.environ['DATABASE_URL'])
host, port = url.hostname, url.port or 5432
user, password, db = url.username, url.password, url.path.lstrip('/')

for i in range(30):
    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password, dbname=db)
        conn.close()
        print("PostgreSQL is up")
        break
    except Exception as e:
        print(f"Waiting for DB... ({i+1}/30): {e}")
        time.sleep(1)
else:
    raise SystemExit("Database not reachable after 30 seconds")
PY
fi

# Run migrations
if [ -f "alembic.ini" ]; then
  echo "Running Alembic migrations..."
  alembic upgrade head
fi

# Start the app
exec uvicorn app.main:app \
  --host "${HOST:-0.0.0.0}" \
  --port "${PORT:-8000}" \
  --workers "${UVICORN_WORKERS:-2}" \
  --log-level "${LOG_LEVEL:-info}"
