import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Menghitung jumlah penghuni yang kontraknya masih aktif.
  Future<int> getTenantCount() async {
    final data = await _supabase
        .from('occupancies')
        .select('user_id')
        .eq('status', 'active');

    return data.length;
  }
}
