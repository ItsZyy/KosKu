import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'qris_screen.dart';

class PaymentMethodCard extends StatelessWidget {
  final List<Map<String, dynamic>> paymentInfo;

  const PaymentMethodCard({super.key, required this.paymentInfo});

  Future<void> _copyAccountNumber(
    BuildContext context,
    String accountNumber,
  ) async {
    await Clipboard.setData(ClipboardData(text: accountNumber));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor rekening berhasil disalin'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openQris(BuildContext context, String imageUrl) {
    QrisScreen.show(context, imageUrl: imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final methods = <Widget>[];

    for (final info in paymentInfo) {
      final type = info['type']?.toString().toLowerCase();

      if (type == 'cash') {
        methods.add(_buildCashMethod());
      } else if (type == 'qris') {
        final qrisImageUrl = info['qris_image_url']?.toString();

        if (qrisImageUrl != null && qrisImageUrl.isNotEmpty) {
          methods.add(_buildQrisMethod(context, qrisImageUrl));
        }
      } else if (type == 'bank') {
        final bankName = info['bank_name']?.toString();
        final accountNumber = info['account_number']?.toString();
        final accountName = info['account_name']?.toString();

        if (bankName != null &&
            bankName.isNotEmpty &&
            accountNumber != null &&
            accountNumber.isNotEmpty &&
            accountName != null &&
            accountName.isNotEmpty) {
          methods.add(
            _buildBankMethod(context, bankName, accountNumber, accountName),
          );
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(),
            if (methods.isNotEmpty) ...[
              const SizedBox(height: 22),
              for (int i = 0; i < methods.length; i++) ...[
                methods[i],
                if (i < methods.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1),
                  ),
              ],
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'Metode pembayaran belum tersedia.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.credit_card_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Metode Pembayaran',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildBankMethod(
    BuildContext context,
    String bankName,
    String accountNumber,
    String accountName,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMethodIcon(Icons.account_balance_rounded),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer Bank',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bankName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Bank',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bankName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No. Rekening',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            accountNumber,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _copyAccountNumber(context, accountNumber);
                          },
                          tooltip: 'Salin nomor rekening',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Atas Nama',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrisMethod(BuildContext context, String imageUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMethodIcon(Icons.qr_code_2_rounded),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QRIS',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Scan QRIS untuk melakukan pembayaran.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {
            _openQris(context, imageUrl);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: const Text('Lihat QRIS'),
        ),
      ],
    );
  }

  Widget _buildCashMethod() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMethodIcon(Icons.payments_rounded),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembayaran Tunai',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Bayar langsung kepada pemilik kos.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodIcon(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24, color: AppColors.primary),
    );
  }
}
