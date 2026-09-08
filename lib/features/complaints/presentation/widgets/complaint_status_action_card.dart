import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ComplaintStatusActionCard extends StatelessWidget {
  final String currentStatus;
  final bool isUpdating;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onUpdate;

  const ComplaintStatusActionCard({
    super.key,
    required this.currentStatus,
    required this.isUpdating,
    required this.onStatusChanged,
    required this.onUpdate,
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
          Text(
            'Ubah Status',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildStatusOption(
            status: 'waiting',
            icon: Icons.schedule_rounded,
            label: 'Menunggu',
          ),
          const SizedBox(height: 10),

          _buildStatusOption(
            status: 'process',
            icon: Icons.build_rounded,
            label: 'Diproses',
          ),
          const SizedBox(height: 10),

          _buildStatusOption(
            status: 'completed',
            icon: Icons.check_circle_outline_rounded,
            label: 'Selesai',
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isUpdating ? null : onUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.textDisabled,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Update Laporan',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String status,
    required IconData icon,
    required String label,
  }) {
    final bool selected = currentStatus == status;

    return InkWell(
      onTap: isUpdating
          ? null
          : () {
              onStatusChanged(status);
            },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                style: selected
                    ? AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      )
                    : AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
