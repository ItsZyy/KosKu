import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'section_card.dart';

class RoomBasicInfoCard extends StatelessWidget {
  final TextEditingController roomNumberController;
  final TextEditingController priceController;
  final int capacity;
  final TextEditingController descriptionController;
  final ValueChanged<int> onCapacityChanged;
  final String? Function(String?)? roomNumberValidator;
  final String? Function(String?)? priceValidator;

  const RoomBasicInfoCard({
    super.key,
    required this.roomNumberController,
    required this.priceController,
    required this.capacity,
    required this.descriptionController,
    required this.onCapacityChanged,
    this.roomNumberValidator,
    this.priceValidator,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Informasi Dasar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: 'Nomor Kamar'),
          const SizedBox(height: 8),
          TextFormField(
            controller: roomNumberController,
            keyboardType: TextInputType.text,
            validator: roomNumberValidator,
            decoration: _decoration(
              hintText: 'Contoh: 09',
              prefixIcon: Icons.meeting_room_outlined,
            ),
          ),
          const SizedBox(height: 16),
          _Label(text: 'Harga Sewa / Bulan'),
          const SizedBox(height: 8),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            validator: priceValidator,
            decoration: _decoration(
              hintText: 'Contoh: 1.500.000',
              prefixText: 'Rp ',
              prefixIcon: Icons.payments_outlined,
            ),
          ),
          const SizedBox(height: 16),
          _Label(text: 'Kapasitas Penghuni'),
          const SizedBox(height: 8),
          _CapacityStepper(
            value: capacity,
            onChanged: onCapacityChanged,
          ),
          const SizedBox(height: 16),
          _Label(text: 'Deskripsi'),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: _decoration(
              hintText: 'Contoh: Kamar di pojok dekat kamar mandi...',
              prefixIcon: Icons.notes_outlined,
              alignPrefixWithLabel: false,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration({
    required String hintText,
    IconData? prefixIcon,
    String? prefixText,
    bool alignPrefixWithLabel = true,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: AppColors.textSecondary,
              size: 22,
            )
          : null,
      prefixIconConstraints: alignPrefixWithLabel
          ? null
          : const BoxConstraints(minWidth: 0, minHeight: 0),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelLarge,
    );
  }
}

class _CapacityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CapacityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onTap: () {
              if (canDecrease) onChanged(value - 1);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            enabled: true,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : AppColors.textDisabled;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}