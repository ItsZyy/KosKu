import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_model.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========================================
  // RPC generate_payment (dipanggil Admin)
  // ========================================
  // Function di database yang membuat payments + payment_items
  // secara otomatis. Flutter tidak menghitung total tagihan.
  Future<String> generatePayment({
    required String userId,
    required String roomId,
    required String period,
    required String dueDate,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final paymentId = await _supabase.rpc(
      'generate_payment',
      params: {
        'p_user_id': userId,
        'p_room_id': roomId,
        'p_period': period,
        'p_due_date': dueDate,
      },
    );

    if (paymentId == null) {
      throw Exception('Gagal membuat tagihan. Tagihan mungkin sudah ada.');
    }

    return paymentId.toString();
  }

  // ========================================
  // Detail pembayaran + payment_items
  // ========================================
  Future<Payment?> getPaymentDetail(String paymentId) async {
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
          rooms (
            room_number
          ),
          payment_items (
            id,
            payment_id,
            item_type,
            description,
            amount,
            created_at
          )
        ''')
        .eq('id', paymentId)
        .maybeSingle();

    if (data == null) return null;
    return Payment.fromMap(data);
  }

  // Rincian tagihan (payment_items) dari sebuah payment.
  Future<List<PaymentItem>> getPaymentItems(String paymentId) async {
    final data = await _supabase
        .from('payment_items')
        .select()
        .eq('payment_id', paymentId)
        .order('created_at', ascending: true);

    return data
        .map<PaymentItem>((e) => PaymentItem.fromMap(e))
        .toList();
  }

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

  // Riwayat pembayaran milik penghuni yang sedang login
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data = await _supabase
        .from('payments')
        .select()
        .eq('user_id', user.id)
        .order('period', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getPaymentInfo() async {
    try {
      final data = await _supabase
          .from('payment_info')
          .select()
          .limit(1)
          .maybeSingle();

      return data;
    } catch (_) {
      // Tabel payment_info bersifat opsional. Jika belum tersedia,
      // metode pembayaran tetap bisa ditampilkan kosong.
      return null;
    }
  }

  // ========================================
  // TYPED METHODS (return Payment model)
  // ========================================

  Future<Payment?> getCurrentPayment() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

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
          rooms (
            room_number
          ),
          payment_items (
            id,
            payment_id,
            item_type,
            description,
            amount,
            created_at
          )
        ''')
        .eq('user_id', user.id)
        .order('period', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return Payment.fromMap(data);
  }

  Future<List<Payment>> getPaymentHistoryTyped() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return [];

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
          rooms (
            room_number
          ),
          payment_items (
            id,
            payment_id,
            item_type,
            description,
            amount,
            created_at
          )
        ''')
        .eq('user_id', user.id)
        .order('period', ascending: false);

    return (data as List).map((e) => Payment.fromMap(e)).toList();
  }
}
