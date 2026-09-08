import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';
import 'payment_status_badge.dart';

class AdminPaymentHeader extends StatelessWidget {
  final Payment payment;

  const AdminPaymentHeader({super.key, required this.payment});

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
            ],
          ),
        ),
        const SizedBox(width: 12),
        PaymentStatusBadge(
          status: payment.status,
          hasProof: payment.hasSubmittedPayment,
        ),
      ],
    );
  }
}