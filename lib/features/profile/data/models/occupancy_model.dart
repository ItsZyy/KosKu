class OccupancyModel {
  final String id;
  final String roomId;
  final String userId;
  final DateTime contractStart;
  final DateTime contractEnd;
  final double rentPrice;
  final String status;
  final int paymentIntervalMonths;
  final int paymentDay;
  final String roomNumber;
  final List<String> facilities;

  const OccupancyModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.contractStart,
    required this.contractEnd,
    required this.rentPrice,
    required this.status,
    required this.paymentIntervalMonths,
    required this.paymentDay,
    required this.roomNumber,
    required this.facilities,
  });

  factory OccupancyModel.fromMap(Map<String, dynamic> map) {
    final room = map['rooms'] as Map<String, dynamic>?;

    final roomFacilities = room?['room_facilities'] as List<dynamic>? ?? [];

    final facilities = roomFacilities
        .map((item) {
          final facility = item['facilities'] as Map<String, dynamic>?;

          return facility?['name'] as String?;
        })
        .whereType<String>()
        .toList();

    return OccupancyModel(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      userId: map['user_id'] as String,
      contractStart: DateTime.parse(map['contract_start'].toString()),
      contractEnd: DateTime.parse(map['contract_end'].toString()),
      rentPrice: (map['rent_price'] as num).toDouble(),
      status: map['status'] as String? ?? '',
      paymentIntervalMonths: map['payment_interval_months'] as int? ?? 6,
      paymentDay: map['payment_day'] as int? ?? 1,
      roomNumber: room?['room_number'] as String? ?? '-',
      facilities: facilities,
    );
  }
}
