import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident.dart';
import '../services/api_service.dart';
import 'report_incident_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Coordenadas del centro urbano de Puerto Montt, Chile
  final double centerLat = -41.4693;
  final double centerLon = -72.9424;

  List<Incident> incidents = [];
  bool isLoading = true;

  // Incidentes de muestra para Puerto Montt cuando el backend local no responde o está offline
  final List<Incident> mockIncidents = [
    Incident(
      id: 101,
      title: 'Semáforo Apagado',
      description: 'Semáforo fuera de servicio en cruce de Av. Diego Portales con Costanera.',
      categoryId: 1,
      categoryName: 'Tránsito',
      latitude: -41.4705,
      longitude: -72.9410,
      addressReference: 'Av. Diego Portales / Costanera, Puerto Montt',
      status: 'reported',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      distanceKm: 0.3,
    ),
    Incident(
      id: 102,
      title: 'Bache Peligroso en Calzada',
      description: 'Bache profundo en carril derecho afectando el tránsito vehicular.',
      categoryId: 2,
      categoryName: 'Infraestructura',
      latitude: -41.4658,
      longitude: -72.9520,
      addressReference: 'Sector Angelmó, Puerto Montt',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      distanceKm: 1.2,
    ),
    Incident(
      id: 103,
      title: 'Falta de Alumbrado Público',
      description: 'Tramo sin iluminación nocturna en avenida principal hacia la playa.',
      categoryId: 3,
      categoryName: 'Alumbrado',
      latitude: -41.4780,
      longitude: -72.9150,
      addressReference: 'Balneario Pelluco, Puerto Montt',
      status: 'reported',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      distanceKm: 2.5,
    ),
    Incident(
      id: 104,
      title: 'Acumulación de Escombros',
      description: 'Depósito no autorizado de escombros bloqueando paso peatonal.',
      categoryId: 4,
      categoryName: 'Limpieza',
      latitude: -41.4880,
      longitude: -72.9750,
      addressReference: 'Sector Chinquihue, Puerto Montt',
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      distanceKm: 3.8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getIncidents(lat: centerLat, lon: centerLon);
      setState(() {
        if (data.isNotEmpty) {
          incidents = data;
        } else {
          incidents = mockIncidents;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        incidents = mockIncidents;
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
      case 'reportado':
        return Colors.redAccent;
      case 'in_progress':
      case 'en proceso':
        return Colors.orangeAccent;
      case 'resolved':
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'tránsito':
      case 'transito':
        return Icons.traffic_rounded;
      case 'infraestructura':
        return Icons.build_rounded;
      case 'alumbrado':
        return Icons.lightbulb_rounded;
      case 'limpieza':
        return Icons.delete_outline_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puerto Montt - Incidentes en Vivo'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIncidents,
            tooltip: 'Actualizar Mapa',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.blueGrey.shade50,
              child: Column(
                children: [
                  // MAPA INTERACTIVO REAL CON FLUTTER_MAP (OPENSTREETMAP)
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(centerLat, centerLon),
                            initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.puertomontt.app',
                            ),
                            MarkerLayer(
                              markers: incidents.map((inc) {
                                return Marker(
                                  point: LatLng(inc.latitude, inc.longitude),
                                  width: 44,
                                  height: 44,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${inc.title}: ${inc.addressReference}'),
                                          duration: const Duration(seconds: 3),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: _getStatusColor(inc.status),
                                          width: 2.5,
                                        ),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(inc.effectiveCategoryName),
                                        color: _getStatusColor(inc.status),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        // Indicador de estado y resumen sobre el mapa
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${incidents.length} Alertas en Puerto Montt',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Encabezado de Lista de Reportes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reportes Cercanos en Tiempo Real',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Radio: 5 km',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista interactiva de tarjetas de incidentes
                  Expanded(
                    child: ListView.builder(
                      itemCount: incidents.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final inc = incidents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(inc.status).withOpacity(0.15),
                              child: Icon(
                                _getCategoryIcon(inc.effectiveCategoryName),
                                color: _getStatusColor(inc.status),
                              ),
                            ),
                            title: Text(
                              inc.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(inc.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.place, size: 12, color: Colors.grey),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        inc.addressReference ?? 'Puerto Montt',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (inc.distanceKm != null)
                                      Text(
                                        '${inc.distanceKm} km',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(inc.status),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                inc.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportIncidentScreen()),
          );
          if (res == true) {
            _loadIncidents();
          }
        },
        backgroundColor: const Color(0xFFE53935),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('REPORTAR INCIDENTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
