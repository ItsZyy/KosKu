import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ComplaintSummary extends StatelessWidget {
  final int total;
  final int menunggu;
  final int diproses;
  final int selesai;

  const ComplaintSummary({
    super.key,
    required this.total,
    required this.menunggu,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          icon: Icons.bar_chart_rounded,
          title: 'Total Keluhan',
          value: total,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primarySoft,
        ),
        _buildSummaryCard(
          icon: Icons.hourglass_empty_rounded,
          title: 'Menunggu',
          value: menunggu,
          iconColor: AppColors.warning,
          iconBackground: AppColors.warningSoft,
        ),
        _buildSummaryCard(
          icon: Icons.sync_rounded,
          title: 'Diproses',
          value: diproses,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
        ),
        _buildSummaryCard(
          icon: Icons.check_circle_outline_rounded,
          title: 'Selesai',
          value: selesai,
          iconColor: AppColors.success,
          iconBackground: AppColors.successSoft,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required int value,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.toString(),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
