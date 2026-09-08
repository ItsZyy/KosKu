import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/complaint_model.dart';

class ComplaintDetailHeaderCard extends StatelessWidget {
  final ComplaintModel complaint;
  final String currentStatus;

  const ComplaintDetailHeaderCard({
    super.key,
    required this.complaint,
    required this.currentStatus,
  });

  Color _statusColor() {
    switch (currentStatus) {
      case 'waiting':
        return AppColors.warning;
      case 'process':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusBackground() {
    switch (currentStatus) {
      case 'waiting':
        return AppColors.warningSoft;
      case 'process':
        return AppColors.infoSoft;
      case 'completed':
        return AppColors.successSoft;
      default:
        return AppColors.inputBackground;
    }
  }

  String _statusLabel() {
    switch (currentStatus) {
      case 'waiting':
        return 'Menunggu';
      case 'process':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return currentStatus;
    }
  }

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
          Text(
            'Kategori Keluhan',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            complaint.type,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBackground(),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _statusLabel(),
              style: AppTextStyles.labelMedium.copyWith(
                color: _statusColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
