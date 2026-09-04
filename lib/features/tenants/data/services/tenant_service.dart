import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tenant_model.dart';

class TenantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TenantModel>> getTenants() async {
    final occupancies = await _supabase
        .from('occupancies')
        .select('''
          id,
          user_id,
          room_id,
          contract_start,
          contract_end,
          rent_price,
          status
        ''')
        .eq('status', 'active')
        .order('contract_start', ascending: false);

    if (occupancies.isEmpty) {
      return [];
    }

    final userIds = occupancies
        .map((item) => item['user_id'] as String)
        .toSet()
        .toList();

    final roomIds = occupancies
        .map((item) => item['room_id'] as String)
        .toSet()
        .toList();

    final profiles = await _supabase
        .from('profiles')
        .select('id, name, phone, profile_photo_url')
        .inFilter('id', userIds);

    final rooms = await _supabase
        .from('rooms')
        .select('id, room_number')
        .inFilter('id', roomIds);

    final profileMap = {
      for (final profile in profiles) profile['id'] as String: profile,
    };

    final roomMap = {for (final room in rooms) room['id'] as String: room};

    return occupancies.map((item) {
      final profile = profileMap[item['user_id']];
      final room = roomMap[item['room_id']];

      return TenantModel.fromMap({
        'id': item['id'],
        'user_id': item['user_id'],
        'room_id': item['room_id'],
        'name': profile?['name'] ?? 'Nama tidak tersedia',
        'phone': profile?['phone'],
        'profile_photo_url': profile?['profile_photo_url'],
        'room_number': room?['room_number'] ?? '-',
        'contract_start': item['contract_start'],
        'contract_end': item['contract_end'],
        'rent_price': item['rent_price'],
        'status': item['status'],
      });
    }).toList();
  }
}
