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
      id: json['id'] ?? 0,
      name: json['name'] ?? 'General',
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
  final IncidentCategory? category;
  final String? categoryName;
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
    this.category,
    this.categoryName,
    this.userId = 1,
    this.userName = 'Ciudadano',
    required this.latitude,
    required this.longitude,
    this.addressReference,
    required this.status,
    this.imageUrl,
    this.distanceKm,
    required this.createdAt,
  });

  String get effectiveCategoryName {
    if (categoryName != null && categoryName!.isNotEmpty) {
      return categoryName!;
    }
    if (category != null) {
      return category!.name;
    }
    return 'General';
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Incidente',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? 1,
      category: json['category'] != null ? IncidentCategory.fromJson(json['category']) : null,
      categoryName: json['category_name'] ?? (json['category'] != null ? json['category']['name'] : null),
      userId: json['user_id'] ?? 1,
      userName: json['user_name'] ?? 'Ciudadano',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -41.4693,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -72.9424,
      addressReference: json['address_reference'],
      status: json['status'] ?? 'reported',
      imageUrl: json['image_url'],
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
