class EmergencyContact {
  final int id;
  final String institutionName;
  final String shortCode;
  final String phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String icon;

  EmergencyContact({
    required this.id,
    required this.institutionName,
    required this.shortCode,
    required this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    required this.icon,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      institutionName: json['institution_name'],
      shortCode: json['short_code'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      icon: json['icon'] ?? 'phone',
    );
  }
}
