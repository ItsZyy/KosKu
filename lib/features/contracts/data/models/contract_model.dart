class ContractModel {
  final String occupancyId;
  final String userId;
  final String? roomId;

  final String? tenantName;
  final String? tenantPhone;
  final String? profilePhotoUrl;

  final String? roomNumber;

  final String? contractStart;
  final String? contractEnd;
  final double? rentPrice;
  final int? paymentIntervalMonths;
  final int? paymentDay;

  final String status;

  const ContractModel({
    required this.occupancyId,
    required this.userId,
    this.roomId,
    this.tenantName,
    this.tenantPhone,
    this.profilePhotoUrl,
    this.roomNumber,
    this.contractStart,
    this.contractEnd,
    this.rentPrice,
    this.paymentIntervalMonths,
    this.paymentDay,
    required this.status,
  });

  bool get isActive => status.toLowerCase() == 'active';

  bool get isInactive => status.toLowerCase() == 'inactive';

  String get displayName =>
      tenantName?.trim().isNotEmpty == true ? tenantName! : 'Penghuni';

  static ContractModel fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? profile;
    final rawProfile = map['profiles'];

    if (rawProfile is Map) {
      profile = Map<String, dynamic>.from(rawProfile);
    }

    Map<String, dynamic>? room;
    final rawRoom = map['rooms'];

    if (rawRoom is Map) {
      room = Map<String, dynamic>.from(rawRoom);
    }

    final rawRentPrice = map['rent_price'];
    final rawPaymentInterval = map['payment_interval_months'];
    final rawPaymentDay = map['payment_day'];

    return ContractModel(
      occupancyId: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      roomId: map['room_id']?.toString(),
      tenantName: profile?['name']?.toString(),
      tenantPhone: profile?['phone']?.toString(),
      profilePhotoUrl: profile?['profile_photo_url']?.toString(),
      roomNumber: room?['room_number']?.toString(),
      contractStart: map['contract_start']?.toString(),
      contractEnd: map['contract_end']?.toString(),
      rentPrice: rawRentPrice is num ? rawRentPrice.toDouble() : null,
      paymentIntervalMonths: rawPaymentInterval is num
          ? rawPaymentInterval.toInt()
          : null,
      paymentDay: rawPaymentDay is num ? rawPaymentDay.toInt() : null,
      status: map['status']?.toString().toLowerCase() ?? 'inactive',
    );
  }
}
