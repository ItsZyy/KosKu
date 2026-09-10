import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_input_formatter.dart';
import '../../data/models/payment_formatter.dart';
import 'payment_option_selector.dart';

class PaymentAmountSection extends StatelessWidget {
  final PaymentOption option;
  final int totalAmount;
  final TextEditingController controller;

  const PaymentAmountSection({
    super.key,
    required this.option,
    required this.totalAmount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = option == PaymentOption.installment;

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
              if (isInstallment) ...[
                Text(
                  'Rp',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: isInstallment
                    ? TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MoneyInputFormatter(),
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
