import 'package:flutter/material.dart';

import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_status.dart';

class PaymentHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> payments;

  const PaymentHistoryCard({super.key, required this.payments});

  String _formatRupiah(dynamic amount) {
    if (amount == null) return '-';

    final value = int.tryParse(amount.toString());

    if (value == null) {
      return amount.toString();
    }

    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';

    final parsedDate = DateTime.tryParse(date.toString());

    if (parsedDate == null) {
      return date.toString();
    }

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

  String _getStatusLabel(Map<String, dynamic> payment) {
    final rawStatus = payment['status']?.toString();

    if (PaymentStatus.tryParse(rawStatus) == null) {
      return rawStatus ?? '-';
    }

    final proofUrl = payment['proof_url']?.toString();

    final isCash =
        payment['payment_method']?.toString().toLowerCase() == 'cash';

    final dueDate = DateTime.tryParse(payment['due_date']?.toString() ?? '');

    return resolvePaymentDisplayStatus(
      status: rawStatus,
      hasProof: proofUrl != null && proofUrl.isNotEmpty,
      isCash: isCash,
      dueDate: dueDate,
    ).label;
  }

  IconData _getStatusIcon(Map<String, dynamic> payment) {
    switch (PaymentStatus.tryParse(payment['status']?.toString())) {
      case PaymentStatus.confirmed:
        return Icons.check_circle;

      case PaymentStatus.rejected:
        return Icons.cancel;

      case PaymentStatus.pending:
        final proofUrl = payment['proof_url']?.toString();

        final isCash =
            payment['payment_method']?.toString().toLowerCase() == 'cash';

        final dueDate = DateTime.tryParse(payment['due_date']?.toString() ?? '');

        final display = resolvePaymentDisplayStatus(
          status: payment['status']?.toString(),
          hasProof: proofUrl != null && proofUrl.isNotEmpty,
          isCash: isCash,
          dueDate: dueDate,
        );

        if (display == PaymentDisplayStatus.late) {
          return Icons.error_outline;
        }

        if (display == PaymentDisplayStatus.notPaid) {
          return Icons.schedule;
        }

        return Icons.access_time;

      case null:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(Map<String, dynamic> payment) {
    switch (PaymentStatus.tryParse(payment['status']?.toString())) {
      case PaymentStatus.confirmed:
        return Colors.green;

      case PaymentStatus.rejected:
        return Colors.red;

      case PaymentStatus.pending:
        final proofUrl = payment['proof_url']?.toString();

        final isCash =
            payment['payment_method']?.toString().toLowerCase() == 'cash';

        if (isDueDatePassed(
              DateTime.tryParse(payment['due_date']?.toString() ?? ''),
            ) &&
            proofUrl == null &&
            !isCash) {
          return Colors.red;
        }

        return Colors.orange;

      case null:
        return Colors.grey;
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada riwayat pembayaran',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...payments.map((payment) {
                final items = payment['payment_items'];

                final int amount;

                if (items is List && items.isNotEmpty) {
                  int sum = 0;

                  for (final item in items) {
                    sum += (item['amount'] as num?)?.toInt() ?? 0;
                  }

                  amount = sum;
                } else {
                  amount = (payment['amount'] as num?)?.toInt() ?? 0;
                }

                return _PaymentHistoryItem(
                  period: PaymentFormatter.periodRange(
                    DateTime.tryParse(
                      payment['contract_start']?.toString() ?? '',
                    ),
                    DateTime.tryParse(
                      payment['contract_end']?.toString() ?? '',
                    ),
                    fallbackPeriod: payment['period'],
                  ),
                  amount: _formatRupiah(amount),
                  date: _formatDate(
                    payment['confirmed_at'] ?? payment['created_at'],
                  ),
                  status: _getStatusLabel(payment),
                  statusIcon: _getStatusIcon(payment),
                  statusColor: _getStatusColor(payment),
                );
              }),
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
  final Color statusColor;

  const _PaymentHistoryItem({
    required this.period,
    required this.amount,
    required this.date,
    required this.status,
    required this.statusIcon,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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
