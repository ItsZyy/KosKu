// Widget untuk PaymentDetailScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_status.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;
  final bool hasProof;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.hasProof = false,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (PaymentStatus.tryParse(status)) {
      case PaymentStatus.confirmed:
        label = 'Lunas';
        backgroundColor = AppColors.successSoft;
        textColor = AppColors.success;
        icon = Icons.check_circle;
      case PaymentStatus.rejected:
        label = 'Ditolak';
        backgroundColor = AppColors.errorSoft;
        textColor = AppColors.error;
        icon = Icons.cancel;
      case PaymentStatus.pending:
        if (hasProof) {
          label = 'Menunggu Konfirmasi';
        } else {
          label = 'Belum Dibayar';
        }
        backgroundColor = AppColors.warningSoft;
        textColor = AppColors.warning;
        icon = Icons.access_time;
      case null:
        label = status;
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
