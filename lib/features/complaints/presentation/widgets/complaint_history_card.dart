import 'package:flutter/material.dart';

class ComplaintHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> complaints;
  final VoidCallback? onViewAll;

  const ComplaintHistoryCard({
    super.key,
    required this.complaints,
    this.onViewAll,
  });

  String _getStatusLabel(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'pending':
      case 'menunggu':
        return 'Menunggu';

      case 'process':
      case 'diproses':
      case 'in_process':
        return 'Diproses';

      case 'completed':
      case 'selesai':
        return 'Selesai';

      default:
        return status?.toString() ?? '-';
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'pending':
      case 'menunggu':
        return Colors.blue;

      case 'process':
      case 'diproses':
      case 'in_process':
        return Colors.orange;

      case 'completed':
      case 'selesai':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData _getComplaintIcon(dynamic type) {
    final value = type?.toString().toLowerCase() ?? '';

    if (value.contains('air')) {
      return Icons.water_drop_outlined;
    }

    if (value.contains('lampu') || value.contains('listrik')) {
      return Icons.lightbulb_outline;
    }

    if (value.contains('wifi') || value.contains('internet')) {
      return Icons.wifi;
    }

    return Icons.report_problem_outlined;
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
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Riwayat Keluhan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (complaints.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${complaints.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (complaints.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada riwayat keluhan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Keluhan yang Anda kirim akan muncul di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...complaints.take(3).map((complaint) {
                    final status = complaint['status'];
                    final statusColor = _getStatusColor(status);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getComplaintIcon(
                                  complaint['title'] ?? complaint['type'],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          complaint['title'] ??
                                              complaint['type'] ??
                                              'Keluhan',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusLabel(status),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    complaint['room_number']?.toString() ??
                                        complaint['room']?['room_number']
                                            ?.toString() ??
                                        'Kamar -',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    complaint['message'] ??
                                        complaint['description'] ??
                                        '-',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  if (complaints.length > 3)
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('Lihat Semua Riwayat →'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
