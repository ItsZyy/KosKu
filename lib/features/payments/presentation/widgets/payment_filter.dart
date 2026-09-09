import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PaymentFilter extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const PaymentFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Pembayaran',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Cari penghuni atau kamar...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: AppColors.textSecondary,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Status Pembayaran',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Lunas'),
                  _buildFilterChip('Menunggu'),
                  _buildFilterChip('Belum Bayar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (_) {
          onFilterChanged(filter);
        },
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : AppColors.border.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
