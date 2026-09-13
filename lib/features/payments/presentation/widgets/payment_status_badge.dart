// Widget untuk PaymentDetailScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_status.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;
  final bool hasProof;
  final bool isCash;
  final DateTime? dueDate;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.hasProof = false,
    this.isCash = false,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color backgroundColor;
    final Color textColor;
    final IconData? icon;

    if (PaymentStatus.tryParse(status) == null) {
      label = status;
      backgroundColor = AppColors.warningSoft;
      textColor = AppColors.warning;
      icon = Icons.access_time;
    } else {
      switch (resolvePaymentDisplayStatus(
        status: status,
        hasProof: hasProof,
        isCash: isCash,
        dueDate: dueDate,
      )) {
        case PaymentDisplayStatus.paid:
          label = PaymentDisplayStatus.paid.label;
          backgroundColor = AppColors.successSoft;
          textColor = AppColors.success;
          icon = Icons.check_circle;
        case PaymentDisplayStatus.rejected:
          label = PaymentDisplayStatus.rejected.label;
          backgroundColor = AppColors.errorSoft;
          textColor = AppColors.error;
          icon = Icons.cancel;
        case PaymentDisplayStatus.waitingConfirmation:
          label = PaymentDisplayStatus.waitingConfirmation.label;
          backgroundColor = AppColors.warningSoft;
          textColor = AppColors.warning;
          icon = Icons.access_time;
        case PaymentDisplayStatus.notPaid:
          label = PaymentDisplayStatus.notPaid.label;
          backgroundColor = AppColors.warningSoft;
          textColor = AppColors.warning;
          icon = Icons.schedule;
        case PaymentDisplayStatus.late:
          label = PaymentDisplayStatus.late.label;
          backgroundColor = AppColors.errorSoft;
          textColor = AppColors.error;
          icon = Icons.error_outline;
      }
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
