class TenantModel {
  final String id;
  final String userId;
  final String roomId;
  final String name;
  final String? phone;
  final String? profilePhotoUrl;
  final String roomNumber;
  final DateTime contractStart;
  final DateTime contractEnd;
  final double rentPrice;
  final String status;

  const TenantModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.name,
    this.phone,
    this.profilePhotoUrl,
    required this.roomNumber,
    required this.contractStart,
    required this.contractEnd,
    required this.rentPrice,
    required this.status,
  });

  String get joinedDate {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${contractStart.day.toString().padLeft(2, '0')} '
        '${months[contractStart.month - 1]} '
        '${contractStart.year}';
  }

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      roomId: map['room_id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      roomNumber: map['room_number'] as String,
      contractStart: DateTime.parse(map['contract_start'] as String),
      contractEnd: DateTime.parse(map['contract_end'] as String),
      rentPrice: (map['rent_price'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}
