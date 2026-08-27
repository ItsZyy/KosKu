import 'package:flutter/material.dart';

import '../../data/models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  announcement.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),

            if (announcement.imageUrl != null) const SizedBox(height: 12),

            Text(
              announcement.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(announcement.message),

            const SizedBox(height: 8),

            Text(
              '${announcement.createdAt.day}/'
              '${announcement.createdAt.month}/'
              '${announcement.createdAt.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
