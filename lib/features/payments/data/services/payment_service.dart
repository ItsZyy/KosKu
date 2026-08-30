import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Pembayaran terbaru milik penghuni
  Future<Map<String, dynamic>?> getPayment() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('payments')
        .select()
        .eq('user_id', user.id)
        .order('period', ascending: false)
        .limit(1)
        .maybeSingle();

    return data;
  }

  // Total pendapatan yang sudah dikonfirmasi
  Future<int> getTotalIncome() async {
    final data = await _supabase
        .from('payments')
        .select('amount')
        .eq('status', 'dikonfirmasi');

    int total = 0;

    for (final payment in data) {
      total += (payment['amount'] as num).toInt();
    }

    return total;
  }

  // Semua pembayaran untuk Admin
  Future<List<Map<String, dynamic>>> getPayments() async {
    final data = await _supabase
        .from('payments')
        .select('''
        id,
        user_id,
        room_id,
        payment_type,
        amount,
        period,
        due_date,
        proof_url,
        status,
        confirmed_by,
        confirmed_at,
        created_at,
        profiles!payments_user_id_fkey (
          name
        ),
        rooms (
          room_number
        )
      ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
