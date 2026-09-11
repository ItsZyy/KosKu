import 'payment_status.dart';

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

  /// Menampilkan rentang periode tagihan/kontrak penghuni, misalnya
  /// "Sep 2026 - Feb 2027". Jika data kontrak tidak tersedia, kembali
  /// ke format periode tunggal lama.
  static String periodRange(
    DateTime? contractStart,
    DateTime? contractEnd, {
    dynamic fallbackPeriod,
  }) {
    if (contractStart != null && contractEnd != null) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      final start = '${months[contractStart.month - 1]} ${contractStart.year}';
      final end = '${months[contractEnd.month - 1]} ${contractEnd.year}';

      return '$start - $end';
    }

    return period(fallbackPeriod);
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
    switch (PaymentStatus.tryParse(status)) {
      case PaymentStatus.confirmed:
        return 'Lunas';
      case PaymentStatus.rejected:
        return 'Ditolak';
      case PaymentStatus.pending:
        return 'Menunggu Pembayaran';
      case null:
        return status;
    }
  }
}
