import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activity_model.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ActivityModel>> getRecentActivities({int limit = 20}) async {
    final results = await Future.wait([
      _getPaymentActivities(),
      _getComplaintActivities(),
      _getAnnouncementActivities(),
      _getTenantActivities(),
      _getRoomActivities(),
    ]);

    final activities = <ActivityModel>[
      for (final result in results) ...result,
    ];

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(limit).toList();
  }

  Future<List<ActivityModel>> _getPaymentActivities() async {
    try {
      final data = await _supabase
          .from('payments')
          .select('''
            id,
            amount,
            period,
            status,
            proof_url,
            payment_method,
            confirmed_at,
            created_at,
            profiles (
              name,
              profile_photo_url
            ),
            rooms (
              room_number
            )
          ''')
          .order('created_at', ascending: false)
          .limit(10);

      final activities = <ActivityModel>[];

      for (final item in data) {
        final status = item['status']?.toString().toLowerCase() ?? '';
        final name = _profileName(item) ?? 'Penghuni';
        final roomNumber = _roomNumber(item);
        final period = item['period']?.toString();
        final proof = item['proof_url']?.toString().trim() ?? '';
        final isCash = item['payment_method']?.toString().toLowerCase() == 'cash';

        String title;
        String? subtitle;

        if (status == 'dikonfirmasi') {
          final amount = (item['amount'] as num?)?.toInt() ?? 0;

          title = '$name membayar tagihan';

          subtitle = [
            if (period != null && period.isNotEmpty) 'Periode $period',
            if (amount > 0) _formatRupiah(amount),
            item['confirmed_at'] != null ? 'Dikonfirmasi admin' : null,
          ].whereType<String>().join(' · ');
        } else if (status == 'ditolak') {
          title = 'Pembayaran $name ditolak';

          subtitle = period != null && period.isNotEmpty
              ? 'Periode $period'
              : null;
        } else if (proof.isNotEmpty || isCash) {
          title = '$name mengirim bukti pembayaran';

          subtitle = period != null && period.isNotEmpty
              ? 'Periode $period'
              : null;
        } else {
          title = 'Tagihan dibuat untuk $name';

          subtitle = roomNumber != null ? 'Kamar $roomNumber' : null;
        }

        activities.add(
          ActivityModel(
            type: 'payment',
            title: title,
            subtitle: subtitle,
            photoUrl: _profilePhoto(item),
            timestamp: _parseDate(item['confirmed_at']) ??
                _parseDate(item['created_at']) ??
                DateTime.now(),
          ),
        );
      }

      return activities;
    } catch (_) {
      return const [];
    }
  }

  Future<List<ActivityModel>> _getComplaintActivities() async {
    try {
      final data = await _supabase
          .from('complaints')
          .select('''
            id,
            type,
            created_at,
            profiles (
              name,
              profile_photo_url
            ),
            rooms (
              room_number
            )
          ''')
          .order('created_at', ascending: false)
          .limit(10);

      final activities = <ActivityModel>[];

      for (final item in data) {
        final name = _profileName(item) ?? 'Penghuni';
        final complaintType = item['type']?.toString() ?? 'keluhan';
        final roomNumber = _roomNumber(item);

        activities.add(
          ActivityModel(
            type: 'complaint',
            title: '$name mengirim keluhan: $complaintType',
            subtitle: roomNumber != null ? 'Kamar $roomNumber' : null,
            photoUrl: _profilePhoto(item),
            timestamp: _parseDate(item['created_at']) ?? DateTime.now(),
          ),
        );
      }

      return activities;
    } catch (_) {
      return const [];
    }
  }

  Future<List<ActivityModel>> _getAnnouncementActivities() async {
    try {
      final data = await _supabase
          .from('announcements')
          .select('id, title, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      return data.map<ActivityModel>((item) {
        final title = item['title']?.toString() ?? 'Pengumuman';

        return ActivityModel(
          type: 'announcement',
          title: 'Pengumuman baru: $title',
          timestamp: _parseDate(item['created_at']) ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<ActivityModel>> _getTenantActivities() async {
    try {
      final data = await _supabase
          .from('occupancies')
          .select('''
            contract_start,
            profiles (
              name,
              profile_photo_url
            ),
            rooms (
              room_number
            )
          ''')
          .eq('status', 'active')
          .order('contract_start', ascending: false)
          .limit(10);

      final activities = <ActivityModel>[];

      for (final item in data) {
        final name = _profileName(item) ?? 'Penghuni baru';
        final roomNumber = _roomNumber(item);

        activities.add(
          ActivityModel(
            type: 'tenant',
            title: '$name menjadi penghuni baru',
            subtitle: roomNumber != null ? 'Kamar $roomNumber' : null,
            photoUrl: _profilePhoto(item),
            timestamp: _parseDate(item['contract_start']) ?? DateTime.now(),
          ),
        );
      }

      return activities;
    } catch (_) {
      return const [];
    }
  }

  Future<List<ActivityModel>> _getRoomActivities() async {
    try {
      final data = await _supabase
          .from('rooms')
          .select('id, room_number, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      return data.map<ActivityModel>((item) {
        final roomNumber = item['room_number']?.toString() ?? 'Kamar';

        return ActivityModel(
          type: 'room',
          title: '$roomNumber ditambahkan',
          timestamp: _parseDate(item['created_at']) ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  String _formatRupiah(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return 'Rp $buffer';
  }

  String? _profileName(dynamic map) {
    final profile = map['profiles'];

    if (profile is Map) {
      return profile['name']?.toString();
    }

    return null;
  }

  String? _profilePhoto(dynamic map) {
    final profile = map['profiles'];

    if (profile is Map) {
      final photo = profile['profile_photo_url']?.toString();

      if (photo == null || photo.isEmpty) {
        return null;
      }

      return photo;
    }

    return null;
  }

  String? _roomNumber(dynamic map) {
    final room = map['rooms'];

    if (room is Map) {
      return room['room_number']?.toString();
    }

    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}