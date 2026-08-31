import 'package:flutter/material.dart';

import '../../data/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;

  final String? userName;
  final String? contractStart;
  final String? contractEnd;

  final VoidCallback? onDetail;
  final VoidCallback? onRent;
  final VoidCallback? onAddUser;
  final VoidCallback? onFinishRepair;

  const RoomCard({
    super.key,
    required this.room,
    this.userName,
    this.contractStart,
    this.contractEnd,
    this.onDetail,
    this.onRent,
    this.onAddUser,
    this.onFinishRepair,
  });

  bool get isOccupied => room.status == 'Terisi';

  bool get isEmpty => room.status == 'Kosong';

  bool get isRepair => room.status == 'Perbaikan';

  Color get statusColor {
    switch (room.status) {
      case 'Terisi':
        return Colors.green;
      case 'Kosong':
        return Colors.blue;
      case 'Perbaikan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (room.status) {
      case 'Terisi':
        return Icons.check_circle;
      case 'Kosong':
        return Icons.home_outlined;
      case 'Perbaikan':
        return Icons.build_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatRupiah(double amount) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                if (isOccupied) ...[const SizedBox(height: 12), _buildUser()],

                const SizedBox(height: 12),

                const Divider(),

                const SizedBox(height: 12),

                _buildPrice(),

                const SizedBox(height: 8),

                _buildRoomType(),

                if (isOccupied &&
                    contractStart != null &&
                    contractEnd != null) ...[
                  const SizedBox(height: 8),
                  _buildContract(),
                ],

                if (isRepair) ...[
                  const SizedBox(height: 8),
                  _buildRepairStatus(),
                ],

                const SizedBox(height: 16),

                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = room.imageUrl;

    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: Colors.white, size: 16),

                  const SizedBox(width: 5),

                  Text(
                    room.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Kamar ${room.roomNumber}',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),

        if (isOccupied)
          Text(
            'Terisi',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),

        if (isEmpty)
          const Text(
            'Belum ada penghuni',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),

        if (isRepair)
          const Text(
            'Perbaikan',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildUser() {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 20),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            userName ?? 'Belum ada penghuni',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Row(
      children: [
        const Icon(Icons.payments_outlined, size: 20),

        const SizedBox(width: 8),

        Text(
          _formatRupiah(room.price),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 5),

        const Text('/ bulan'),
      ],
    );
  }

  Widget _buildRoomType() {
    return const Row(
      children: [
        Icon(Icons.sell_outlined, size: 20),

        SizedBox(width: 8),

        Text('Sewa Kamar'),
      ],
    );
  }

  Widget _buildContract() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.calendar_month_outlined, size: 20),

        const SizedBox(width: 8),

        Expanded(child: Text('$contractStart - $contractEnd')),
      ],
    );
  }

  Widget _buildRepairStatus() {
    return const Row(
      children: [
        Icon(Icons.build_outlined, size: 20),

        SizedBox(width: 8),

        Text('Status: Perbaikan'),
      ],
    );
  }

  Widget _buildActions() {
    if (isOccupied) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onDetail,
          child: const Text('Lihat Detail Kamar'),
        ),
      );
    }

    if (isRepair) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onFinishRepair,
              child: const Text('Selesaikan Perbaikan'),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: onAddUser,
              child: const Text('Tambah User'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onRent,
            child: const Text('Sewakan'),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton(
            onPressed: onAddUser,
            child: const Text('Tambah User'),
          ),
        ),
      ],
    );
  }
}
