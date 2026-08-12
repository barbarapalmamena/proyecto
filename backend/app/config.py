import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Plataforma Colaborativa de Incidentes Urbanos - Puerto Montt"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Base de datos
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "sqlite:///./puertomontt.db"
    )
    
    # Seguridad JWT
    JWT_SECRET: str = os.getenv("JWT_SECRET", "puerto_montt_collaborative_secret_key_2026")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))
    
    # Centro geográfico de Puerto Montt por defecto
    PUERTO_MONTT_DEFAULT_LAT: float = -41.4693
    PUERTO_MONTT_DEFAULT_LON: float = -72.9424

    class Config:
        case_sensitive = True

settings = Settings()
