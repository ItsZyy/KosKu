class PaymentItem {
  final String? id;
  final String? paymentId;
  final String? itemType;
  final String? description;
  final int amount;
  final DateTime? createdAt;

  const PaymentItem({
    this.id,
    this.paymentId,
    this.itemType,
    this.description,
    this.amount = 0,
    this.createdAt,
  });

  factory PaymentItem.fromMap(Map<String, dynamic> map) {
    return PaymentItem(
      id: map['id']?.toString(),
      paymentId: map['payment_id']?.toString(),
      itemType: map['item_type']?.toString(),
      description: map['description']?.toString(),
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      'item_type': itemType,
      'description': description,
      'amount': amount,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

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

  // Rincian tagihan bersumber dari tabel payment_items.
  final List<PaymentItem> items;

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
    this.status = 'menunggu',
    this.confirmedBy,
    this.confirmedAt,
    this.createdAt,
    this.items = const [],
  });

  /// Total resmi selalu berasal dari payments.amount (dihitung oleh
  /// function generate_payment di database). Flutter tidak menghitung
  /// ulang dari payment_items.
  int get totalAmount => amount;

  bool get hasBreakdown => items.isNotEmpty;

  bool get isPending => status.toLowerCase() == 'menunggu';
  bool get isConfirmed => status.toLowerCase() == 'dikonfirmasi';
  bool get isRejected => status.toLowerCase() == 'ditolak';

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
      status: map['status']?.toString() ?? 'menunggu',
      confirmedBy: map['confirmed_by']?.toString(),
      confirmedAt: _parseDate(map['confirmed_at']),
      createdAt: _parseDate(map['created_at']),
      items: _extractItems(map),
    );
  }

  static List<PaymentItem> _extractItems(Map<String, dynamic> map) {
    final raw = map['payment_items'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => PaymentItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const <PaymentItem>[];
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
      'payment_items': items.map((item) => item.toMap()).toList(),
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
}
