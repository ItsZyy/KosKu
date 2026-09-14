import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../profile/data/services/profile_service.dart';

class ActivityFeed extends StatelessWidget {
  final List<ActivityModel> activities;

  const ActivityFeed({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.notifications_none),
          title: Text('Belum ada aktivitas terbaru'),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < activities.length; i++) ...[
            _ActivityTile(activity: activities[i]),
            if (i < activities.length - 1)
              const Divider(height: 1, indent: 72),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(activity.type);

    return ListTile(
      leading: _buildLeading(activity, visual),
      title: Text(
        activity.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: _buildSubtitle(activity),
      isThreeLine: activity.subtitle != null,
    );
  }

  Widget _buildLeading(ActivityModel activity, ({IconData icon, Color color}) visual) {
    final photoUrl = ProfileService.resolveProfilePhotoUrl(activity.photoUrl);

    if (photoUrl != null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: visual.color.withValues(alpha: 0.12),
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (_, _) {},
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: visual.color.withValues(alpha: 0.12),
      child: Icon(visual.icon, color: visual.color, size: 22),
    );
  }

  Widget? _buildSubtitle(ActivityModel activity) {
    final time = _relativeTime(activity.timestamp);

    if (activity.subtitle == null) {
      return Text(time);
    }

    return Text('${activity.subtitle} · $time');
  }

  ({IconData icon, Color color}) _visualFor(String type) {
    switch (type) {
      case 'complaint':
        return (icon: Icons.report_problem, color: AppColors.warning);
      case 'announcement':
        return (icon: Icons.campaign, color: AppColors.info);
      case 'tenant':
        return (icon: Icons.person_add, color: AppColors.primary);
      case 'room':
        return (icon: Icons.meeting_room, color: AppColors.secondary);
      case 'payment':
      default:
        return (icon: Icons.payments, color: AppColors.success);
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    }

    if (diff.inDays == 1) {
      return 'Kemarin';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    }

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

    return '${time.day} ${months[time.month - 1]} ${time.year}';
  }
}