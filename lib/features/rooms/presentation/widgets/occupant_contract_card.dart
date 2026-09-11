import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';

class OccupantContractCard extends StatelessWidget {
  final DateTime contractStart;
  final DateTime contractEnd;
  final double rentPrice;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const OccupantContractCard({
    super.key,
    required this.contractStart,
    required this.contractEnd,
    required this.rentPrice,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
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

          _buildInfoField(value: _formatCurrency(rentPrice), isBold: true),

          const SizedBox(height: 16),

          Text('Periode Pembayaran', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),

          _buildInfoField(value: '6 bulan sekali'),

          const SizedBox(height: 16),

          Text('Tanggal Pembayaran', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),

          _buildInfoField(value: 'Tanggal ${contractStart.day}'),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tanggal pembayaran otomatis mengikuti tanggal mulai kontrak dan pembayaran dilakukan setiap 6 bulan.',
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

  Widget _buildInfoField({required String value, bool isBold = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
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
