import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';

/// Menampilkan rincian tagihan (breakdown) dari `payment_items`.
///
/// Total resmi tetap memakai `Payment.amount` (dihitung di database).
/// Item di sini hanya untuk menampilkan rincian per-fasilitas.
class PaymentItemsSection extends StatelessWidget {
  final Payment payment;

  const PaymentItemsSection({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final items = payment.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Pisahkan item kamar (rent) vs fasilitas.
    final roomItem = items.where((i) {
      final type = (i.itemType ?? '').toLowerCase();
      return type == 'kamar' || type == 'rent' || type == 'sewa';
    }).toList();

    final facilityItems = items.where((i) {
      final type = (i.itemType ?? '').toLowerCase();
      return type != 'kamar' && type != 'rent' && type != 'sewa';
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (roomItem.isNotEmpty) ...[
            Text(
              'Kamar',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...roomItem.map((item) => _ItemRow(item: item)),
            const SizedBox(height: 16),
          ],

          if (facilityItems.isNotEmpty) ...[
            Text(
              'Fasilitas',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...facilityItems.map((item) => _ItemRow(item: item)),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final PaymentItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final label = item.description?.isNotEmpty == true
        ? item.description!
        : (item.itemType ?? 'Item');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(width: 12),
          Text(
            PaymentFormatter.rupiah(item.amount),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
