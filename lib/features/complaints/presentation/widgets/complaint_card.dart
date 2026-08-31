import 'package:flutter/material.dart';

import '../../data/models/complaint_model.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final String? userName;
  final String? roomNumber;
  final VoidCallback? onDetail;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.userName,
    this.roomNumber,
    this.onDetail,
  });

  Color get statusColor {
    switch (complaint.status) {
      case 'Menunggu':
        return Colors.red;
      case 'Diproses':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (complaint.status) {
      case 'Menunggu':
        return Icons.hourglass_empty;
      case 'Diproses':
        return Icons.sync;
      case 'Selesai':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
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

    final day = date.day.toString();
    final month = months[date.month - 1];
    final year = date.year.toString();

    return '$day $month $year';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildMessage(),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildInformation(),
            const SizedBox(height: 12),
            _buildDetailButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (complaint.photoUrl != null &&
                  complaint.photoUrl!.isNotEmpty) ...[
                const Icon(Icons.image_outlined, size: 22),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  complaint.type,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStatus(),
      ],
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            complaint.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      complaint.message,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildInformation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  userName ?? 'User',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 5),
                Text(_formatDate(complaint.createdAt)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 5),
                Text(_formatTime(complaint.createdAt)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onDetail, child: const Text('Detail')),
    );
  }
}
