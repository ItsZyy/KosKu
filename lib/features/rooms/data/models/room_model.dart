class RoomModel {
  final String id;
  final String roomNumber;
  final double price;
  final int capacity;
  final String status;
  final String facilities;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.price,
    required this.capacity,
    required this.status,
    required this.facilities,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] as String,
      roomNumber: map['room_number'] as String,
      price: (map['price'] as num).toDouble(),
      capacity: (map['capacity'] as num).toInt(),
      status: map['status'] as String,
      facilities: map['facilities'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
