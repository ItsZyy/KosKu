import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';

class AdminPaymentInfoSection extends StatelessWidget {
  final Payment payment;

  const AdminPaymentInfoSection({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final type = _paymentTypeLabel(payment.paymentType);
    final isInstallment = (payment.paymentType ?? '').toLowerCase() == 'cicil';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 16),
          _buildRow('Jenis Pembayaran', type),
          const Divider(height: 24, color: AppColors.divider),
          _buildRow('Nominal', PaymentFormatter.rupiah(payment.amount)),
          if (isInstallment) ...[
            const SizedBox(height: 6),
            Text(
              'Schema payments belum menyimpan nominal cicilan aktual. '
              'Nominal di atas adalah total tagihan resmi.',
              style: AppTextStyles.bodySmall,
            ),
          ],
          const Divider(height: 24, color: AppColors.divider),
          _buildStatusRow(),
          const Divider(height: 24, color: AppColors.divider),
          _buildRow('Dibuat', PaymentFormatter.date(payment.createdAt)),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(Icons.payments_outlined, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          'Informasi Pembayaran',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    const statusInfo = {
      'menunggu': ('Menunggu', AppColors.warning, Icons.access_time),
      'dikonfirmasi': ('Lunas', AppColors.success, Icons.check_circle),
      'ditolak': ('Ditolak', AppColors.error, Icons.cancel),
    };

    final status = payment.status.toLowerCase();
    final (label, color, icon) =
        statusInfo[status] ??
        (payment.status, AppColors.textSecondary, Icons.help_outline);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Status',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _paymentTypeLabel(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'lunas':
      case 'full':
        return 'Lunas';
      case 'cicil':
      case 'installment':
        return 'Cicilan';
      default:
        return '-';
    }
  }
}
