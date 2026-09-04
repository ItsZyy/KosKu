import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';
import 'payment_status_badge.dart';

class PaymentHeaderCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onPay;

  const PaymentHeaderCard({
    super.key,
    required this.payment,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final periodLabel = PaymentFormatter.period(payment.period);
    final totalDisplay = PaymentFormatter.rupiah(payment.totalAmount);
    final roomNumber = payment.roomNumber ?? '-';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDisabled.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(periodLabel),
                    const SizedBox(height: 20),
                    _buildNominal(totalDisplay),
                    const SizedBox(height: 20),
                    _buildBreakdown(roomNumber),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    _buildTotal(totalDisplay),
                    const SizedBox(height: 20),
                    _buildPayButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String periodLabel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TAGIHAN',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                periodLabel,
                style: AppTextStyles.headlineMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PaymentStatusBadge(status: payment.status),
      ],
    );
  }

  Widget _buildNominal(String totalDisplay) {
    return Row(
      children: [
        const Icon(
          Icons.payments_outlined,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 10),
        Text(
          totalDisplay,
          style: AppTextStyles.displaySmall,
        ),
      ],
    );
  }

  Widget _buildBreakdown(String roomNumber) {
    if (!payment.hasBreakdown) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (payment.roomRent != null)
            _BreakdownRow(
              label: 'Sewa Kamar ($roomNumber)',
              value: PaymentFormatter.rupiah(payment.roomRent),
            ),
          if (payment.roomRent != null && payment.utilities != null)
            const SizedBox(height: 12),
          if (payment.utilities != null)
            _BreakdownRow(
              label: 'Listrik & Air',
              value: PaymentFormatter.rupiah(payment.utilities),
            ),
          if (payment.utilities != null && payment.otherAmount != null)
            const SizedBox(height: 12),
          if (payment.otherAmount != null)
            _BreakdownRow(
              label: 'Biaya Tambahan',
              value: PaymentFormatter.rupiah(payment.otherAmount),
            ),
        ],
      ),
    );
  }

  Widget _buildTotal(String totalDisplay) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Total Pembayaran',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          totalDisplay,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    if (!payment.isPending) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPay,
        child: const Text('Bayar Sekarang'),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;

  const _BreakdownRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
