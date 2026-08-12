from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import EmergencyContact
from app.schemas import EmergencyContactResponse

router = APIRouter(prefix="/emergency", tags=["Centrales de Emergencia Locales"])

@router.get("/contacts", response_model=List[EmergencyContactResponse])
def get_emergency_contacts(db: Session = Depends(get_db)):
    """
    Retorna los accesos directos a las centrales de emergencia locales de Puerto Montt
    (Carabineros, Bomberos, SAMU, Seguridad Ciudadana y PDI).
    """
    contacts = db.query(EmergencyContact).all()
    results = []
    for c in contacts:
        results.append(
            EmergencyContactResponse(
                id=c.id,
                institution_name=c.institution_name,
                short_code=c.short_code,
                phone_number=c.phone_number,
                address=c.address,
                latitude=float(c.latitude) if c.latitude else None,
                longitude=float(c.longitude) if c.longitude else None,
                icon=c.icon
            )
        )
    return results
