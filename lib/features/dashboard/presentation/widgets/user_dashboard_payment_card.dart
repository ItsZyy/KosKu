import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../payments/presentation/screens/user_payment_screen.dart';

class UserDashboardPaymentCard extends StatelessWidget {
  final Map<String, dynamic>? payment;

  const UserDashboardPaymentCard({super.key, required this.payment});

  String _formatAmount(dynamic amount) {
    if (amount == null) {
      return '-';
    }

    final value = double.tryParse(amount.toString());

    if (value == null) {
      return '-';
    }

    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'dikonfirmasi':
        return AppColors.success;

      case 'menunggu':
        return AppColors.warning;

      case 'ditolak':
        return AppColors.error;

      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBackground(String? status) {
    switch (status?.toLowerCase()) {
      case 'dikonfirmasi':
        return AppColors.successSoft;

      case 'menunggu':
        return AppColors.warningSoft;

      case 'ditolak':
        return AppColors.errorSoft;

      default:
        return AppColors.inputBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = payment?['amount'];
    final status = payment?['status']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Tagihan', style: AppTextStyles.bodySmall),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBackground(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // JUMLAH TAGIHAN
          Text(_formatAmount(amount), style: AppTextStyles.headlineMedium),

          const SizedBox(height: 18),

          // BUTTON LIHAT PEMBAYARAN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserPaymentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Lihat Pembayaran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
