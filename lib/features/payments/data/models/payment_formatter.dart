class PaymentFormatter {
  PaymentFormatter._();

  static String rupiah(dynamic amount) {
    if (amount == null) return '-';

    final value = int.tryParse(amount.toString());
    if (value == null) return amount.toString();

    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  static String period(dynamic period) {
    if (period == null) return '-';

    final date = DateTime.tryParse(period.toString());
    if (date == null) return period.toString();

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

    return '${months[date.month - 1]} ${date.year}';
  }

  static String date(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Lunas';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu Pembayaran';
      default:
        return status;
    }
  }
}
