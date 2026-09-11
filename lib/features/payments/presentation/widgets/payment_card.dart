// Widget untuk AdminPaymentsScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/data/services/profile_service.dart';
import 'payment_status_badge.dart';

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
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildAvatar({String? photoUrl}) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: hasPhoto
          ? null
          : Icon(
              Icons.person,
              size: 24,
              color: AppColors.primary,
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

    final amount = (payment['amount'] as num?)?.toInt() ?? 0;

    final status = payment['status']?.toString() ?? 'menunggu';

    final createdAt = payment['created_at']?.toString();

    final proofUrl = payment['proof_url']?.toString();

    final paymentId = payment['id']?.toString();

    // Tombol mengundang admin untuk aksi hanya saat pembayaran
    // benar-benar bisa dikonfirmasi/ditolak: status menunggu DAN
    // penghuni sudah mengirim bukti (badge "Menunggu Konfirmasi").
    final canBeConfirmed =
        status.toLowerCase() == 'menunggu' &&
        proofUrl != null &&
        proofUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(photoUrl: resolvedPhotoUrl),

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
                  hasProof: proofUrl != null && proofUrl.isNotEmpty,
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
                  canBeConfirmed ? 'Konfirmasi Pembayaran' : 'Lihat Detail',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
