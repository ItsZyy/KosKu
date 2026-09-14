// Widget untuk UserProfileScreen dan AdminProfileScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Keluar / Logout',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
        ),
        onTap: onLogout,
      ),
    );
  }
}
