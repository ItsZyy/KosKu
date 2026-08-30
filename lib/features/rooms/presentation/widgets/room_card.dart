import 'package:flutter/material.dart';

import '../../data/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback? onTap;

  const RoomCard({super.key, required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.imageUrl != null && room.imageUrl!.isNotEmpty)
              Image.network(
                room.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  );
                },
              )
            else
              const SizedBox(
                width: double.infinity,
                height: 180,
                child: Center(child: Icon(Icons.meeting_room, size: 48)),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kamar ${room.roomNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        room.status,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text('Rp ${room.price.toStringAsFixed(0)} / bulan'),

                  const SizedBox(height: 4),

                  Text('Kapasitas: ${room.capacity} orang'),

                  const SizedBox(height: 4),

                  Text('Fasilitas: ${room.facilities}'),

                  const SizedBox(height: 8),

                  Text(
                    room.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Lihat Detail'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
