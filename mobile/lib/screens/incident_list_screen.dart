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

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => isLoading = true);
    final data = await ApiService.getIncidents();
    setState(() {
      incidents = data;
      isLoading = false;
    });
  }

  List<Incident> get filteredIncidents {
    if (selectedFilter == 'ALL') return incidents;
    return incidents.where((inc) => inc.status == selectedFilter.toLowerCase()).toList();
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
                            child: ListTile(
                              title: Text(inc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${inc.category.name} • ${inc.addressReference ?? "Puerto Montt"}'),
                              trailing: Text(
                                inc.status.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
