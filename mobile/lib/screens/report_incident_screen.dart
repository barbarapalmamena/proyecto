import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/api_service.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  List<IncidentCategory> categories = [];
  int? selectedCategoryId;
  bool isSubmitting = false;

  // Coordenadas por defecto (Centro de Puerto Montt)
  double latitude = -41.4693;
  double longitude = -72.9424;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final list = await ApiService.getCategories();
    setState(() {
      categories = list;
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first.id;
      }
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || selectedCategoryId == null) {
      return;
    }

    setState(() => isSubmitting = true);

    // Simulación de envío con token temporal
    final success = await ApiService.createIncident(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: selectedCategoryId!,
      latitude: latitude,
      longitude: longitude,
      addressReference: _addressController.text.trim().isEmpty
          ? 'Puerto Montt Centro'
          : _addressController.text.trim(),
      token: 'demo_token_puerto_montt',
    );

    setState(() => isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Incidente reportado exitosamente! Alerta enviada a la comunidad.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el reporte. Intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte de Incidente'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clasificación del Incidente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Dropdown de Categorías
              categories.isEmpty
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedCategoryId = val),
                    ),

              const SizedBox(height: 16),
              const Text(
                'Título del Reporte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej: Semáforo apagado en Av. Diego Portales',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.trim().length < 5
                    ? 'Ingrese un título descriptivo de al menos 5 caracteres.'
                    : null,
              ),

              const SizedBox(height: 16),
              const Text(
                'Descripción Detallada',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describa lo sucedido, nivel de riesgo y referencias...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.trim().length < 10
                    ? 'La descripción debe tener al menos 10 caracteres.'
                    : null,
              ),

              const SizedBox(height: 16),
              const Text(
                'Ubicación y Referencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                  hintText: 'Ej: Cerca de Plaza de Armas / Costanera',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    isSubmitting ? 'ENVIANDO...' : 'PUBLICAR REPORTE',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
