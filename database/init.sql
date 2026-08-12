-- Script de Inicialización de Base de Datos MySQL
-- Proyecto: Plataforma Colaborativa de Incidentes Urbanos - Puerto Montt

CREATE DATABASE IF NOT EXISTS capstone_puertomontt DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE capstone_puertomontt;

-- 1. Tabla de Usuarios
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('citizen', 'admin') DEFAULT 'citizen',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabla de Categorías de Incidentes
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon_name VARCHAR(50) DEFAULT 'warning',
    color_code VARCHAR(10) DEFAULT '#FF0000'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabla de Incidentes Urbanos
CREATE TABLE IF NOT EXISTS incidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    category_id INT NOT NULL,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address_reference VARCHAR(255),
    status ENUM('reported', 'in_progress', 'resolved', 'dismissed') DEFAULT 'reported',
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabla de Centrales de Emergencia Locales de Puerto Montt
CREATE TABLE IF NOT EXISTS emergency_contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    institution_name VARCHAR(100) NOT NULL,
    short_code VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(200),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    icon VARCHAR(50) DEFAULT 'phone'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabla de Alertas y Notificaciones Push Geoespaciales
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    radius_km DECIMAL(4, 2) DEFAULT 2.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- POBLADO DE DATOS SEMILLA (SEED DATA)
-- ==========================================

-- Insertar Categorías principales
INSERT INTO categories (id, name, description, icon_name, color_code) VALUES
(1, 'Accidente de Tránsito', 'Choques, colisiones o atropellos en vías públicas', 'car_crash', '#E53935'),
(2, 'Seguridad y Delitos', 'Robos, asaltos o actividad sospechosa', 'shield_alert', '#D81B60'),
(3, 'Mascotas Perdidas', 'Animales extraviados o en situación de riesgo', 'pets', '#8E24AA'),
(4, 'Falla de Infraestructura', 'Semáforos apagados, baches o alumbrado defectuoso', 'build', '#FB8C00'),
(5, 'Basura y Escombros', 'Acumulación ilegal de desperdicios o microbasurales', 'delete', '#43A047'),
(6, 'Emergencia Climática', 'Inundaciones, desprendimientos o caídas de árboles', 'cyclone', '#039BE5')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Insertar Contactos de Emergencia de Puerto Montt
INSERT INTO emergency_contacts (id, institution_name, short_code, phone_number, address, latitude, longitude, icon) VALUES
(1, 'Carabineros de Chile - 2da Comisaría Puerto Montt', '133', '133', 'Guillermo Gallardo 345, Puerto Montt', -41.470500, -72.941200, 'local_police'),
(2, 'Cuerpo de Bomberos de Puerto Montt', '132', '132', 'San Antonio 145, Puerto Montt', -41.468200, -72.939500, 'local_fire_department'),
(3, 'SAMU Puerto Montt - Atención Médica', '131', '131', 'Hospital Base Puerto Montt, Los Oledares', -41.455600, -72.923400, 'medical_services'),
(4, 'Seguridad Ciudadana Municipal Puerto Montt', '800 800 133', '+56652261000', 'San Martín 80, Puerto Montt', -41.472100, -72.943000, 'security'),
(5, 'Policía de Investigaciones (PDI)', '134', '134', 'Egaña 640, Puerto Montt', -41.467800, -72.935100, 'badge')
ON DUPLICATE KEY UPDATE institution_name=VALUES(institution_name);

-- Insertar Usuario Demostración
-- Contraseña en texto plano: 'puertomontt2026' (Hash bcrypt pregenerado)
INSERT INTO users (id, name, email, phone, password_hash, role) VALUES
(1, 'Bárbara Palma', 'barbara.palma@puertomontt.cl', '+56912345678', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'admin'),
(2, 'Renato Díaz', 'renato.diaz@puertomontt.cl', '+56987654321', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'citizen')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Insertar Incidentes Iniciales en la Comuna de Puerto Montt
INSERT INTO incidents (id, title, description, category_id, user_id, latitude, longitude, address_reference, status) VALUES
(1, 'Semáforo apagado en intersección crítica', 'El semáforo de Urmeneta con San Martín se encuentra completamente apagado generando congestión vehicular.', 4, 1, -41.472000, -72.942500, 'Urmeneta esq. San Martín, Centro', 'reported'),
(2, 'Accidente menor entre dos vehículos', 'Colisión por alcance cerca de la costanera. Tránsito lento hacia Pelluco.', 1, 2, -41.474500, -72.935000, 'Av. Diego Portales altura 800', 'in_progress'),
(3, 'Perro mestizo extraviado con collar azul', 'Se busca perro mestizo mediano de color café, visto por última vez en sector Angelmó.', 3, 1, -41.481000, -72.961000, 'Sector Feria Angelmó', 'reported'),
(4, 'Acumulación de escombros en vía pública', 'Gran cantidad de maderas y restos de construcción bloqueando paso peatonal.', 5, 2, -41.463000, -72.938000, 'Población Manuel Montt', 'resolved')
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Insertar Notificación Inicial
INSERT INTO notifications (id, incident_id, title, message, radius_km) VALUES
(1, 1, 'Precaución: Semáforo apagado en Centro', 'Se reporta semáforo apagado en Urmeneta / San Martín. Conduzca con precaución.', 1.50)
ON DUPLICATE KEY UPDATE title=VALUES(title);
