import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterStepIndicator extends StatelessWidget {
  final int currentStep;

  const RegisterStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepItem(
          step: 1,
          label: 'Akun',
          isActive: currentStep >= 1,
          isCompleted: currentStep > 1,
        ),
        _StepLine(isActive: currentStep > 1),
        _StepItem(
          step: 2,
          label: 'Data Pribadi',
          isActive: currentStep >= 2,
          isCompleted: currentStep > 2,
        ),
        _StepLine(isActive: currentStep > 2),
        _StepItem(
          step: 3,
          label: 'Kamar',
          isActive: currentStep >= 3,
          isCompleted: currentStep > 3,
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.border;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.inputBackground,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, size: 18, color: AppColors.onPrimary)
              : Text(
                  '$step',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isActive
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 22, left: 8, right: 8),
        color: isActive ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
