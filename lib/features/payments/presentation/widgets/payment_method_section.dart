import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodSection extends StatelessWidget {
  final List<PaymentMethodModel> methods;
  final PaymentMethodModel? selectedMethod;
  final ValueChanged<PaymentMethodModel> onChanged;
  final String? qrisSignedUrl;

  const PaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onChanged,
    this.qrisSignedUrl,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Metode Pembayaran',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          if (methods.isEmpty)
            Text(
              'Belum ada metode pembayaran.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...methods.map(
              (method) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PaymentMethodTile(
                  method: method,
                  selected: selectedMethod?.id == method.id,
                  onTap: () {
                    onChanged(method);
                  },
                ),
              ),
            ),

          if (selectedMethod != null) ...[
            const SizedBox(height: 8),
            _buildMethodDetail(selectedMethod!),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodDetail(PaymentMethodModel method) {
    if (method.isBank) return _BankDetail(method: method);
    if (method.isQris) return _QrisDetail(signedUrl: qrisSignedUrl);
    return const SizedBox.shrink();
  }
}

class _BankDetail extends StatelessWidget {
  final PaymentMethodModel method;

  const _BankDetail({required this.method});

  Future<void> _copyAccountNumber(BuildContext context) async {
    if (method.accountNumber == null || method.accountNumber!.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: method.accountNumber!));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor rekening berhasil disalin'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                method.bankName ?? 'Bank',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (method.accountNumber != null && method.accountNumber!.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    method.accountNumber!,
                    style: AppTextStyles.headlineSmall,
                  ),
                ),
                GestureDetector(
                  onTap: () => _copyAccountNumber(context),
                  child: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
          if (method.accountName != null && method.accountName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'a.n. ${method.accountName!}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QrisDetail extends StatelessWidget {
  final String? signedUrl;

  const _QrisDetail({this.signedUrl});

  @override
  Widget build(BuildContext context) {
    if (signedUrl == null || signedUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'QRIS',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Scan QRIS',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              signedUrl!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined, size: 32),
                        SizedBox(height: 4),
                        Text('QRIS tidak dapat ditampilkan'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethodModel method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                method.isQris ? Icons.qr_code_2 : Icons.account_balance,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.isQris ? 'QRIS' : method.bankName ?? 'Bank',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
