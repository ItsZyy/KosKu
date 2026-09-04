import '../../../payments/data/models/payment_formatter.dart';

/// Format angka ke "Rp 1.500.000" untuk preview.
/// Nilai yang disimpan ke DB tetap numeric (int).
String formatRupiahPreview(num value) {
  return PaymentFormatter.rupiah(value);
}