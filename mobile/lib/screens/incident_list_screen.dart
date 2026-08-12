import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/api_service.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({Key? key}) : super(key: key);

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  List<Incident> incidents = [];
  bool isLoading = true;
  String selectedFilter = 'ALL';

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
      final data = await ApiService.getIncidents();
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

  List<Incident> get filteredIncidents {
    if (selectedFilter == 'ALL') return incidents;
    return incidents.where((inc) => inc.status.toLowerCase() == selectedFilter.toLowerCase()).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reportes'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Selector de filtro por estado
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('TODOS', 'ALL'),
                  _filterChip('REPORTADOS', 'reported'),
                  _filterChip('EN PROCESO', 'in_progress'),
                  _filterChip('RESUELTOS', 'resolved'),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredIncidents.isEmpty
                    ? const Center(child: Text('No hay incidentes para este filtro.'))
                    : ListView.builder(
                        itemCount: filteredIncidents.length,
                        itemBuilder: (context, index) {
                          final inc = filteredIncidents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(inc.status).withOpacity(0.15),
                                child: Icon(Icons.warning_amber_rounded, color: _getStatusColor(inc.status)),
                              ),
                              title: Text(inc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${inc.effectiveCategoryName} • ${inc.addressReference ?? "Puerto Montt"}'),
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
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11)),
        selected: isSelected,
        selectedColor: const Color(0xFF1E88E5),
        onSelected: (selected) {
          if (selected) {
            setState(() => selectedFilter = value);
          }
        },
      ),
    );
  }
}
