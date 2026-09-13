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

/// Status tampilan yang konsisten antara Admin dan Penghuni.
enum PaymentDisplayStatus {
  paid('Lunas'),
  waitingConfirmation('Menunggu Konfirmasi'),
  notPaid('Belum Bayar'),
  late('Telat Bayar'),
  rejected('Ditolak');

  const PaymentDisplayStatus(this.label);

  final String label;
}

/// Opsi filter pembayaran yang sama untuk Admin dan Penghuni.
const List<String> paymentStatusFilters = [
  'Semua',
  'Lunas',
  'Menunggu Konfirmasi',
  'Belum Bayar',
  'Telat Bayar',
];

bool isDueDatePassed(DateTime? dueDate) {
  if (dueDate == null) return false;

  final today = DateTime.now();

  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

  final todayDay = DateTime(today.year, today.month, today.day);

  return dueDay.isBefore(todayDay);
}

/// Menentukan status tampilan dari data pembayaran yang ada.
/// "Telat Bayar" hanya tampil saat masih menunggu (tanpa bukti/tunai)
/// dan jatuh tempo sudah lewat.
PaymentDisplayStatus resolvePaymentDisplayStatus({
  required String? status,
  required bool hasProof,
  required bool isCash,
  DateTime? dueDate,
}) {
  switch (PaymentStatus.tryParse(status)) {
    case PaymentStatus.confirmed:
      return PaymentDisplayStatus.paid;
    case PaymentStatus.rejected:
      return PaymentDisplayStatus.rejected;
    case PaymentStatus.pending:
      if (hasProof || isCash) {
        return PaymentDisplayStatus.waitingConfirmation;
      }

      return isDueDatePassed(dueDate)
          ? PaymentDisplayStatus.late
          : PaymentDisplayStatus.notPaid;
    case null:
      return PaymentDisplayStatus.notPaid;
  }
}