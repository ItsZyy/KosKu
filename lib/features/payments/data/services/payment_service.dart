import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getPayment() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('payments')
        .select()
        .eq('tenant_id', user.id)
        .order('period', ascending: false)
        .limit(1)
        .maybeSingle();

    return data;
  }

  Future<int> getTotalIncome() async {
    final data = await _supabase
        .from('payments')
        .select('amount')
        .eq('status', 'lunas');

    int total = 0;

    for (final payment in data) {
      total += (payment['amount '] as num).toInt();
    }

    return total;
  }
}
