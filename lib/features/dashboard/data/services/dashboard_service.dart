import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getTenantCount() async {
    final data = await _supabase
        .from('occupancies')
        .select('user_id')
        .eq('status', 'active');

    return data.length;
  }
}
