import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_model.dart';

class AdminPaymentTenantCard extends StatelessWidget {
  final Payment payment;

  const AdminPaymentTenantCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final name = payment.userName;
    final photoUrl = payment.userPhotoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(name: name, photoUrl: photoUrl),
          const SizedBox(width: 12),
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildAvatar({String? name, String? photoUrl}) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: hasPhoto
          ? null
          : Text(
              (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
    );
  }

  Widget _buildInfo() {
    final name = payment.userName ?? 'Penghuni';
    final roomNumber = payment.roomNumber;
    final phone = payment.userPhone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          icon: Icons.meeting_room_outlined,
          text: roomNumber != null ? 'Kamar $roomNumber' : 'Kamar -',
        ),
        if (phone != null && phone.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildInfoRow(icon: Icons.phone_outlined, text: phone),
        ],
      ],
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}