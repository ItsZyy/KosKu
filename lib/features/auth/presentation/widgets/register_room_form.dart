import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../rooms/data/models/room_model.dart';
import 'primary_button.dart';

class RegisterRoomForm extends StatelessWidget {
  final List<RoomModel> rooms;
  final String? selectedRoomId;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final bool isLoading;

  const RegisterRoomForm({
    super.key,
    required this.rooms,
    required this.selectedRoomId,
    required this.onRoomSelected,
    required this.onBack,
    required this.onSubmit,
    this.isLoading = false,
  });

  String _formatPrice(double price) {
    final value = price.toStringAsFixed(0);

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$formatted / 6 bulan';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Kamar',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih kamar yang masih tersedia untuk ditempati.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        if (rooms.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 42,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada kamar tersedia',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Silakan coba lagi nanti.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          RadioGroup<String>(
            groupValue: selectedRoomId,
            onChanged: (value) {
              if (isLoading || value == null) {
                return;
              }

              onRoomSelected(value);
            },
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rooms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final room = rooms[index];
                final isSelected = room.id == selectedRoomId;

                return InkWell(
                  onTap: isLoading ? null : () => onRoomSelected(room.id),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.meeting_room_outlined,
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kamar ${room.roomNumber}',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                room.description ?? 'Tidak ada deskripsi',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatPrice(room.price),
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: room.id,
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Daftar',
                onPressed: selectedRoomId == null ? null : onSubmit,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
