"""API routes."""
from fastapi import APIRouter
from app.routes import health, users

# Create main API router
api_router = APIRouter()

# Include route modules
api_router.include_router(health.router, tags=["health"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
