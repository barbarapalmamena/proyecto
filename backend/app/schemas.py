from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from app.models import UserRole, IncidentStatus

# Auth & User Schemas
class UserRegister(BaseModel):
    name: str = Field(..., example="Bárbara Palma")
    email: EmailStr = Field(..., example="barbara.palma@puertomontt.cl")
    phone: Optional[str] = Field(None, example="+56912345678")
    password: str = Field(..., min_length=6, example="puertomontt2026")

class UserLogin(BaseModel):
    email: EmailStr = Field(..., example="barbara.palma@puertomontt.cl")
    password: str = Field(..., example="puertomontt2026")

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    phone: Optional[str]
    role: UserRole
    created_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

# Category Schemas
class CategoryResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    icon_name: str
    color_code: str

    class Config:
        from_attributes = True

# Incident Schemas
class IncidentCreate(BaseModel):
    title: str = Field(..., min_length=5, max_length=150, example="Semáforo apagado en intersección crítica")
    description: str = Field(..., min_length=10, example="El semáforo de Urmeneta con San Martín se encuentra apagado.")
    category_id: int = Field(..., example=4)
    latitude: float = Field(..., example=-41.472000)
    longitude: float = Field(..., example=-72.942500)
    address_reference: Optional[str] = Field(None, example="Urmeneta esq. San Martín, Centro")
    image_url: Optional[str] = Field(None, example="https://example.com/incident.jpg")

class IncidentStatusUpdate(BaseModel):
    status: IncidentStatus

class IncidentResponse(BaseModel):
    id: int
    title: str
    description: str
    category_id: int
    category: CategoryResponse
    user_id: int
    user_name: Optional[str] = None
    latitude: float
    longitude: float
    address_reference: Optional[str]
    status: IncidentStatus
    image_url: Optional[str]
    distance_km: Optional[float] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Emergency Contact Schemas
class EmergencyContactResponse(BaseModel):
    id: int
    institution_name: str
    short_code: str
    phone_number: str
    address: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    icon: str

    class Config:
        from_attributes = True

# Notification & Geospatial Alert Schemas
class AlertRadiusQuery(BaseModel):
    latitude: float = Field(..., example=-41.4693)
    longitude: float = Field(..., example=-72.9424)
    radius_km: float = Field(2.0, example=2.5)

class NotificationResponse(BaseModel):
    id: int
    incident_id: int
    title: str
    message: str
    radius_km: float
    created_at: datetime

    class Config:
        from_attributes = True
