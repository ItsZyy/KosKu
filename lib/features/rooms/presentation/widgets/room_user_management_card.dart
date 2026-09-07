// widget uuntuk room edit
import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';
import 'package:kosku/features/rooms/data/models/room_detail_model.dart';

class RoomUserManagementCard extends StatelessWidget {
  final List<RoomDetailUser> users;
  final int capacity;
  final VoidCallback? onAddUser;
  final void Function(RoomDetailUser user)? onEditUser;
  final void Function(RoomDetailUser user)? onRemoveUser;

  const RoomUserManagementCard({
    super.key,
    required this.users,
    required this.capacity,
    this.onAddUser,
    this.onEditUser,
    this.onRemoveUser,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = users.length >= capacity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Penghuni', style: AppTextStyles.labelLarge),
              ),
              Text(
                '${users.length}/$capacity',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (users.isEmpty)
            _buildEmptyState()
          else
            ...users.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildUserItem(user),
              ),
            ),

          if (!isFull) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddUser,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Tambah Penghuni'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            'Belum ada penghuni',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan penghuni ke kamar ini.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(RoomDetailUser user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.border,
            backgroundImage:
                user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                ? NetworkImage(user.profilePhotoUrl!)
                : null,
            child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                ? const Icon(Icons.person_outline)
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.phone!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _buildContractText(user),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEditUser?.call(user);
              } else if (value == 'remove') {
                onRemoveUser?.call(user);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'remove', child: Text('Hapus Penghuni')),
            ],
          ),
        ],
      ),
    );
  }

  String _buildContractText(RoomDetailUser user) {
    if (user.contractStart == null && user.contractEnd == null) {
      return 'Kontrak belum diatur';
    }

    final start = user.contractStart != null
        ? _formatDate(user.contractStart!)
        : '-';

    final end = user.contractEnd != null ? _formatDate(user.contractEnd!) : '-';

    return 'Kontrak: $start - $end';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
