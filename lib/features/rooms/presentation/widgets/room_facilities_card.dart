import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'section_card.dart';

class RoomFacilityOption {
  final String key;
  final String label;
  final IconData icon;

  const RoomFacilityOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class RoomFacilitiesCard extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final List<RoomFacilityOption> options;
  final bool enabled;

  const RoomFacilitiesCard({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.options,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Fasilitas',
      subtitle: 'Pilih satu atau lebih fasilitas yang tersedia di kamar.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 360 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selected.contains(option.key);
              return _FacilityItem(
                option: option,
                selected: isSelected,
                enabled: enabled,
                onTap: () => _toggle(option.key),
              );
            },
          );
        },
      ),
    );
  }

  void _toggle(String key) {
    final next = List<String>.from(selected);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    onChanged(next);
  }
}

class _FacilityItem extends StatelessWidget {
  final RoomFacilityOption option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _FacilityItem({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primarySoft : AppColors.surface;
    final borderColor = selected ? AppColors.primary : AppColors.border;
    final iconColor = selected ? AppColors.primary : AppColors.textSecondary;
    final textColor = selected ? AppColors.primary : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(option.icon, color: iconColor, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.onPrimary,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}