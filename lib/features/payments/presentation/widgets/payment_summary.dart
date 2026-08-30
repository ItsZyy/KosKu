import 'package:flutter/material.dart';

class PaymentSummary extends StatelessWidget {
  final int totalBill;
  final int paidBill;
  final int unpaidBill;

  const PaymentSummary({
    super.key,
    required this.totalBill,
    required this.paidBill,
    required this.unpaidBill,
  });

  // String _formatRupiah(int amount) {
  //   final text = amount.toString();
  //   final buffer = StringBuffer();

  //   for (int i = 0; i < text.length; i++) {
  //     if (i > 0 && (text.length - i) % 3 == 0) {
  //       buffer.write('.');
  //     }

  //     buffer.write(text[i]);
  //   }

  //   return 'Rp ${buffer.toString()}';
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              icon: Icons.receipt_long,
              title: 'Total Tagihan',
              amount: totalBill,
            ),
            const Divider(height: 20),
            _SummaryRow(
              icon: Icons.check_circle,
              title: 'Sudah Bayar',
              amount: paidBill,
            ),
            const Divider(height: 20),
            _SummaryRow(
              icon: Icons.cancel,
              title: 'Belum Bayar',
              amount: unpaidBill,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;

  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.amount,
  });

  String _formatRupiah(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Text(
          _formatRupiah(amount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
