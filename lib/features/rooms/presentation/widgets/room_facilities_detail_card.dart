import 'package:flutter/material.dart';
import 'package:kosku/features/rooms/data/models/facility_model.dart';

class RoomFacilitiesDetailCard extends StatelessWidget {
  final List<FacilityModel> facilities;

  const RoomFacilitiesDetailCard({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi & Fasilitas',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (facilities.isEmpty)
            _buildEmptyState(context)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: facilities.map((facility) {
                return _FacilityDetailItem(facility: facility);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Text(
            'Belum ada fasilitas',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityDetailItem extends StatelessWidget {
  final FacilityModel facility;

  const _FacilityDetailItem({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getFacilityIcon(facility.name),
              size: 19,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              facility.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFacilityIcon(String name) {
    final facilityName = name.toLowerCase();

    if (facilityName.contains('wifi')) {
      return Icons.wifi;
    }

    if (facilityName.contains('tv')) {
      return Icons.tv_outlined;
    }

    if (facilityName.contains('kasur')) {
      return Icons.bed_outlined;
    }

    if (facilityName.contains('lemari')) {
      return Icons.door_sliding_outlined;
    }

    if (facilityName.contains('meja')) {
      return Icons.desk_outlined;
    }

    if (facilityName.contains('kamar mandi')) {
      return Icons.bathtub_outlined;
    }

    return Icons.home_outlined;
  }
}
