class Payment {
  final String? id;
  final String? userId;
  final String? roomId;
  final String? roomNumber;
  final String? userName;
  final String? paymentType;
  final int amount;
  final String? period;
  final DateTime? dueDate;
  final String? proofUrl;
  final String status;
  final String? confirmedBy;
  final DateTime? confirmedAt;
  final DateTime? createdAt;

  // Breakdown
  // TODO: DB FIELD NEEDED — room_rent belum ada di tabel payments
  final int? roomRent;

  // TODO: DB FIELD NEEDED — utilities belum ada di tabel payments
  final int? utilities;

  // TODO: DB FIELD NEEDED — other_amount belum ada di tabel payments
  final int? otherAmount;

  const Payment({
    this.id,
    this.userId,
    this.roomId,
    this.roomNumber,
    this.userName,
    this.paymentType,
    this.amount = 0,
    this.period,
    this.dueDate,
    this.proofUrl,
    this.status = 'pending',
    this.confirmedBy,
    this.confirmedAt,
    this.createdAt,
    this.roomRent,
    this.utilities,
    this.otherAmount,
  });

  int get totalAmount {
    if (roomRent != null || utilities != null || otherAmount != null) {
      return (roomRent ?? 0) + (utilities ?? 0) + (otherAmount ?? 0);
    }
    return amount;
  }

  bool get hasBreakdown =>
      roomRent != null || utilities != null || otherAmount != null;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString(),
      roomId: map['room_id']?.toString(),
      roomNumber: _extractRoomNumber(map),
      userName: _extractUserName(map),
      paymentType: map['payment_type']?.toString(),
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      period: map['period']?.toString(),
      dueDate: _parseDate(map['due_date']),
      proofUrl: map['proof_url']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      confirmedBy: map['confirmed_by']?.toString(),
      confirmedAt: _parseDate(map['confirmed_at']),
      createdAt: _parseDate(map['created_at']),
      roomRent: _parseIntNullable(map['room_rent']),
      utilities: _parseIntNullable(map['utilities']),
      otherAmount: _parseIntNullable(map['other_amount']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (roomId != null) 'room_id': roomId,
      'payment_type': paymentType,
      'amount': amount,
      'period': period,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      'proof_url': proofUrl,
      'status': status,
      if (roomRent != null) 'room_rent': roomRent,
      if (utilities != null) 'utilities': utilities,
      if (otherAmount != null) 'other_amount': otherAmount,
    };
  }

  static String? _extractRoomNumber(Map<String, dynamic> map) {
    final rooms = map['rooms'];
    if (rooms is Map<String, dynamic>) {
      return rooms['room_number']?.toString();
    }
    return null;
  }

  static String? _extractUserName(Map<String, dynamic> map) {
    final profiles = map['profiles'];
    if (profiles is Map<String, dynamic>) {
      return profiles['name']?.toString();
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    return (value as num?)?.toInt();
  }
}
