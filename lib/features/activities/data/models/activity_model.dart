class ActivityModel {
  final String type;
  final String title;
  final String? subtitle;
  final String? photoUrl;
  final DateTime timestamp;

  const ActivityModel({
    required this.type,
    required this.title,
    this.subtitle,
    this.photoUrl,
    required this.timestamp,
  });
}