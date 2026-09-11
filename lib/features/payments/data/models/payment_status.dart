enum PaymentStatus {
  pending('menunggu'),
  confirmed('dikonfirmasi'),
  rejected('ditolak');

  const PaymentStatus(this.value);

  final String value;

  static PaymentStatus? tryParse(String? value) {
    switch (value?.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return PaymentStatus.pending;
      case 'dikonfirmasi':
      case 'confirmed':
        return PaymentStatus.confirmed;
      case 'ditolak':
      case 'rejected':
        return PaymentStatus.rejected;
      default:
        return null;
    }
  }
}