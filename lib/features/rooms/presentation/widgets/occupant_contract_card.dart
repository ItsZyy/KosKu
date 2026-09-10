import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';

class OccupantContractCard extends StatelessWidget {
  final DateTime contractStart;
  final DateTime contractEnd;
  final double rentPrice;
  final int paymentDay;

  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final ValueChanged<int> onPaymentDayChanged;

  const OccupantContractCard({
    super.key,
    required this.contractStart,
    required this.contractEnd,
    required this.rentPrice,
    required this.paymentDay,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onPaymentDayChanged,
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
          Text('Kontrak & Pembayaran', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),

          _buildDateField(
            label: 'Tanggal Mulai Kontrak',
            value: _formatDate(contractStart),
            icon: Icons.calendar_today_outlined,
            onTap: onSelectStartDate,
          ),

          const SizedBox(height: 12),

          _buildDateField(
            label: 'Tanggal Selesai Kontrak',
            value: _formatDate(contractEnd),
            icon: Icons.event_available_outlined,
            onTap: onSelectEndDate,
          ),

          const SizedBox(height: 16),

          Text('Harga Sewa (6 Bulan)', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _formatCurrency(rentPrice),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text('Periode Pembayaran', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),

          DropdownButtonFormField<int>(
            initialValue: 6,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 6, child: Text('6 bulan sekali')),
            ],
            onChanged: null,
          ),

          const SizedBox(height: 16),

          Text('Tanggal Pembayaran', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),

          DropdownButtonFormField<int>(
            initialValue: paymentDay,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: List.generate(31, (index) {
              final day = index + 1;

              return DropdownMenuItem(value: day, child: Text('Tanggal $day'));
            }),
            onChanged: (value) {
              if (value != null) {
                onPaymentDayChanged(value);
              }
            },
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tanggal pembayaran secara default mengikuti tanggal mulai kontrak.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 1),
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double value) {
    final formatted = value.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
  }
}
