// Widget untuk UserDashboardScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../payments/data/models/payment_status.dart';
import '../../../payments/presentation/screens/payment_detail_screen.dart';

class UserDashboardPaymentCard extends StatelessWidget {
  final Map<String, dynamic>? payment;

  const UserDashboardPaymentCard({super.key, required this.payment});

  String _formatAmount(dynamic amount) {
    return formatRupiah(amount);
  }

  // Status tampilan ditentukan dari status, bukti, metode, dan jatuh tempo.
  _PaymentDisplayState _getDisplayState() {
    final status = payment?['status']?.toString().toLowerCase() ?? '';
    final proofUrl = payment?['proof_url']?.toString();
    final hasProof = proofUrl != null && proofUrl.isNotEmpty;
    final isCash = payment?['payment_method']?.toString().toLowerCase() == 'cash';

    if (status == 'dikonfirmasi') {
      return _PaymentDisplayState.confirmed;
    }

    if (status == 'ditolak') {
      return _PaymentDisplayState.rejected;
    }

    if (status == 'menunggu' && (hasProof || isCash)) {
      return _PaymentDisplayState.waitingConfirmation;
    }

    if (status == 'menunggu') {
      final dueDate = DateTime.tryParse(payment?['due_date']?.toString() ?? '');

      if (isDueDatePassed(dueDate)) {
        return _PaymentDisplayState.late;
      }

      return _PaymentDisplayState.notPaid;
    }

    return _PaymentDisplayState.notPaid;
  }

  @override
  Widget build(BuildContext context) {
    final amount = payment?['amount'];
    final displayState = _getDisplayState();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Tagihan', style: AppTextStyles.bodySmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBackground(displayState),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(displayState),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: _getStatusColor(displayState),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(_formatAmount(amount), style: AppTextStyles.headlineMedium),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canNavigate(displayState)
                  ? () {
                      final paymentId = payment?['id']?.toString();
                      if (paymentId == null || paymentId.isEmpty) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentDetailScreen(
                            paymentId: paymentId,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: Icon(
                _getButtonIcon(displayState),
                size: 18,
              ),
              label: Text(_getButtonLabel(displayState)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: _getDisabledBgColor(displayState),
                disabledForegroundColor: _getDisabledFgColor(displayState),
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

  bool _canNavigate(_PaymentDisplayState state) {
    return state == _PaymentDisplayState.notPaid ||
        state == _PaymentDisplayState.rejected ||
        state == _PaymentDisplayState.late;
  }

  String _getStatusLabel(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return 'Lunas';
      case _PaymentDisplayState.waitingConfirmation:
        return 'Menunggu Konfirmasi';
      case _PaymentDisplayState.rejected:
        return 'Ditolak';
      case _PaymentDisplayState.notPaid:
        return 'Belum Bayar';
      case _PaymentDisplayState.late:
        return 'Telat Bayar';
    }
  }

  String _getButtonLabel(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return 'Lunas';
      case _PaymentDisplayState.waitingConfirmation:
        return 'Menunggu Konfirmasi';
      case _PaymentDisplayState.rejected:
        return 'Kirim Ulang';
      case _PaymentDisplayState.notPaid:
        return 'Bayar Sekarang';
      case _PaymentDisplayState.late:
        return 'Bayar Sekarang';
    }
  }

  IconData _getButtonIcon(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return Icons.check_circle_rounded;
      case _PaymentDisplayState.waitingConfirmation:
        return Icons.hourglass_top_rounded;
      case _PaymentDisplayState.rejected:
        return Icons.refresh_rounded;
      case _PaymentDisplayState.notPaid:
        return Icons.receipt_long_rounded;
      case _PaymentDisplayState.late:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getStatusColor(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return AppColors.success;
      case _PaymentDisplayState.waitingConfirmation:
        return AppColors.warning;
      case _PaymentDisplayState.rejected:
        return AppColors.error;
      case _PaymentDisplayState.notPaid:
        return AppColors.warning;
      case _PaymentDisplayState.late:
        return AppColors.error;
    }
  }

  Color _getStatusBackground(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return AppColors.successSoft;
      case _PaymentDisplayState.waitingConfirmation:
        return AppColors.warningSoft;
      case _PaymentDisplayState.rejected:
        return AppColors.errorSoft;
      case _PaymentDisplayState.notPaid:
        return AppColors.warningSoft;
      case _PaymentDisplayState.late:
        return AppColors.errorSoft;
    }
  }

  Color _getDisabledBgColor(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return AppColors.successSoft;
      case _PaymentDisplayState.waitingConfirmation:
        return AppColors.warningSoft;
      case _PaymentDisplayState.rejected:
        return AppColors.primary;
      case _PaymentDisplayState.notPaid:
        return AppColors.primary;
      case _PaymentDisplayState.late:
        return AppColors.primary;
    }
  }

  Color _getDisabledFgColor(_PaymentDisplayState state) {
    switch (state) {
      case _PaymentDisplayState.confirmed:
        return AppColors.success;
      case _PaymentDisplayState.waitingConfirmation:
        return AppColors.warning;
      case _PaymentDisplayState.rejected:
        return AppColors.onPrimary;
      case _PaymentDisplayState.notPaid:
        return AppColors.onPrimary;
      case _PaymentDisplayState.late:
        return AppColors.onPrimary;
    }
  }
}

enum _PaymentDisplayState {
  notPaid,
  waitingConfirmation,
  confirmed,
  rejected,
  late,
}
