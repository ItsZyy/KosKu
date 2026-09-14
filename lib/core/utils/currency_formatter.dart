// Memformat angka menjadi format Rupiah, misalnya "Rp 1.500.000".
String formatRupiah(dynamic value) {
  final amount = int.tryParse(value?.toString() ?? '');
  if (amount == null) return value?.toString() ?? '-';

  return 'Rp ${amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  )}';
}