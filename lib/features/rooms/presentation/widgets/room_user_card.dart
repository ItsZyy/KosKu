// Widget untuk kartu detail penghuni kamar
import 'package:flutter/material.dart';
import 'package:kosku/core/theme/app_text_styles.dart';
import 'package:kosku/core/utils/currency_formatter.dart';
import 'package:kosku/features/rooms/data/models/room_detail_model.dart';

class RoomUserCard extends StatelessWidget {
  final RoomDetailUser? user;

  const RoomUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _buildEmptyState(context);
    }

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Penghuni',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Akan diarahkan ke detail user nanti.
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildAvatar(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user!.phone != null &&
                        user!.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user!.phone!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(height: 1),

          const SizedBox(height: 18),

          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Mulai kontrak',
            value: _formatDate(user!.contractStart),
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.event_outlined,
            label: 'Akhir kontrak',
            value: _formatDate(user!.contractEnd),
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Harga kamar per 6 bulan',
            value: formatRupiah(user!.rentPrice),
          ),

          const SizedBox(height: 18),

          _buildContractProgress(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final photoUrl = user!.profilePhotoUrl;

    return CircleAvatar(
      radius: 28,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      backgroundImage: photoUrl != null && photoUrl.trim().isNotEmpty
          ? NetworkImage(photoUrl)
          : null,
      child: photoUrl == null || photoUrl.trim().isEmpty
          ? Icon(
              Icons.person_outline,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildContractProgress(BuildContext context) {
    final start = user!.contractStart;
    final end = user!.contractEnd;

    if (start == null || end == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();

    final totalDays = end.difference(start).inDays;
    final elapsedDays = now.difference(start).inDays;

    double progress;

    if (totalDays <= 0) {
      progress = 1;
    } else {
      progress = elapsedDays / totalDays;
      progress = progress.clamp(0.0, 1.0);
    }

    final remainingDays = end.difference(now).inDays;

    final String statusText;

    if (remainingDays < 0) {
      statusText = 'Kontrak telah berakhir';
    } else if (remainingDays == 0) {
      statusText = 'Kontrak berakhir hari ini';
    } else {
      statusText = '$remainingDays hari tersisa';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Progress kontrak',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              statusText,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress, minHeight: 7),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 36,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada penghuni',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
