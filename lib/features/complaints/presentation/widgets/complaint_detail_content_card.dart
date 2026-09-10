import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/profile/data/services/profile_service.dart';
import '../../data/models/complaint_model.dart';

class ComplaintDetailContentCard extends StatelessWidget {
  final ComplaintModel complaint;
  final String? userName;
  final String? roomNumber;

  const ComplaintDetailContentCard({
    super.key,
    required this.complaint,
    this.userName,
    this.roomNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTenantInfo(),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 20),
          Text(
            'Deskripsi Kerusakan',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (complaint.photoUrl != null && complaint.photoUrl!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Foto Bukti',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildPhoto(),
          ],
        ],
      ),
    );
  }

  Widget _buildTenantInfo() {
    final complaintName = complaint.userName?.trim();

    final name = complaintName != null && complaintName.isNotEmpty
        ? complaintName
        : userName != null && userName!.trim().isNotEmpty
        ? userName!.trim()
        : 'Penghuni';

    final complaintRoom = complaint.roomNumber?.trim();

    final room = complaintRoom != null && complaintRoom.isNotEmpty
        ? 'Kamar No. $complaintRoom'
        : roomNumber != null && roomNumber!.trim().isNotEmpty
        ? 'Kamar No. ${roomNumber!.trim()}'
        : 'Kamar No. -';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTenantAvatar(name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                room,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenantAvatar(String name) {
    final photoUrl = ProfileService.resolveProfilePhotoUrl(
      complaint.userPhotoUrl,
    );

    final fallback = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primarySoft,
        border: Border.all(color: AppColors.primarySoft, width: 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (photoUrl == null) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return fallback;
        },
      ),
    );
  }

  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Image.network(
          complaint.photoUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              color: AppColors.inputBackground,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.inputBackground,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textHint,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto tidak dapat dimuat',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
