# FastAPI Backend Template

A production-ready, modular FastAPI template using SQLAlchemy 2.0, Alembic, and Pydantic v2. Includes PostgreSQL setup, environment-based settings, and Docker support.

## Features

- Modular app layout: routes, models, schemas, services-ready
- PostgreSQL via SQLAlchemy 2.0 and session dependency
- Alembic migrations pre-wired to models metadata
- Pydantic v2 settings with flexible CORS config parsing
- Health endpoints and example User CRUD
- Password hashing with bcrypt
- CORS middleware and sensible defaults
- Dockerfile and entrypoint to run migrations before app

## Project structure

```
fast-api-backend-structure/
├── alembic/              # Alembic migration environment
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
├── app/
│   ├── main.py           # FastAPI app factory
│   ├── database.py       # SQLAlchemy engine/session + Base
│   ├── models/           # ORM models
│   │   └── user.py
│   ├── routes/           # API routers (functional)
│   │   ├── health.py
│   │   └── users.py
│   └── schemas/          # Pydantic schemas
│       └── user.py
├── settings.py           # Pydantic Settings (v2)
├── alembic.ini           # Alembic config
├── requirements.txt
├── run.py                # Local runner (uvicorn)
├── docker/entrypoint.sh  # Wait DB, run migrations, start app
├── Dockerfile
├── .dockerignore
├── env.example           # Copy to .env and edit
└── README.md
```

## Requirements

- Python 3.12+
- PostgreSQL 13+

## Setup (local)

1. Create and activate a virtual environment

```bash
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\\Scripts\\activate  # Windows PowerShell
```

2. Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

3. Configure environment

```bash
cp env.example .env
# Edit .env (DATABASE_URL, SECRET_KEY, etc.)
```

4. Create initial migration and apply

```bash
alembic revision --autogenerate -m "Initial tables"
alembic upgrade head
```

5. Run the app

```bash
python run.py
# or: uvicorn app.main:app --reload
```

- API: `http://localhost:8000`
- Docs: `http://localhost:8000/docs`

## Docker

Build image:

```bash
docker build -t fastapi-backend:latest .
```

Run container (requires `.env`):

```bash
docker run --env-file ./.env -p 8000:8000 fastapi-backend:latest
```

The entrypoint will:

- Wait for PostgreSQL (when `DATABASE_URL` is postgresql://...)
- Apply Alembic migrations (`alembic upgrade head`)
- Start Uvicorn

Environment overrides:

- `HOST` (default `0.0.0.0`)
- `PORT` (default `8000`)
- `UVICORN_WORKERS` (default `2`)
- `LOG_LEVEL` (default `info`)

## Configuration

Managed via `settings.py` (Pydantic v2):

- `DATABASE_URL`: e.g. `postgresql://user:pass@host:5432/db`
- `SECRET_KEY`, `ALGORITHM`, `ACCESS_TOKEN_EXPIRE_MINUTES`
- `CORS_ORIGINS`: supports JSON array or comma-separated string
  - Examples:
    - `CORS_ORIGINS=["http://localhost:3000","http://localhost:8000"]`
    - `CORS_ORIGINS=http://localhost:3000,http://localhost:8000`

Note: This template uses Pydantic v2 validators (`@field_validator`).

## Database model changes

- Update models in `app/models/`
- Generate migration: `alembic revision --autogenerate -m "<message>"`
- Apply: `alembic upgrade head`

## Example requests

Create user:

```bash
curl -X POST http://localhost:8000/api/v1/users/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","username":"user","password":"secret"}'
```

List users:

```bash
curl http://localhost:8000/api/v1/users/
```

Health:

```bash
curl http://localhost:8000/api/v1/health
```

## Production notes

- Use a proper `SECRET_KEY` and configure allowed `CORS_ORIGINS`
- Set `UVICORN_WORKERS` according to CPU cores (e.g., 2–4)
- Use a process manager or container orchestration (Docker/K8s)
- Configure database connection pool sizes as needed in `app/database.py`
- Add observability (logs/metrics/traces) per your stack

## License

MIT
