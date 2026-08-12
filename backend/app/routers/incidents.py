from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models import Incident, Category, User, IncidentStatus, Notification
from app.schemas import IncidentCreate, IncidentResponse, IncidentStatusUpdate, CategoryResponse
from app.utils.security import get_current_user
from app.utils.geo import calculate_haversine_distance
from app.config import settings

router = APIRouter(prefix="/incidents", tags=["Incidentes Urbanos"])

@router.get("/categories", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()

@router.get("/", response_model=List[IncidentResponse])
def get_incidents(
    latitude: Optional[float] = Query(None, description="Latitud para filtrar por cercanía"),
    longitude: Optional[float] = Query(None, description="Longitud para filtrar por cercanía"),
    radius_km: Optional[float] = Query(5.0, description="Radio de búsqueda en kilómetros"),
    category_id: Optional[int] = Query(None, description="Filtrar por categoría"),
    status_filter: Optional[IncidentStatus] = Query(None, description="Filtrar por estado del incidente"),
    db: Session = Depends(get_db)
):
    query = db.query(Incident)

    if category_id:
        query = query.filter(Incident.category_id == category_id)
    if status_filter:
        query = query.filter(Incident.status == status_filter)

    incidents = query.order_by(Incident.created_at.desc()).all()
    results = []

    for inc in incidents:
        inc_lat = float(inc.latitude)
        inc_lon = float(inc.longitude)

        dist = None
        if latitude is not None and longitude is not None:
            dist = calculate_haversine_distance(latitude, longitude, inc_lat, inc_lon)
            if radius_km and dist > radius_km:
                continue

        resp = IncidentResponse(
            id=inc.id,
            title=inc.title,
            description=inc.description,
            category_id=inc.category_id,
            category=CategoryResponse.from_orm(inc.category),
            user_id=inc.user_id,
            user_name=inc.user.name if inc.user else "Anonimo",
            latitude=inc_lat,
            longitude=inc_lon,
            address_reference=inc.address_reference,
            status=inc.status,
            image_url=inc.image_url,
            distance_km=dist,
            created_at=inc.created_at,
            updated_at=inc.updated_at
        )
        results.append(resp)

    return results

@router.post("/", response_model=IncidentResponse, status_code=status.HTTP_201_CREATED)
def create_incident(
    incident_data: IncidentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    category = db.query(Category).filter(Category.id == incident_data.category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="La categoría especificada no existe.")

    new_incident = Incident(
        title=incident_data.title,
        description=incident_data.description,
        category_id=incident_data.category_id,
        user_id=current_user.id,
        latitude=incident_data.latitude,
        longitude=incident_data.longitude,
        address_reference=incident_data.address_reference,
        status=IncidentStatus.reported,
        image_url=incident_data.image_url
    )
    db.add(new_incident)
    db.commit()
    db.refresh(new_incident)

    auto_notif = Notification(
        incident_id=new_incident.id,
        title=f"Nuevo incidente: {new_incident.title}",
        message=f"Reportado en {new_incident.address_reference or 'Puerto Montt'}: {new_incident.description[:100]}...",
        radius_km=2.0
    )
    db.add(auto_notif)
    db.commit()

    return IncidentResponse(
        id=new_incident.id,
        title=new_incident.title,
        description=new_incident.description,
        category_id=new_incident.category_id,
        category=CategoryResponse.from_orm(category),
        user_id=current_user.id,
        user_name=current_user.name,
        latitude=float(new_incident.latitude),
        longitude=float(new_incident.longitude),
        address_reference=new_incident.address_reference,
        status=new_incident.status,
        image_url=new_incident.image_url,
        distance_km=0.0,
        created_at=new_incident.created_at,
        updated_at=new_incident.updated_at
    )

@router.get("/{incident_id}", response_model=IncidentResponse)
def get_incident_by_id(incident_id: int, db: Session = Depends(get_db)):
    inc = db.query(Incident).filter(Incident.id == incident_id).first()
    if not inc:
        raise HTTPException(status_code=404, detail="Incidente no encontrado.")
    return IncidentResponse(
        id=inc.id,
        title=inc.title,
        description=inc.description,
        category_id=inc.category_id,
        category=CategoryResponse.from_orm(inc.category),
        user_id=inc.user_id,
        user_name=inc.user.name if inc.user else "Anonimo",
        latitude=float(inc.latitude),
        longitude=float(inc.longitude),
        address_reference=inc.address_reference,
        status=inc.status,
        image_url=inc.image_url,
        created_at=inc.created_at,
        updated_at=inc.updated_at
    )

@router.patch("/{incident_id}/status", response_model=IncidentResponse)
def update_incident_status(
    incident_id: int,
    status_data: IncidentStatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    inc = db.query(Incident).filter(Incident.id == incident_id).first()
    if not inc:
        raise HTTPException(status_code=404, detail="Incidente no encontrado.")

    inc.status = status_data.status
    db.commit()
    db.refresh(inc)

    return IncidentResponse(
        id=inc.id,
        title=inc.title,
        description=inc.description,
        category_id=inc.category_id,
        category=CategoryResponse.from_orm(inc.category),
        user_id=inc.user_id,
        user_name=inc.user.name if inc.user else "Anonimo",
        latitude=float(inc.latitude),
        longitude=float(inc.longitude),
        address_reference=inc.address_reference,
        status=inc.status,
        image_url=inc.image_url,
        created_at=inc.created_at,
        updated_at=inc.updated_at
    )
