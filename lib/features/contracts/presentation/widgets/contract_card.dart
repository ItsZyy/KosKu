// Widget untuk card kontrak di halaman daftar kontrak (admin).
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../data/models/contract_model.dart';
import 'contract_status_badge.dart';

class ContractCard extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback? onTap;

  const ContractCard({super.key, required this.contract, this.onTap});

  String _formatRupiah(double? amount) {
    if (amount == null) {
      return '-';
    }

    final text = amount.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  String _formatPeriod(String? start, String? end) {
    String format(String? value) {
      if (value == null) {
        return '-';
      }

      final date = DateTime.tryParse(value);

      if (date == null) {
        return value;
      }

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    return '${format(start)} - ${format(end)}';
  }

  Widget _buildAvatar({String? photoUrl}) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: hasPhoto
          ? null
          : Icon(Icons.person, size: 24, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPhotoUrl = ProfileService.resolveProfilePhotoUrl(
      contract.profilePhotoUrl,
    );

    final roomNumber = contract.roomNumber ?? '-';

    final period = _formatPeriod(contract.contractStart, contract.contractEnd);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(photoUrl: resolvedPhotoUrl),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contract.displayName,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kamar $roomNumber',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ContractStatusBadge(status: contract.status),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(height: 1, color: AppColors.divider),

              const SizedBox(height: 12),

              _buildInfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Periode Kontrak',
                value: period,
              ),

              const SizedBox(height: 8),

              _buildInfoRow(
                icon: Icons.payments_outlined,
                label: 'Harga Sewa',
                value: _formatRupiah(contract.rentPrice),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),

        const SizedBox(width: 8),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
