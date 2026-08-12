import math

def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calcula la distancia de Haversine en kilómetros entre dos puntos dados en coordenadas de latitud y longitud.
    """
    R = 6371.0  # Radio de la Tierra en kilómetros

    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)

    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c

    return round(distance, 3)

def is_within_radius(center_lat: float, center_lon: float, target_lat: float, target_lon: float, radius_km: float) -> bool:
    """
    Determina si un punto objetivo se encuentra dentro de un radio en kilómetros a partir de un centro geográfico.
    """
    distance = calculate_haversine_distance(center_lat, center_lon, target_lat, target_lon)
    return distance <= radius_km
