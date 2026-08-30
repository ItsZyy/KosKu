import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onTap;

  const PaymentCard({super.key, required this.payment, this.onTap});

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

  String _formatDate(String? value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final profile = payment['profiles'] as Map<String, dynamic>?;

    final room = payment['rooms'] as Map<String, dynamic>?;

    final name = profile?['name'] ?? 'Penghuni';
    final roomNumber = room?['room_number'] ?? '-';

    final amount = (payment['amount'] as num?)?.toInt() ?? 0;

    final status = payment['status']?.toString() ?? 'menunggu';

    final createdAt = payment['created_at']?.toString();

    final proofUrl = payment['proof_url']?.toString();

    final isPaid = status == 'dikonfirmasi';
    final isWaiting = status == 'menunggu';

    final statusText = isPaid
        ? 'LUNAS'
        : isWaiting
        ? 'MENUNGGU'
        : 'BELUM BAYAR';

    final statusColor = isPaid
        ? Colors.green
        : isWaiting
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 24, child: const Icon(Icons.person)),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kamar $roomNumber',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              children: [
                const Expanded(child: Text('Jumlah Tagihan')),
                Text(
                  _formatRupiah(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Expanded(child: Text('Tanggal')),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            if (proofUrl != null && proofUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.image, size: 18),
                  SizedBox(width: 6),
                  Text('Bukti pembayaran tersedia'),
                ],
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                child: Text(isWaiting ? 'Verifikasi' : 'Lihat Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
