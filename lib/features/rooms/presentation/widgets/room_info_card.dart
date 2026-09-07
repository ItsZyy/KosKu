import 'package:flutter/material.dart';
import 'package:kosku/features/rooms/data/models/room_model.dart';

class RoomInfoCard extends StatelessWidget {
  final RoomModel room;

  const RoomInfoCard({super.key, required this.room});

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
          // Nomor kamar + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Kamar ${room.roomNumber}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),

          // Deskripsi
          if (room.description != null &&
              room.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              room.description!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 20),

          const Divider(height: 1),

          const SizedBox(height: 18),

          // Label harga
          Text(
            'HARGA KAMAR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 6),

          // Harga
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(room.price),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '/bulan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Kapasitas
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 19,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Kapasitas ${room.capacity} orang',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = room.status.toLowerCase();

    final String label;
    final IconData icon;

    switch (status) {
      case 'terisi':
        label = 'Terisi';
        icon = Icons.person;
        break;

      case 'perbaikan':
        label = 'Perbaikan';
        icon = Icons.build_outlined;
        break;

      case 'booking':
      case 'dipesan':
        label = 'Booking';
        icon = Icons.event_available_outlined;
        break;

      case 'kosong':
      default:
        label = 'Kosong';
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(context, status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _getStatusColor(context, status)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(context, status),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'terisi':
        return Colors.orange;

      case 'perbaikan':
        return Colors.red;

      case 'booking':
      case 'dipesan':
        return Colors.blue;

      case 'kosong':
      default:
        return Colors.green;
    }
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(value[i]);
    }

    return 'Rp$buffer';
  }
}
