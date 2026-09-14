import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ComplaintFilter extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final int total;
  final int menunggu;
  final int diproses;
  final int selesai;

  const ComplaintFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.total,
    required this.menunggu,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('Semua', total),
      ('Menunggu', menunggu),
      ('Diproses', diproses),
      ('Selesai', selesai),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final name = filter.$1;
          final count = filter.$2;
          final isSelected = selectedFilter == name;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                '$name ($count)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                onFilterChanged(name);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
