from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Notification, Incident
from app.schemas import NotificationResponse
from app.utils.geo import calculate_haversine_distance

router = APIRouter(prefix="/notifications", tags=["Alertas Push y Notificaciones"])

@router.get("/", response_model=List[NotificationResponse])
def get_nearby_notifications(
    latitude: float = Query(-41.4693, description="Latitud actual del usuario en Puerto Montt"),
    longitude: float = Query(-72.9424, description="Longitud actual del usuario en Puerto Montt"),
    user_radius_km: float = Query(5.0, description="Radio máximo de alertas para el usuario"),
    db: Session = Depends(get_db)
):
    """
    Retorna las alertas y notificaciones push activas que corresponden a la ubicación actual del usuario.
    """
    notifications = db.query(Notification).join(Incident).order_by(Notification.created_at.desc()).all()
    results = []

    for notif in notifications:
        inc = notif.incident
        if inc:
            dist = calculate_haversine_distance(latitude, longitude, float(inc.latitude), float(inc.longitude))
            # Si el incidente está dentro del radio de la notificación y del radio elegido por el usuario
            if dist <= float(notif.radius_km) or dist <= user_radius_km:
                results.append(notif)

    return results
