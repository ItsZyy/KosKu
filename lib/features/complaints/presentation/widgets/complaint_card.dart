// widget untuk reports_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    switch (complaint.status.toLowerCase()) {
      case 'menunggu':
        return AppColors.warning;
      case 'diproses':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get statusBackgroundColor {
    switch (complaint.status.toLowerCase()) {
      case 'menunggu':
        return AppColors.warningSoft;
      case 'diproses':
        return AppColors.infoSoft;
      case 'selesai':
        return AppColors.successSoft;
      default:
        return AppColors.inputBackground;
    }
  }

  IconData get statusIcon {
    switch (complaint.status.toLowerCase()) {
      case 'menunggu':
        return Icons.hourglass_empty_rounded;
      case 'diproses':
        return Icons.sync_rounded;
      case 'selesai':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
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
    final hasPhoto =
        complaint.photoUrl != null && complaint.photoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
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

  // ============================================================
  // HEADER
  // ============================================================

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

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 13, color: statusColor),

          const SizedBox(width: 4),

          Text(
            complaint.status.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  Widget _buildMessage() {
    return Text(
      complaint.message,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    );
  }

  // ============================================================
  // PHOTO
  // ============================================================

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

  // ============================================================
  // FOOTER
  // ============================================================

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

  // ============================================================
  // USER INFORMATION
  // ============================================================

  Widget _buildUserInformation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildUserAvatar(),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName ?? 'User',
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

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildUserAvatar() {
    final name = userName?.trim();

    String initial = 'U';

    if (name != null && name.isNotEmpty) {
      initial = name[0].toUpperCase();
    }

    return Container(
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
  }

  // ============================================================
  // DETAIL BUTTON
  // ============================================================

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
