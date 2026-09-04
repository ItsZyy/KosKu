import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TenantCard extends StatelessWidget {
  final String name;
  final String roomNumber;
  final String joinedDate;
  final String status;
  final String? photoUrl;
  final VoidCallback? onDetail;

  const TenantCard({
    super.key,
    required this.name,
    required this.roomNumber,
    required this.joinedDate,
    required this.status,
    this.photoUrl,
    this.onDetail,
  });

  bool get isActive => status.toLowerCase() == 'aktif';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatus(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kamar $roomNumber',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bergabung: $joinedDate',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                TextButton(onPressed: onDetail, child: const Text('Detail')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? NetworkImage(photoUrl!)
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }

  Widget _buildStatus() {
    final color = isActive ? AppColors.success : AppColors.textSecondary;
    final backgroundColor = isActive
        ? AppColors.successSoft
        : AppColors.inputBackground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(status, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
