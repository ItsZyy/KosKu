// widget untuk dashboard user screen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class UserDashboardRoomCard extends StatelessWidget {
  final Map<String, dynamic>? room;

  const UserDashboardRoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final roomData = room?['room'];

    final roomNumber = roomData?['room_number']?.toString() ?? '-';

    final capacity = roomData?['capacity']?.toString() ?? '-';

    final status = roomData?['status']?.toString() ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informasi Kamar', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bedroom_parent_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamar $roomNumber',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Informasi kamar Anda',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.people_outline_rounded,
                      label: 'Kapasitas',
                      value: '$capacity orang',
                    ),
                  ),
                  Container(width: 1, height: 42, color: AppColors.divider),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.home_outlined,
                      label: 'Status',
                      value: status,
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

  Widget _buildStatusBadge(String status) {
    final normalizedStatus = status.toLowerCase();

    final Color textColor;
    final Color backgroundColor;

    if (normalizedStatus == 'terisi' || normalizedStatus == 'aktif') {
      textColor = AppColors.success;
      backgroundColor = AppColors.successSoft;
    } else if (normalizedStatus == 'perbaikan') {
      textColor = AppColors.warning;
      backgroundColor = AppColors.warningSoft;
    } else {
      textColor = AppColors.textSecondary;
      backgroundColor = AppColors.inputBackground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
