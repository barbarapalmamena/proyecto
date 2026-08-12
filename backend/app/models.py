from sqlalchemy import Column, Integer, String, Text, Numeric, Enum, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
import enum
from app.database import Base

class UserRole(str, enum.Enum):
    citizen = "citizen"
    admin = "admin"

class IncidentStatus(str, enum.Enum):
    reported = "reported"
    in_progress = "in_progress"
    resolved = "resolved"
    dismissed = "dismissed"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(120), unique=True, nullable=False, index=True)
    phone = Column(String(20), nullable=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(Enum(UserRole), default=UserRole.citizen)
    created_at = Column(DateTime, server_default=func.now())

    incidents = relationship("Incident", back_populates="user")

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    icon_name = Column(String(50), default="warning")
    color_code = Column(String(10), default="#FF0000")

    incidents = relationship("Incident", back_populates="category")

class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    latitude = Column(Numeric(10, 8), nullable=False)
    longitude = Column(Numeric(11, 8), nullable=False)
    address_reference = Column(String(255), nullable=True)
    status = Column(Enum(IncidentStatus), default=IncidentStatus.reported)
    image_url = Column(String(255), nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    category = relationship("Category", back_populates="incidents")
    user = relationship("User", back_populates="incidents")
    notifications = relationship("Notification", back_populates="incident")

class EmergencyContact(Base):
    __tablename__ = "emergency_contacts"

    id = Column(Integer, primary_key=True, index=True)
    institution_name = Column(String(100), nullable=False)
    short_code = Column(String(10), nullable=False)
    phone_number = Column(String(20), nullable=False)
    address = Column(String(200), nullable=True)
    latitude = Column(Numeric(10, 8), nullable=True)
    longitude = Column(Numeric(11, 8), nullable=True)
    icon = Column(String(50), default="phone")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    incident_id = Column(Integer, ForeignKey("incidents.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(150), nullable=False)
    message = Column(Text, nullable=False)
    radius_km = Column(Numeric(4, 2), default=2.00)
    created_at = Column(DateTime, server_default=func.now())

    incident = relationship("Incident", back_populates="notifications")
