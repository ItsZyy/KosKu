import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../payments/data/models/payment_formatter.dart';
import '../../data/models/facility_model.dart';
import 'room_facility_catalog.dart';

class AdminFacilityCard extends StatelessWidget {
  final FacilityModel facility;
  final VoidCallback onEdit;

  const AdminFacilityCard({
    super.key,
    required this.facility,
    required this.onEdit,
  });

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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconForFacility(facility.name),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facility.name, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    facility.price > 0
                        ? PaymentFormatter.rupiah(facility.price.toInt())
                        : 'Gratis',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: facility.price > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (facility.description != null &&
                      facility.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      facility.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Harga'),
            ),
          ],
        ),
      ),
    );
  }
}
