// Widget untuk aksi bawah detail kamar
import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';

class RoomDetailBottomAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool enabled;

  const RoomDetailBottomAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.edit_outlined,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: isEnabled ? onPressed : null,
            icon: Icon(icon),
            label: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
