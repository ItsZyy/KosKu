import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getRoom() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('occupancies')
        .select('''
        room_id,
        contract_start,
        contract_end,
        rent_price,
        status,
        rooms (
          room_number,
          capacity,
          status,
          facilities,
          description
        )
      ''')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return data['rooms'];
  }

  Future<Map<String, int>> getRoomStats() async {
    final data = await _supabase.from('rooms').select('id, status');

    int total = data.length;
    int terisi = data.where((room) => room['status'] == 'Terisi').length;

    return {'total': total, 'terisi': terisi};
  }
}
