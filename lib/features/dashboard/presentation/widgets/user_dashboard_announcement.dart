// widget untuk dashboard user screen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../announcements/data/models/announcement_model.dart';
import '../../../announcements/presentation/widgets/announcement_card.dart';

class UserDashboardAnnouncement extends StatelessWidget {
  final List<AnnouncementModel> announcements;
  final VoidCallback? onViewAll;

  const UserDashboardAnnouncement({
    super.key,
    this.announcements = const [],
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Pengumuman', style: AppTextStyles.titleLarge),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text('Lihat Semua', style: AppTextStyles.link),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (announcements.isNotEmpty)
          ...announcements.map(
            (a) => Padding(
              padding: EdgeInsets.only(
                bottom: a != announcements.last ? 12 : 0,
              ),
              child: AnnouncementCard(announcement: a),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.campaign_outlined,
                  size: 36,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 10),
                Text(
                  'Belum ada pengumuman terbaru',
                  textAlign: TextAlign.center,
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
}
