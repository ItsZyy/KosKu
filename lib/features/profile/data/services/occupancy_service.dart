import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/occupancy_model.dart';

class OccupancyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<OccupancyModel?> getActiveOccupancy() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('occupancies')
        .select('''
          id,
          room_id,
          user_id,
          contract_start,
          contract_end,
          rent_price,
          status,
          payment_interval_months,
          payment_day,
          rooms (
            room_number,
            room_facilities (
              facilities (
                name
              )
            )
          )
        ''')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return OccupancyModel.fromMap(data);
  }

  Future<OccupancyModel?> getActiveOccupancyByUserId(String userId) async {
    final data = await _supabase
        .from('occupancies')
        .select('''
          id,
          room_id,
          user_id,
          contract_start,
          contract_end,
          rent_price,
          status,
          payment_interval_months,
          payment_day,
          rooms (
            room_number,
            room_facilities (
              facilities (
                name
              )
            )
          )
        ''')
        .eq('user_id', userId)
        .eq('status', 'active')
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return OccupancyModel.fromMap(data);
  }
}
