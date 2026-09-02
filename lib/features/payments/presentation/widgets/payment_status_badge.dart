import 'package:flutter/material.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();

    String label;
    IconData icon;

    if (normalizedStatus == 'confirmed') {
      label = 'Lunas';
      icon = Icons.check_circle;
    } else if (normalizedStatus == 'rejected') {
      label = 'Ditolak';
      icon = Icons.cancel;
    } else {
      label = 'Menunggu Pembayaran';
      icon = Icons.access_time;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
