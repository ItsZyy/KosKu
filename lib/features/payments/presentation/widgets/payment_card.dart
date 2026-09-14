// Widget untuk AdminPaymentsScreen & AdminRevenueReportScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../data/models/payment_status.dart';
import 'payment_status_badge.dart';

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onTap;

  const PaymentCard({super.key, required this.payment, this.onTap});

  String _formatRupiah(int amount) {
    return formatRupiah(amount);
  }

  String _formatDate(String? value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildAvatar({String? photoUrl, String? name}) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: hasPhoto
          ? null
          : Text(
              (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = payment['profiles'] as Map<String, dynamic>?;

    final room = payment['rooms'] as Map<String, dynamic>?;

    final name = profile?['name'] ?? 'Penghuni';
    final roomNumber = room?['room_number'] ?? '-';

    final photoPath = profile?['profile_photo_url']?.toString();

    final resolvedPhotoUrl = ProfileService.resolveProfilePhotoUrl(photoPath);

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

    final status = payment['status']?.toString() ?? PaymentStatus.pending.value;

    final createdAt = payment['created_at']?.toString();

    final proofUrl = payment['proof_url']?.toString();

    final dueDate = DateTime.tryParse(payment['due_date']?.toString() ?? '');

    final isCash = payment['payment_method']?.toString().toLowerCase() == 'cash';

    final hasSubmittedPayment = proofUrl != null && proofUrl.isNotEmpty;

    final isWaitingConfirmation =
        PaymentStatus.tryParse(status) == PaymentStatus.pending &&
        (hasSubmittedPayment || isCash);

    final paymentId = payment['id']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(photoUrl: resolvedPhotoUrl, name: name),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toString(),
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kamar $roomNumber',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                PaymentStatusBadge(
                  status: status,
                  hasProof: hasSubmittedPayment,
                  isCash: isCash,
                  dueDate: dueDate,
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              children: [
                const Expanded(
                  child: Text('Jumlah Tagihan', style: AppTextStyles.bodyMedium),
                ),
                Text(
                  _formatRupiah(amount),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Expanded(
                  child: Text('Tanggal', style: AppTextStyles.bodyMedium),
                ),
                Text(
                  _formatDate(createdAt),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            if (proofUrl != null && proofUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.image, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text(
                    'Bukti pembayaran tersedia',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: paymentId == null ? null : onTap,
                child: Text(
                  isWaitingConfirmation ? 'Konfirmasi Pembayaran' : 'Lihat Detail',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
