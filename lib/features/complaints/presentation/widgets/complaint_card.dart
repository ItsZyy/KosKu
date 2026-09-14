import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/profile/data/services/profile_service.dart';
import '../../data/models/complaint_model.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final String? userName;
  final String? roomNumber;
  final VoidCallback? onDetail;
  final bool isMine;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.userName,
    this.roomNumber,
    this.onDetail,
    this.isMine = false,
  });

  Color get statusColor {
    switch (complaint.status.toLowerCase()) {
      case 'menunggu':
      case 'waiting':
        return AppColors.warning;
      case 'diproses':
      case 'process':
        return AppColors.info;
      case 'selesai':
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get statusBackgroundColor {
    switch (complaint.status.toLowerCase()) {
      case 'menunggu':
      case 'waiting':
        return AppColors.warningSoft;
      case 'diproses':
      case 'process':
        return AppColors.infoSoft;
      case 'selesai':
      case 'completed':
        return AppColors.successSoft;
      default:
        return AppColors.inputBackground;
    }
  }

  String get statusText {
    switch (complaint.status.toLowerCase()) {
      case 'menunggu':
      case 'waiting':
        return 'Menunggu';
      case 'diproses':
      case 'process':
        return 'Diproses';
      case 'selesai':
      case 'completed':
        return 'Selesai';
      default:
        return complaint.status;
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        complaint.photoUrl != null && complaint.photoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: isMine
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMine) ...[_buildMineLabel(), const SizedBox(height: 14)],
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMessage(),
            if (hasPhoto) ...[const SizedBox(height: 12), _buildPhoto()],
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMineLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Keluhan Anda',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            complaint.type,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildStatus(),
      ],
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      complaint.message,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        complaint.photoUrl!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                width: double.infinity,
                height: 160,
                color: AppColors.inputBackground,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 32,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto tidak dapat dimuat',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildUserInformation()),
        const SizedBox(width: 12),
        _buildDetailButton(),
      ],
    );
  }

  Widget _buildUserInformation() {
    final complaintName = complaint.userName?.trim();

    final displayName = isMine
        ? 'Anda'
        : complaintName != null && complaintName.isNotEmpty
        ? complaintName
        : userName != null && userName!.trim().isNotEmpty
        ? userName!.trim()
        : 'Penghuni';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildUserAvatar(displayName),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _formatDate(complaint.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '•',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(complaint.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String displayName) {
    final photoUrl = ProfileService.resolveProfilePhotoUrl(
      complaint.userPhotoUrl,
    );

    String initial = 'P';

    if (displayName.isNotEmpty) {
      initial = displayName[0].toUpperCase();
    }

    final fallback = Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (photoUrl == null) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 32,
        height: 32,
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

  Widget _buildDetailButton() {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onDetail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Detail',
          style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
