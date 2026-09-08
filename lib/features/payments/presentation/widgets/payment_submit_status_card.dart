import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum PaymentSubmitStatus { waiting, rejected, confirmed }

class PaymentSubmitStatusCard extends StatelessWidget {
  final PaymentSubmitStatus status;

  const PaymentSubmitStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle, backgroundColor, foregroundColor) =
        switch (status) {
      PaymentSubmitStatus.waiting => (
          Icons.hourglass_top_rounded,
          'Menunggu Konfirmasi',
          'Bukti pembayaran sudah dikirim dan sedang menunggu verifikasi admin.',
          AppColors.warningSoft,
          AppColors.warning,
        ),
      PaymentSubmitStatus.rejected => (
          Icons.cancel_outlined,
          'Pembayaran Ditolak',
          'Bukti pembayaran ditolak admin. Silakan kirim ulang dengan bukti yang valid.',
          AppColors.errorSoft,
          AppColors.error,
        ),
      PaymentSubmitStatus.confirmed => (
          Icons.check_circle_outline,
          'Pembayaran Dikonfirmasi',
          'Pembayaran sudah dikonfirmasi oleh admin.',
          AppColors.successSoft,
          AppColors.success,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foregroundColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}