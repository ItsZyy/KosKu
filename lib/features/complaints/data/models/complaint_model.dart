class ComplaintModel {
  final String id;
  final String roomId;
  final String userId;
  final String type;
  final String message;
  final String? photoUrl;
  final String status;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.type,
    required this.message,
    this.photoUrl,
    required this.status,
    this.resolvedAt,
    required this.createdAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      id: map['id'].toString(),
      roomId: map['room_id'].toString(),
      userId: map['user_id'].toString(),
      type: map['type']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      photoUrl: map['photo_url']?.toString(),
      status: map['status']?.toString() ?? 'Menunggu',
      resolvedAt: map['resolved_at'] != null
          ? DateTime.tryParse(map['resolved_at'].toString())
          : null,
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }
}
