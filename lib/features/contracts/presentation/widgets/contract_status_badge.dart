// Widget untuk menampilkan badge status kontrak.
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ContractStatusBadge extends StatelessWidget {
  /// Status kontrak dari `occupancies.status`:
  ///   - `active`   → kontrak berjalan
  ///   - `inactive` → kontrak selesai
  final String status;

  const ContractStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final bool isActive = normalized == 'active';

    final bool isUnknown = normalized != 'active' && normalized != 'inactive';

    final Color backgroundColor = isActive
        ? AppColors.successSoft
        : isUnknown
        ? AppColors.infoSoft
        : AppColors.warningSoft;

    final Color textColor = isActive
        ? AppColors.success
        : isUnknown
        ? AppColors.info
        : AppColors.warning;

    final IconData icon = isActive
        ? Icons.check_circle
        : isUnknown
        ? Icons.help_outline
        : Icons.archive_outlined;

    final String label = isActive
        ? 'Aktif'
        : isUnknown
        ? 'Kontrak'
        : 'Selesai';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
