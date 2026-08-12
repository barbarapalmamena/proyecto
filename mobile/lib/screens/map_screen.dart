import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/api_service.dart';
import 'report_incident_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centro geográfico de Puerto Montt
  final double centerLat = -41.4693;
  final double centerLon = -72.9424;

  List<Incident> incidents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => isLoading = true);
    final data = await ApiService.getIncidents(lat: centerLat, lon: centerLon);
    setState(() {
      incidents = data;
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reported':
        return Colors.redAccent;
      case 'in_progress':
        return Colors.orangeAccent;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puerto Montt - Incidentes en Vivo'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIncidents,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.blueGrey.shade50,
              child: Column(
                children: [
                  // Simulación visual de mapa interactivo urbano de Puerto Montt
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.map, size: 64, color: Color(0xFF0284C7)),
                              SizedBox(height: 8),
                              Text(
                                'Mapa Urbano de Puerto Montt',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                              Text(
                                'Coordenadas: -41.4693, -72.9424',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${incidents.length} Alertas activas',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reportes Cercanos en Tiempo Real',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Radio: 5 km',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),

                  // Lista interactiva de tarjetas de incidentes
                  Expanded(
                    child: incidents.isEmpty
                        ? const Center(child: Text('No hay incidentes reportados en esta zona.'))
                        : ListView.builder(
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
                                    backgroundColor: _getStatusColor(inc.status).withOpacity(0.2),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
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
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
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
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
