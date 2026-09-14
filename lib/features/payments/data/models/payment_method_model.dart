class PaymentMethodModel {
  final String id;
  final String type;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? qrisImageUrl;
  final DateTime? updatedAt;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.qrisImageUrl,
    this.updatedAt,
  });

  bool get isBank => type == 'bank';

  bool get isQris => type == 'qris';

  bool get isCash => type == 'cash';

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'].toString(),
      type: map['type'].toString(),
      bankName: map['bank_name']?.toString(),
      accountNumber: map['account_number']?.toString(),
      accountName: map['account_name']?.toString(),
      qrisImageUrl: map['qris_image_url']?.toString(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}
