import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/services/payment_method_service.dart';

class AdminPaymentMethodCard extends StatefulWidget {
  final PaymentMethodModel paymentMethod;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminPaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AdminPaymentMethodCard> createState() => _AdminPaymentMethodCardState();
}

class _AdminPaymentMethodCardState extends State<AdminPaymentMethodCard> {
  final PaymentMethodService _paymentMethodService = PaymentMethodService();

  String? _qrisSignedUrl;
  bool _isLoadingQris = false;

  bool get _isBank => widget.paymentMethod.type == 'bank';

  bool get _isQris => widget.paymentMethod.type == 'qris';

  bool get _isCash => widget.paymentMethod.type == 'cash';

  @override
  void initState() {
    super.initState();

    if (_isQris) {
      _loadQrisImage();
    }
  }

  Future<void> _loadQrisImage() async {
    final path = widget.paymentMethod.qrisImageUrl;

    if (path == null || path.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingQris = true;
    });

    try {
      final signedUrl = await _paymentMethodService.getQrisSignedUrl(path);

      if (!mounted) return;

      setState(() {
        _qrisSignedUrl = signedUrl;
        _isLoadingQris = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _qrisSignedUrl = null;
        _isLoadingQris = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isBank
                        ? Icons.account_balance_outlined
                        : _isQris
                        ? Icons.qr_code_2_outlined
                        : Icons.payments_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isBank
                            ? 'Rekening Bank'
                            : _isQris
                            ? 'QRIS'
                            : 'Tunai',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isBank
                            ? widget.paymentMethod.bankName ?? '-'
                            : _isQris
                            ? 'Metode pembayaran QRIS'
                            : 'Pembayaran langsung kepada pemilik',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isCash) ...[
                  IconButton(
                    onPressed: widget.onEdit,
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: widget.onDelete,
                    tooltip: 'Hapus',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (_isBank) _buildBankInfo(),
            if (_isQris) _buildQrisInfo(),
            if (_isCash) _buildCashInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nomor Rekening',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.paymentMethod.accountNumber ?? '-',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Atas Nama',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.paymentMethod.accountName ?? '-',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'QRIS',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingQris)
            const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_qrisSignedUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 400),
                color: Colors.white,
                child: Image.network(
                  _qrisSignedUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildQrisError();
                  },
                ),
              ),
            )
          else
            _buildQrisError(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCashInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pembayaran tunai dilakukan langsung '
              'kepada pemilik kos dan dikonfirmasi '
              'melalui aplikasi.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisError() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, size: 40),
          const SizedBox(height: 10),
          Text('QRIS tidak dapat ditampilkan', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text(
            'Pastikan file QRIS tersedia di storage.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
