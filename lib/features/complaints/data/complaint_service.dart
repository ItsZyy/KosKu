import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getActiveComplaints() async {
    final data = await _supabase.from('complaints').select('id').inFilter(
      'status',
      ['menunggu', 'diproses'],
    );

    return data.length;
  }
}
