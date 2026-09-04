import 'package:kosku/features/rooms/data/services/room_service.dart';

class RoomModel {
  final String id;
  final String roomNumber;
  final double price;
  final int capacity;
  final String status;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.price,
    required this.capacity,
    required this.status,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  List<String> get imagePaths => RoomService.parseImageUrls(imageUrl);

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] as String,
      roomNumber: map['room_number'] as String,
      price: (map['price'] as num).toDouble(),
      capacity: (map['capacity'] as num?)?.toInt() ?? 1,
      status: (map['status'] as String?) ?? 'kosong',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
