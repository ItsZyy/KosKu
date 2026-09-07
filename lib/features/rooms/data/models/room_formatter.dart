import '../../../payments/data/models/payment_formatter.dart';

/// Format angka ke "Rp 1.500.000" untuk preview.
String formatRupiahPreview(num value) {
  return PaymentFormatter.rupiah(value);
}
