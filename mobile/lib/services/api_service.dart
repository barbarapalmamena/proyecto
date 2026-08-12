import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/incident.dart';
import '../models/emergency_contact.dart';

class ApiService {
  // Configuración dinámica de URL Base según la plataforma de ejecución
  // - Emulador Android: 10.0.2.2 apunta al host donde se ejecuta Docker/FastAPI
  // - Simulador iOS / Web / Desktop: 127.0.0.1 o localhost
  // - Dispositivo Físico: Usar IP de la red local (ej. 192.168.x.x)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      // iOS / macOS / otros
      return 'http://127.0.0.1:8000/api/v1';
    }
  }

  // Obtener lista de categorías
  static Future<List<IncidentCategory>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/incidents/categories'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => IncidentCategory.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo categorías: $e');
      return [];
    }
  }

  // Obtener reportes e incidentes cercanos en Puerto Montt
  static Future<List<Incident>> getIncidents({
    double lat = -41.4693,
    double lon = -72.9424,
    double radiusKm = 10.0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/incidents/?latitude=$lat&longitude=$lon&radius_km=$radiusKm');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Incident.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo incidentes: $e');
      return [];
    }
  }

  // Crear un nuevo reporte de incidente
  static Future<bool> createIncident({
    required String title,
    required String description,
    required int categoryId,
    required double latitude,
    required double longitude,
    required String addressReference,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incidents/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'category_id': categoryId,
          'latitude': latitude,
          'longitude': longitude,
          'address_reference': addressReference,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando incidente: $e');
      return false;
    }
  }

  // Obtener accesos directos a emergencias de Puerto Montt
  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/emergency/contacts'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => EmergencyContact.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo contactos de emergencia: $e');
      return [];
    }
  }
}
