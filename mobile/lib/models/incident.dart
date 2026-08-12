class IncidentCategory {
  final int id;
  final String name;
  final String? description;
  final String iconName;
  final String colorCode;

  IncidentCategory({
    required this.id,
    required this.name,
    this.description,
    required this.iconName,
    required this.colorCode,
  });

  factory IncidentCategory.fromJson(Map<String, dynamic> json) {
    return IncidentCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconName: json['icon_name'] ?? 'warning',
      colorCode: json['color_code'] ?? '#FF0000',
    );
  }
}

class Incident {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final IncidentCategory category;
  final int userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String? addressReference;
  final String status;
  final String? imageUrl;
  final double? distanceKm;
  final DateTime createdAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.category,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    this.addressReference,
    required this.status,
    this.imageUrl,
    this.distanceKm,
    required this.createdAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['category_id'],
      category: IncidentCategory.fromJson(json['category']),
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Ciudadano',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressReference: json['address_reference'],
      status: json['status'],
      imageUrl: json['image_url'],
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
