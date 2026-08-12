# 🚨 Plataforma Colaborativa de Reportes Urbanos - Puerto Montt

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](docker-compose.yml)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](backend/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?logo=flutter&logoColor=white)](mobile/)

Plataforma tecnológica colaborativa compuesta por una aplicación móvil (Flutter) y una arquitectura backend basada en microservicios REST (Python/FastAPI) y base de datos relacional/geoespacial (MySQL) containerizada con Docker. Diseñada para la comuna de **Puerto Montt**, permite a la ciudadanía informar sobre incidentes urbanos geolocalizados en tiempo real y acceder directamente a los servicios de emergencia locales.

---

## 👥 Integrantes y Roles

| Integrante | Rol Principal | Responsabilidades |
| :--- | :--- | :--- |
| **Bárbara Palma** | **Líder Mobile, UX/UI & QA** | Prototipado en Figma, Desarrollo de App en Flutter, Mapa interactivo, Accesos a emergencias y Plan de pruebas de integración. |
| **Renato Díaz** | **Líder Backend, BD & DevOps** | Containerización Docker, Desarrollo de APIs en Python (FastAPI), Modelo de datos MySQL geoespacial, Notificaciones por radio geográfico y Pruebas de rendimiento. |

---

## 🎯 Objetivos del Proyecto

- **Objetivo General:** Desarrollar e implementar una plataforma tecnológica colaborativa para Puerto Montt que permita reportar incidentes urbanos geolocalizados en tiempo real y facilitar el acceso a centrales de emergencia locales.
- **Objetivo Específico 1:** Diseñar e implementar una interfaz móvil intuitiva en Flutter con categorías de incidentes y mapa urbano.
- **Objetivo Específico 2:** Desarrollar una arquitectura backend basada en APIs REST en Python capaz de procesar consultas geoespaciales y alertas push.
- **Objetivo Específico 3:** Construir un modelo de datos escalable en MySQL con perfiles de usuarios, historial, coordenadas y accesos a emergencias (Carabineros 133, Bomberos 132, SAMU 131, Seguridad Ciudadana).
- **Objetivo Específico 4:** Ejecutar un plan de pruebas unitarias, de integración y de rendimiento ante reportes simultáneos.

---

## 🛠️ Tecnologías Utilizadas

- **Frontend / Mobile:** Flutter / Dart
- **Backend APIs:** Python 3.11 / FastAPI / SQLAlchemy / Pydantic / PyJWT
- **Base de Datos:** MySQL 8.0 (con funciones geoespaciales Haversine)
- **Infraestructura:** Docker & Docker Compose
- **Metodología:** Kanban (Trello/Monday) + GitHub Feature Branch Workflow

---

## 📁 Estructura del Repositorio

```
Capstone/
├── docker-compose.yml       # Orquestación de MySQL y Backend FastAPI
├── .env.example             # Plantilla de variables de entorno
├── .gitignore               # Reglas de exclusión de git
├── README.md                # Documentación del proyecto
├── database/
│   └── init.sql             # Esquemas de tablas y seed data de Puerto Montt
├── backend/
│   ├── Dockerfile           # Imagen Docker para el backend Python
│   ├── requirements.txt     # Dependencias de Python
│   └── app/
│       ├── main.py          # Punto de entrada de FastAPI y CORS
│       ├── config.py        # Configuración de la app y JWT
│       ├── database.py      # Conexión SQLAlchemy a MySQL
│       ├── models.py        # Modelos relacionales ORM
│       ├── schemas.py       # Esquemas Pydantic
│       ├── routers/         # Endpoints (auth, incidents, emergency, notifications)
│       └── utils/           # Módulos de seguridad (bcrypt/JWT) y Haversine geoespacial
└── mobile/
    ├── pubspec.yaml         # Configuración y dependencias Flutter
    └── lib/
        ├── main.dart        # Navegación principal con BottomNavigationBar
        ├── models/          # Modelos Dart (Incident, EmergencyContact)
        ├── services/        # Consumo de API REST (http)
        └── screens/         # Pantallas Flutter (MapScreen, ReportScreen, EmergencyScreen)
```

---

## 🚀 Despliegue e Instrucciones de Ejecución Local

### Prerrequisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop) instalado y en ejecución.
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (para ejecutar la app móvil).

### 1. Clonar el repositorio e iniciar contenedores Docker
```bash
# Iniciar servicios de MySQL y Backend FastAPI en segundo plano
docker-compose up -d --build
```

### 2. Verificar estado de los servicios
- **Backend API Docs (Swagger):** [http://localhost:8000/docs](http://localhost:8000/docs)
- **Base de Datos MySQL:** Puerto `3306` (Usuario: `app_user`, Contraseña: `app_password`, Base: `capstone_puertomontt`)

### 3. Ejecutar la Aplicación Móvil en Android e iOS (Flutter)

```bash
cd mobile
flutter pub get
```

#### 🤖 En Android (Emulador o Dispositivo Físico)
1. Abre Android Studio o conecta tu celular Android con **Depuración USB** activada.
2. Ejecuta la app indicando el dispositivo Android:
   ```bash
   flutter run -d android
   ```
> **Nota de red**: El código incluye detección automática que redirige `localhost:8000` a `http://10.0.2.2:8000` para que el emulador Android acceda al backend local de Docker.

#### 🍏 En iOS (Simulador o Dispositivo Físico - Requiere macOS + Xcode)
1. Instala los Pods de CocoaPods (solo necesario la primera vez en Mac):
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Ejecuta el simulador de iOS o conecta tu iPhone:
   ```bash
   flutter run -d ios
   ```
   *O abre el proyecto en Xcode:* `open ios/Runner.xcworkspace`

#### 🌐 En Web (Prueba rápida en Navegador)
```bash
flutter run -d chrome
```

---

## 📑 Mapa de Endpoints Principales (API REST)

| Método | Endpoint | Descripción | Auth Requerido |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/register` | Registro de nuevos usuarios ciudadanos | No |
| `POST` | `/api/v1/auth/login` | Autenticación y obtención de Token JWT | No |
| `GET` | `/api/v1/incidents/categories` | Obtener categorías de incidentes urbanos | No |
| `GET` | `/api/v1/incidents/` | Consultar incidentes cercanos por radio geoespacial | No |
| `POST` | `/api/v1/incidents/` | Crear un nuevo reporte de incidente geolocalizado | **Sí (JWT)** |
| `GET` | `/api/v1/emergency/contacts` | Directorio de centrales de emergencia de Puerto Montt | No |
| `GET` | `/api/v1/notifications/` | Obtener notificaciones y alertas en tiempo real | No |

---

## 📌 Contactos de Emergencia Integrados (Puerto Montt)
- **Carabineros de Chile:** 133
- **Cuerpo de Bomberos:** 132
- **SAMU (Atención Médica):** 131
- **Seguridad Ciudadana Municipal:** 800 800 133 / +56 65 226 1000
- **Policía de Investigaciones (PDI):** 134
