import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';
import 'payment_status_badge.dart';

class PaymentDetailHeader extends StatelessWidget {
  final Payment payment;
  final bool isAdmin;

  const PaymentDetailHeader({
    super.key,
    required this.payment,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tagihan ${PaymentFormatter.period(payment.period)}',
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 4),
              if (payment.roomNumber != null)
                Text(
                  'Kamar ${payment.roomNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (isAdmin && payment.userName != null) ...[
                const SizedBox(height: 4),
                Text(
                  payment.userName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        PaymentStatusBadge(status: payment.status),
      ],
    );
  }
}
