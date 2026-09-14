// Widget untuk UserProfileScreen dan TenantProfileScreen
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomDetailCard extends StatelessWidget {
  final String roomNumber;
  final String contractStart;
  final String contractEnd;
  final String rentPrice;
  final String dueDate;
  final List<String> facilities;

  const RoomDetailCard({
    super.key,
    required this.roomNumber,
    required this.contractStart,
    required this.contractEnd,
    required this.rentPrice,
    required this.dueDate,
    required this.facilities,
  });

  IconData _getFacilityIcon(String facility) {
    final name = facility.toLowerCase();

    if (name.contains('wifi')) {
      return Icons.wifi_outlined;
    }

    if (name.contains('kasur')) {
      return Icons.bed_outlined;
    }

    if (name.contains('lemari')) {
      return Icons.door_sliding_outlined;
    }

    if (name.contains('meja')) {
      return Icons.table_restaurant_outlined;
    }

    if (name.contains('kamar mandi')) {
      return Icons.bathroom_outlined;
    }

    if (name.contains('tv')) {
      return Icons.tv_outlined;
    }

    return Icons.home_work_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Detail Kamar',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _RoomInfoRow(title: 'Nomor Kamar', value: roomNumber),
            const Divider(height: 24),
            _RoomInfoRow(
              title: 'Kontrak',
              value: '$contractStart - $contractEnd',
            ),
            const Divider(height: 24),
            _RoomInfoRow(title: 'Harga Sewa', value: rentPrice),
            const Divider(height: 24),
            _RoomInfoRow(title: 'Jatuh Tempo', value: dueDate),
            const Divider(height: 24),
            Text(
              'Fasilitas',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 14),
            facilities.isEmpty
                ? const Text('-', style: TextStyle(color: AppColors.textSecondary))
                : Wrap(
                    spacing: 18,
                    runSpacing: 16,
                    children: facilities.map((facility) {
                      return _FacilityItem(
                        icon: _getFacilityIcon(facility),
                        name: facility,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _RoomInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _RoomInfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 7,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: AppTextStyles.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _FacilityItem extends StatelessWidget {
  final IconData icon;
  final String name;

  const _FacilityItem({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 23, color: primary),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
