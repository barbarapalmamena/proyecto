from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base
from app.routers import auth, incidents, emergency, notifications

# Crear tablas y poblar datos iniciales si no existen
Base.metadata.create_all(bind=engine)

def seed_initial_data():
    from app.database import SessionLocal
    from app.models import Category, EmergencyContact, User, Incident, UserRole
    db = SessionLocal()
    try:
        if db.query(Category).count() == 0:
            categories = [
                Category(id=1, name="Accidente de Tránsito", description="Choques, colisiones o atropellos", icon_name="car_crash", color_code="#E53935"),
                Category(id=2, name="Seguridad y Delitos", description="Robos, asaltos o actividad sospechosa", icon_name="shield_alert", color_code="#D81B60"),
                Category(id=3, name="Mascotas Perdidas", description="Animales extraviados o en riesgo", icon_name="pets", color_code="#8E24AA"),
                Category(id=4, name="Falla de Infraestructura", description="Semáforos apagados, baches", icon_name="build", color_code="#FB8C00"),
                Category(id=5, name="Basura y Escombros", description="Acumulación de desperdicios", icon_name="delete", color_code="#43A047"),
                Category(id=6, name="Emergencia Climática", description="Inundaciones o caídas de árboles", icon_name="cyclone", color_code="#039BE5"),
            ]
            db.add_all(categories)
            db.commit()

        if db.query(EmergencyContact).count() == 0:
            contacts = [
                EmergencyContact(id=1, institution_name="Carabineros de Chile - 2da Comisaría", short_code="133", phone_number="133", address="Guillermo Gallardo 345, Puerto Montt", latitude=-41.4705, longitude=-72.9412, icon="local_police"),
                EmergencyContact(id=2, institution_name="Cuerpo de Bomberos de Puerto Montt", short_code="132", phone_number="132", address="San Antonio 145, Puerto Montt", latitude=-41.4682, longitude=-72.9395, icon="local_fire_department"),
                EmergencyContact(id=3, institution_name="SAMU Puerto Montt - Atención Médica", short_code="131", phone_number="131", address="Hospital Base Puerto Montt", latitude=-41.4556, longitude=-72.9234, icon="medical_services"),
                EmergencyContact(id=4, institution_name="Seguridad Ciudadana Municipal", short_code="800 800 133", phone_number="+56652261000", address="San Martín 80, Puerto Montt", latitude=-41.4721, longitude=-72.9430, icon="security"),
                EmergencyContact(id=5, institution_name="Policía de Investigaciones (PDI)", short_code="134", phone_number="134", address="Egaña 640, Puerto Montt", latitude=-41.4678, longitude=-72.9351, icon="badge"),
            ]
            db.add_all(contacts)
            db.commit()

        if db.query(User).count() == 0:
            from app.utils.security import get_password_hash
            u1 = User(id=1, name="Bárbara Palma", email="barbara.palma@puertomontt.cl", phone="+56912345678", password_hash=get_password_hash("puertomontt2026"), role=UserRole.admin)
            u2 = User(id=2, name="Renato Díaz", email="renato.diaz@puertomontt.cl", phone="+56987654321", password_hash=get_password_hash("puertomontt2026"), role=UserRole.citizen)
            db.add_all([u1, u2])
            db.commit()

        if db.query(Incident).count() == 0:
            inc1 = Incident(id=1, title="Semáforo apagado en intersección crítica", description="Semáforo de Urmeneta con San Martín apagado.", category_id=4, user_id=1, latitude=-41.4720, longitude=-72.9425, address_reference="Urmeneta esq. San Martín, Centro", status="reported")
            inc2 = Incident(id=2, title="Accidente menor entre dos vehículos", description="Colisión por alcance cerca de la costanera.", category_id=1, user_id=2, latitude=-41.4745, longitude=-72.9350, address_reference="Av. Diego Portales altura 800", status="in_progress")
            inc3 = Incident(id=3, title="Perro mestizo extraviado con collar azul", description="Perro mestizo café visto en Angelmó.", category_id=3, user_id=1, latitude=-41.4810, longitude=-72.9610, address_reference="Sector Feria Angelmó", status="reported")
            db.add_all([inc1, inc2, inc3])
            db.commit()
    finally:
        db.close()

seed_initial_data()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API REST de la plataforma colaborativa de reportes urbanos y emergencias para la comuna de Puerto Montt.",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configuración de CORS para permitir peticiones desde aplicaciones Flutter (móviles y web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir Routers de la API v1
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(incidents.router, prefix=settings.API_V1_STR)
app.include_router(emergency.router, prefix=settings.API_V1_STR)
app.include_router(notifications.router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "status": "online",
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "location": "Puerto Montt, Chile",
        "docs": "/docs"
    }
