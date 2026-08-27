class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? imageUrl;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.imageUrl,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
      imageUrl: map['image_url'],
    );
  }
}
