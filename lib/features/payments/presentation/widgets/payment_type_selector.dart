import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum PaymentType { full, installment }

class PaymentTypeSelector extends StatelessWidget {
  final PaymentType selectedType;
  final ValueChanged<PaymentType> onChanged;

  const PaymentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Pembayaran',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PaymentTypeCard(
                title: 'LUNAS',
                selected: selectedType == PaymentType.full,
                backgroundColor: AppColors.success.withValues(alpha: 0.10),
                onTap: () {
                  onChanged(PaymentType.full);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentTypeCard(
                title: 'CICIL',
                selected: selectedType == PaymentType.installment,
                backgroundColor: AppColors.warning.withValues(alpha: 0.10),
                onTap: () {
                  onChanged(PaymentType.installment);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentTypeCard extends StatelessWidget {
  final String title;
  final bool selected;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _PaymentTypeCard({
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
