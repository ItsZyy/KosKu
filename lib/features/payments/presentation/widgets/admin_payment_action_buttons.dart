import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminPaymentActionButtons extends StatelessWidget {
  final VoidCallback? onReject;
  final VoidCallback? onConfirm;
  final bool isBusy;

  const AdminPaymentActionButtons({
    super.key,
    required this.onReject,
    required this.onConfirm,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: isBusy ? null : onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tolak',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: isBusy ? null : onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Konfirmasi',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.onSuccess,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}