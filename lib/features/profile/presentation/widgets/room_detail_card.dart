import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.home_outlined),
                SizedBox(width: 10),
                Text(
                  'Detail Kamar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _RoomInfoRow(title: 'Nomor Kamar', value: roomNumber),

            const Divider(height: 24),

            _RoomInfoRow(
              title: 'Kontrak',
              value: '$contractStart - $contractEnd',
            ),

            const Divider(height: 24),

            _RoomInfoRow(title: 'Harga Sewa', value: rentPrice),

            const Divider(height: 24),

            _RoomInfoRow(title: 'Tanggal Jatuh Tempo', value: dueDate),

            const Divider(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Fasilitas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: facilities.isEmpty
                      ? const Text('-', textAlign: TextAlign.right)
                      : Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 6,
                          runSpacing: 6,
                          children: facilities.map((facility) {
                            return Chip(
                              label: Text(facility),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                ),
              ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value.isNotEmpty ? value : '-',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
