import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();

    String label;
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (normalizedStatus == 'confirmed' || normalizedStatus == 'dikonfirmasi') {
      label = 'Lunas';
      backgroundColor = AppColors.successSoft;
      textColor = AppColors.success;
      icon = Icons.check_circle;
    } else if (normalizedStatus == 'rejected' || normalizedStatus == 'ditolak') {
      label = 'Ditolak';
      backgroundColor = AppColors.errorSoft;
      textColor = AppColors.error;
      icon = Icons.cancel;
    } else {
      label = 'Menunggu Pembayaran';
      backgroundColor = AppColors.warningSoft;
      textColor = AppColors.warning;
      icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
