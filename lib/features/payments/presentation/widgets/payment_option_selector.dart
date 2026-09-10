import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum PaymentOption { full, installment }

class PaymentOptionSelector extends StatelessWidget {
  final PaymentOption selectedOption;
  final ValueChanged<PaymentOption> onChanged;

  const PaymentOptionSelector({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilihan Pembayaran',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PaymentOptionCard(
                title: 'Lunas',
                selected: selectedOption == PaymentOption.full,
                backgroundColor: AppColors.success.withValues(alpha: 0.10),
                onTap: () {
                  onChanged(PaymentOption.full);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentOptionCard(
                title: 'Cicil',
                selected: selectedOption == PaymentOption.installment,
                backgroundColor: AppColors.warning.withValues(alpha: 0.10),
                onTap: () {
                  onChanged(PaymentOption.installment);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final bool selected;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.selected,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: selected ? backgroundColor : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
