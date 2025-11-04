"""User Pydantic schemas."""
from pydantic import BaseModel, EmailStr, ConfigDict
from datetime import datetime
from typing import Optional
from uuid import UUID


class UserBase(BaseModel):
    """Base user schema."""
    email: EmailStr
    username: str


class UserCreate(UserBase):
    """Schema for creating a user."""
    password: str


class UserUpdate(BaseModel):
    """Schema for updating a user."""
    username: Optional[str] = None


class UserResponse(UserBase):
    """Schema for user response."""
    id: UUID
    is_active: bool
    is_superuser: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
