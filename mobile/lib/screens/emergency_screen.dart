import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/api_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<EmergencyContact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    setState(() => isLoading = true);
    final data = await ApiService.getEmergencyContacts();
    setState(() {
      contacts = data;
      isLoading = false;
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_police':
        return Icons.local_police;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'medical_services':
        return Icons.medical_services;
      case 'security':
        return Icons.security;
      default:
        return Icons.phone_in_talk;
    }
  }

  Color _getInstitutionColor(String shortCode) {
    switch (shortCode) {
      case '133':
        return const Color(0xFF1B5E20); // Verde Carabineros
      case '132':
        return const Color(0xFFB71C1C); // Rojo Bomberos
      case '131':
        return const Color(0xFF0D47A1); // Azul SAMU
      default:
        return const Color(0xFFE65100); // Naranja Seguridad Ciudadana
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centrales de Emergencia Local'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Acceso directo a las líneas de emergencia de Puerto Montt. Toque el botón para iniciar llamada inmediata.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFB71C1C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final c = contacts[index];
                        final color = _getInstitutionColor(c.shortCode);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: color,
                                  child: Icon(_getIconData(c.icon), color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.institutionName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.address ?? 'Puerto Montt',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Número directo: ${c.phoneNumber}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Llamando a ${c.institutionName} (${c.phoneNumber})...'),
                                        backgroundColor: color,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                                  label: Text(
                                    c.shortCode,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
