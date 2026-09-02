import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String? qrisImageUrl;

  const PaymentMethodCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.qrisImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card),
                const SizedBox(width: 10),
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance, size: 28),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bankName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          accountNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'a.n. $accountName',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (qrisImageUrl != null && qrisImageUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),

              const Text('QRIS', style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrisImageUrl!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 240,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 40),
                          SizedBox(height: 8),
                          Text('QRIS tidak dapat ditampilkan'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            const Text(
              'Silakan lakukan pembayaran melalui metode di atas.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
