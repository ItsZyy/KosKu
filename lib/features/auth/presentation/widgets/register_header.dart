import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterHeader extends StatelessWidget {
  final int currentStep;

  const RegisterHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final titles = ['Buat Akun', 'Data Pribadi', 'Pilih Kamar'];

    final descriptions = [
      'Daftar akun untuk mulai menggunakan KosKu',
      'Lengkapi data diri dan kontak darurat',
      'Pilih kamar yang ingin kamu tempati',
    ];

    return Column(
      children: [
        Text(
          titles[currentStep - 1],
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          descriptions[currentStep - 1],
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
