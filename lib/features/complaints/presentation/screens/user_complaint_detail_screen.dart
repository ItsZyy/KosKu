import 'package:flutter/material.dart';

import '../../data/models/complaint_model.dart';

class UserComplaintDetailScreen extends StatelessWidget {
  final ComplaintModel complaint;

  const UserComplaintDetailScreen({super.key, required this.complaint});

  String _getStatusLabel() {
    final status = complaint.status.trim().toLowerCase();

    switch (status) {
      case 'menunggu':
      case 'pending':
      case 'waiting':
        return 'Menunggu';

      case 'diproses':
      case 'in_progress':
      case 'in progress':
      case 'process':
      case 'processing':
        return 'Diproses';

      case 'selesai':
      case 'resolved':
      case 'completed':
      case 'done':
        return 'Selesai';

      default:
        return complaint.status.isNotEmpty ? complaint.status : 'Menunggu';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (_getStatusLabel()) {
      case 'Menunggu':
        return Colors.orange;

      case 'Diproses':
        return Theme.of(context).colorScheme.primary;

      case 'Selesai':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  int _getStatusIndex() {
    switch (_getStatusLabel()) {
      case 'Menunggu':
        return 0;
      case 'Diproses':
        return 1;
      case 'Selesai':
        return 2;
      default:
        return 0;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _getStatusLabel();
    final statusColor = _getStatusColor(context);
    final statusIndex = _getStatusIndex();

    final hasPhoto =
        complaint.photoUrl != null && complaint.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Keluhan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            complaint.type,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(complaint.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Deskripsi Keluhan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint.message,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 16),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                      child: Text(
                        'Foto Keluhan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        complaint.photoUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Foto tidak dapat dimuat',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Keluhan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _StatusItem(
                      status: 'Menunggu',
                      active: statusIndex >= 0,
                      current: statusIndex == 0,
                      color: Colors.orange,
                    ),
                    _StatusItem(
                      status: 'Diproses',
                      active: statusIndex >= 1,
                      current: statusIndex == 1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _StatusItem(
                      status: 'Selesai',
                      active: statusIndex >= 2,
                      current: statusIndex == 2,
                      color: Colors.green,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String status;
  final bool active;
  final bool current;
  final Color color;
  final bool isLast;

  const _StatusItem({
    required this.status,
    required this.active,
    required this.current,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: current ? 16 : 14,
              height: current ? 16 : 14,
              decoration: BoxDecoration(
                color: active ? color : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: current
                    ? Border.all(color: color.withValues(alpha: 0.25), width: 4)
                    : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: active && status != 'Selesai'
                    ? color.withValues(alpha: 0.25)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            status,
            style: TextStyle(
              fontWeight: current ? FontWeight.w600 : FontWeight.normal,
              color: current
                  ? color
                  : active
                  ? Colors.black87
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
