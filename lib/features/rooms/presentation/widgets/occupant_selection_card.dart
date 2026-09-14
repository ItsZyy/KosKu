import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';

class OccupantSelectionCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final String? selectedUserId;
  final ValueChanged<Map<String, dynamic>> onSelected;

  const OccupantSelectionCard({
    super.key,
    required this.users,
    required this.selectedUserId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Penghuni', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Pilih penghuni yang belum memiliki kamar.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (users.isEmpty)
            Text(
              'Belum ada data penghuni.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            RadioGroup<String>(
              groupValue: selectedUserId,
              onChanged: (value) {
                if (value == null) return;

                final user = users.firstWhere((item) => item['id'] == value);

                onSelected(user);
              },
              child: Column(children: users.map(_buildUserItem).toList()),
            ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final userId = user['id'] as String;
    final name = user['name'] as String? ?? 'Tanpa Nama';
    final phone = user['phone'] as String?;
    final roomNumber = user['room_number'] as String?;
    final hasRoom = roomNumber != null && roomNumber.isNotEmpty;
    final isSelected = selectedUserId == userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: hasRoom ? null : () => onSelected(user),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasRoom
                ? AppColors.inputBackground
                : isSelected
                ? AppColors.primarySoft
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: hasRoom
                    ? AppColors.border
                    : AppColors.primarySoft,
                child: Icon(
                  Icons.person_outline,
                  color: hasRoom ? AppColors.textDisabled : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: hasRoom
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      hasRoom
                          ? 'Penghuni Kamar $roomNumber'
                          : 'Belum memiliki kamar',
                      style: AppTextStyles.caption.copyWith(
                        color: hasRoom
                            ? AppColors.textDisabled
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasRoom)
                const Icon(Icons.lock_outline, color: AppColors.textDisabled)
              else
                Radio<String>(value: userId, activeColor: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
