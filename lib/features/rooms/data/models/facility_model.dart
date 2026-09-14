class FacilityModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final bool isActive;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.isActive,
  });

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    return FacilityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      isActive: (map['is_active'] as bool?) ?? true,
    );
  }
}
