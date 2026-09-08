import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';

class PaymentBillSection extends StatelessWidget {
  final Payment payment;
  final List<PaymentItem>? items;

  const PaymentBillSection({super.key, required this.payment, this.items});

  @override
  Widget build(BuildContext context) {
    final displayItems = items ?? payment.items;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 2,
            offset: Offset(0, 1),
            color: Color.fromRGBO(0, 0, 0, 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rincian Tagihan - '
                  '${PaymentFormatter.period(payment.period)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (displayItems.isEmpty)
            Text(
              'Tidak ada rincian tagihan.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ..._buildItems(displayItems),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                PaymentFormatter.rupiah(payment.amount),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(List<PaymentItem> items) {
    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      widgets.add(
        _BillRow(
          label: _getItemLabel(item),
          amount: item.amount,
          description: item.description,
        ),
      );

      if (i < items.length - 1) {
        widgets.add(const Divider(height: 24, color: AppColors.divider));
      }
    }

    return widgets;
  }

  String _getItemLabel(PaymentItem item) {
    switch (item.itemType?.toLowerCase()) {
      case 'room':
      case 'kamar':
      case 'sewa':
        return 'Sewa Kamar';

      case 'utilities':
      case 'utility':
      case 'listrik':
      case 'air':
        return 'Listrik & Air';

      case 'wifi':
      case 'internet':
        return 'Internet';

      default:
        return item.description?.isNotEmpty == true
            ? item.description!
            : 'Tagihan';
    }
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final int amount;
  final String? description;

  const _BillRow({required this.label, required this.amount, this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          PaymentFormatter.rupiah(amount),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
