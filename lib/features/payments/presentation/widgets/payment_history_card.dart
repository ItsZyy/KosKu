import 'package:flutter/material.dart';

class PaymentHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final VoidCallback? onViewAll;

  const PaymentHistoryCard({
    super.key,
    required this.payments,
    this.onViewAll,
  });

  String _formatRupiah(dynamic amount) {
    if (amount == null) return '-';

    final value = int.tryParse(amount.toString());

    if (value == null) {
      return amount.toString();
    }

    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';

    final parsedDate = DateTime.tryParse(date.toString());

    if (parsedDate == null) return date.toString();

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

    return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
  }

  String _getStatusLabel(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'confirmed':
        return 'LUNAS';
      case 'rejected':
        return 'DITOLAK';
      case 'pending':
        return 'MENUNGGU';
      default:
        return status?.toString().toUpperCase() ?? '-';
    }
  }

  IconData _getStatusIcon(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Riwayat Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada riwayat pembayaran',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...payments.map(
                (payment) => _PaymentHistoryItem(
                  period: payment['period']?.toString() ?? '-',
                  amount: _formatRupiah(payment['amount']),
                  date: _formatDate(
                    payment['confirmed_at'] ??
                        payment['created_at'],
                  ),
                  status: _getStatusLabel(payment['status']),
                  statusIcon: _getStatusIcon(payment['status']),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final String period;
  final String amount;
  final String date;
  final String status;
  final IconData statusIcon;

  const _PaymentHistoryItem({
    required this.period,
    required this.amount,
    required this.date,
    required this.status,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}