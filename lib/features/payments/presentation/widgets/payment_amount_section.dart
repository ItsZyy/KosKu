import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import 'payment_type_selector.dart';

class PaymentAmountSection extends StatelessWidget {
  final PaymentType paymentType;
  final int totalAmount;
  final TextEditingController controller;

  const PaymentAmountSection({
    super.key,
    required this.paymentType,
    required this.totalAmount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = paymentType == PaymentType.installment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nominal yang akan dibayarkan', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isInstallment
                ? AppColors.surface
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isInstallment
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Rp',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isInstallment
                    ? TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nominal',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      )
                    : Text(
                        PaymentFormatter.rupiah(totalAmount),
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
