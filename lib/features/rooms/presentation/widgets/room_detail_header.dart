// Widget untuk RoomDetailScreen & UserRoomDetailScreen
import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_text_styles.dart';

class RoomDetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const RoomDetailHeader({super.key, this.title = 'Detail Kamar', this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Kembali',
          ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}
