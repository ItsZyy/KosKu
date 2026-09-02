import 'package:flutter/material.dart';

import 'payment_status_badge.dart';

class PaymentHeaderCard extends StatelessWidget {
  final String period;
  final String status;
  final String roomNumber;
  final int roomPrice;
  final int utilityPrice;
  final int additionalFee;

  const PaymentHeaderCard({
    super.key,
    required this.period,
    required this.status,
    required this.roomNumber,
    required this.roomPrice,
    required this.utilityPrice,
    required this.additionalFee,
  });

  int get totalAmount => roomPrice + utilityPrice + additionalFee;

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PaymentStatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 10),
                Text(
                  _formatRupiah(totalAmount),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _PaymentRow(
                    title: 'Sewa Kamar ($roomNumber)',
                    amount: _formatRupiah(roomPrice),
                  ),
                  const SizedBox(height: 12),
                  _PaymentRow(
                    title: 'Listrik & Air',
                    amount: _formatRupiah(utilityPrice),
                  ),
                  const SizedBox(height: 12),
                  _PaymentRow(
                    title: 'Biaya Tambahan',
                    amount: _formatRupiah(additionalFee),
                  ),
                  const Divider(height: 24),
                  _PaymentRow(
                    title: 'TOTAL',
                    amount: _formatRupiah(totalAmount),
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String title;
  final String amount;
  final bool isTotal;

  const _PaymentRow({
    required this.title,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
