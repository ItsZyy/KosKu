import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_model.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
      throw Exception('Tagihan untuk periode ini sudah dibuat.');
    }

    return paymentId.toString();
  }

  Future<Payment?> getPaymentDetail(String paymentId) async {
    final data = await _supabase
        .from('payments')
        .select('''
          id,
          user_id,
          room_id,
          description,
          payment_method,
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

    if (data == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);

    final profile = await _fetchProfile(map['user_id']);

    if (profile != null) {
      map['profiles'] = profile;
    }

    await _attachContract(map);

    return Payment.fromMap(map);
  }

  Future<List<PaymentItem>> getPaymentItems(String paymentId) async {
    final data = await _supabase
        .from('payment_items')
        .select()
        .eq('payment_id', paymentId)
        .order('created_at', ascending: true);

    return data.map<PaymentItem>((e) => PaymentItem.fromMap(e)).toList();
  }

  Future<String> uploadPaymentProof({
    required String paymentId,
    required File file,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final extension = file.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

    final filePath = 'proofs/$paymentId/$fileName';

    await _supabase.storage
        .from('payment-images')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: false));

    return filePath;
  }

  Future<void> submitPaymentProof({
    required String paymentId,
    required String proofUrl,
    required String paymentMethod,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final trimmedProofUrl = proofUrl.trim();

    if (trimmedProofUrl.isEmpty) {
      throw Exception('Path bukti pembayaran tidak valid.');
    }

    if (paymentMethod != 'bank' && paymentMethod != 'qris') {
      throw Exception('Metode pembayaran tidak valid.');
    }

    final payment = await _supabase
        .from('payments')
        .select('id, user_id, proof_url, status')
        .eq('id', paymentId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (payment == null) {
      throw Exception('Tagihan tidak ditemukan.');
    }

    final existingProof = payment['proof_url']?.toString().trim();

    final currentStatus = payment['status']?.toString().toLowerCase();

    final hasExistingProof = existingProof != null && existingProof.isNotEmpty;

    if (hasExistingProof && currentStatus != 'ditolak') {
      if (currentStatus == 'dikonfirmasi') {
        throw Exception('Pembayaran sudah dikonfirmasi oleh admin.');
      }

      throw Exception(
        'Bukti pembayaran sudah dikirim dan sedang menunggu konfirmasi.',
      );
    }

    final updatedPayment = await _supabase
        .from('payments')
        .update({
          'payment_method': paymentMethod,
          'proof_url': trimmedProofUrl,
          'status': 'menunggu',
          'confirmed_by': null,
          'confirmed_at': null,
        })
        .eq('id', paymentId)
        .eq('user_id', user.id)
        .select('id, user_id, payment_method, proof_url, status')
        .maybeSingle();

    if (updatedPayment == null) {
      throw Exception(
        'Bukti pembayaran gagal disimpan. '
        'Pastikan Anda memiliki izin untuk memperbarui pembayaran ini.',
      );
    }

    final savedProof = updatedPayment['proof_url']?.toString().trim();

    final savedStatus = updatedPayment['status']?.toString().toLowerCase();

    if (savedProof == null || savedProof.isEmpty) {
      throw Exception('Bukti pembayaran gagal disimpan ke database.');
    }

    if (savedStatus != 'menunggu') {
      throw Exception('Status pembayaran gagal diperbarui.');
    }
  }

  Future<void> submitCashPayment({required String paymentId}) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final payment = await _supabase
        .from('payments')
        .select('id, user_id, payment_method, proof_url, status')
        .eq('id', paymentId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (payment == null) {
      throw Exception('Tagihan tidak ditemukan.');
    }

    final currentStatus = payment['status']?.toString().toLowerCase();

    if (currentStatus == 'dikonfirmasi') {
      throw Exception('Pembayaran sudah dikonfirmasi oleh admin.');
    }

    if (currentStatus == 'menunggu') {
      throw Exception(
        'Pembayaran sudah dikirim dan sedang menunggu konfirmasi admin.',
      );
    }

    final updated = await _supabase
        .from('payments')
        .update({
          'payment_method': 'cash',
          'proof_url': null,
          'status': 'menunggu',
          'confirmed_by': null,
          'confirmed_at': null,
        })
        .eq('id', paymentId)
        .eq('user_id', user.id)
        .select('id, payment_method, proof_url, status')
        .maybeSingle();

    if (updated == null) {
      throw Exception('Pembayaran tunai gagal disimpan.');
    }

    final savedMethod = updated['payment_method']?.toString();

    final savedStatus = updated['status']?.toString().toLowerCase();

    if (savedMethod != 'cash') {
      throw Exception('Metode pembayaran tunai gagal disimpan.');
    }

    if (savedStatus != 'menunggu') {
      throw Exception('Status pembayaran gagal diperbarui.');
    }
  }

  Future<bool> _isAdmin(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      return profile?['role']?.toString() == 'admin';
    } catch (_) {
      return false;
    }
  }

  Future<void> confirmPayment({
    required String paymentId,
    required String adminUserId,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu.');
    }

    if (adminUserId != user.id) {
      throw Exception(
        'ID admin tidak cocok dengan pengguna yang sedang login.',
      );
    }

    if (!await _isAdmin(user.id)) {
      throw Exception(
        'Anda tidak memiliki izin admin untuk mengonfirmasi pembayaran.',
      );
    }

    final payment = await _supabase
        .from('payments')
        .select('id, status, payment_method, proof_url')
        .eq('id', paymentId)
        .maybeSingle();

    if (payment == null) {
      throw Exception('Pembayaran tidak ditemukan.');
    }

    final currentStatus = payment['status']?.toString().toLowerCase();

    final paymentMethod = payment['payment_method']?.toString().toLowerCase();

    final proof = payment['proof_url']?.toString().trim();

    if (currentStatus != 'menunggu') {
      throw Exception(
        'Pembayaran tidak dapat dikonfirmasi karena status saat ini bukan "menunggu".',
      );
    }

    final isCash = paymentMethod == 'cash';

    if (!isCash && (proof == null || proof.isEmpty)) {
      throw Exception(
        'Pembayaran belum memiliki bukti pembayaran, '
        'tidak dapat dikonfirmasi.',
      );
    }

    final updated = await _supabase
        .from('payments')
        .update({
          'status': 'dikonfirmasi',
          'confirmed_by': user.id,
          'confirmed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', paymentId)
        .eq('status', 'menunggu')
        .select('id, status, confirmed_by, confirmed_at')
        .maybeSingle();

    if (updated == null) {
      throw Exception(
        'Konfirmasi gagal: status pembayaran berubah sebelum proses selesai, '
        'atau Anda tidak memiliki izin untuk memperbarui pembayaran ini (cek RLS).',
      );
    }

    final updatedStatus = updated['status']?.toString().toLowerCase();

    if (updatedStatus != 'dikonfirmasi') {
      throw Exception(
        'Status pembayaran tidak berubah menjadi "dikonfirmasi".',
      );
    }

    if ((updated['confirmed_by']?.toString() ?? '').isEmpty) {
      throw Exception('ID admin tidak tersimpan pada pembayaran.');
    }

    if ((updated['confirmed_at']?.toString() ?? '').isEmpty) {
      throw Exception('Waktu konfirmasi tidak tersimpan pada pembayaran.');
    }
  }

  Future<void> rejectPayment({required String paymentId}) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu.');
    }

    if (!await _isAdmin(user.id)) {
      throw Exception(
        'Anda tidak memiliki izin admin untuk menolak pembayaran.',
      );
    }

    final payment = await _supabase
        .from('payments')
        .select('id, status')
        .eq('id', paymentId)
        .maybeSingle();

    if (payment == null) {
      throw Exception('Pembayaran tidak ditemukan.');
    }

    final currentStatus = payment['status']?.toString().toLowerCase();

    if (currentStatus != 'menunggu') {
      throw Exception(
        'Pembayaran tidak dapat ditolak karena status saat ini bukan "menunggu".',
      );
    }

    final updated = await _supabase
        .from('payments')
        .update({'status': 'ditolak'})
        .eq('id', paymentId)
        .eq('status', 'menunggu')
        .select('id, status')
        .maybeSingle();

    if (updated == null) {
      throw Exception(
        'Penolakan gagal: status pembayaran berubah sebelum proses selesai, '
        'atau Anda tidak memiliki izin untuk memperbarui pembayaran ini (cek RLS).',
      );
    }

    final updatedStatus = updated['status']?.toString().toLowerCase();

    if (updatedStatus != 'ditolak') {
      throw Exception('Status pembayaran tidak berubah menjadi "ditolak".');
    }
  }

  Future<String?> getProofSignedUrl(String? proofPath) async {
    if (proofPath == null || proofPath.isEmpty) {
      return null;
    }

    try {
      return await _supabase.storage
          .from('payment-images')
          .createSignedUrl(proofPath, 3600);
    } catch (_) {
      return null;
    }
  }

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

  Future<List<Map<String, dynamic>>> getPayments() async {
    final data = await _supabase
        .from('payments')
        .select('''
          id,
          user_id,
          room_id,
          description,
          payment_method,
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
          )
        ''')
        .order('created_at', ascending: false);

    final payments = List<Map<String, dynamic>>.from(data);

    await _attachContracts(payments);

    await _attachProfiles(payments);

    return payments;
  }

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

    final payments = List<Map<String, dynamic>>.from(data);

    await _attachContracts(payments);

    return payments;
  }

  Future<List<Map<String, dynamic>>> getPaymentInfo() async {
    try {
      final data = await _supabase
          .from('payment_info')
          .select()
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<Payment?> getCurrentPayment() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('payments')
        .select('''
          id,
          user_id,
          room_id,
          description,
          payment_method,
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

    if (data == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);

    await _attachContract(map);

    return Payment.fromMap(map);
  }

  Future<List<Payment>> getPaymentHistoryTyped() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data = await _supabase
        .from('payments')
        .select('''
          id,
          user_id,
          room_id,
          description,
          payment_method,
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

  Future<List<Map<String, dynamic>>> _getOccupancies() async {
    try {
      return List<Map<String, dynamic>>.from(
        await _supabase
            .from('occupancies')
            .select(
              'user_id, room_id, contract_start, contract_end, status',
            )
            .order('contract_start', ascending: true),
      );
    } catch (_) {
      return const [];
    }
  }

  void _attachContractToMap(
    Map<String, dynamic> payment,
    List<Map<String, dynamic>> occupancies,
  ) {
    final userId = payment['user_id']?.toString();

    final roomId = payment['room_id']?.toString();

    if (userId == null || roomId == null) return;

    final period = DateTime.tryParse(payment['period']?.toString() ?? '');

    Map<String, dynamic>? candidate;

    Map<String, dynamic>? fallback;

    for (final occupancy in occupancies) {
      if (occupancy['user_id']?.toString() != userId) continue;

      if (occupancy['room_id']?.toString() != roomId) continue;

      fallback ??= occupancy;

      if (period == null) continue;

      final start = DateTime.tryParse(
        occupancy['contract_start']?.toString() ?? '',
      );

      final end = DateTime.tryParse(
        occupancy['contract_end']?.toString() ?? '',
      );

      if (start == null || end == null) continue;

      if (!period.isBefore(start) && !period.isAfter(end)) {
        candidate = occupancy;
        break;
      }
    }

    final matched = candidate ?? fallback;

    if (matched == null) return;

    payment['contract_start'] = matched['contract_start'];

    payment['contract_end'] = matched['contract_end'];
  }

  Future<void> _attachContract(Map<String, dynamic> payment) async {
    final occupancies = await _getOccupancies();
    _attachContractToMap(payment, occupancies);
  }

  Future<Map<String, dynamic>?> _fetchProfile(dynamic userId) async {
    if (userId == null) {
      return null;
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select('id, name, phone, profile_photo_url')
          .eq('id', userId.toString())
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _attachProfiles(
    List<Map<String, dynamic>> payments,
  ) async {
    if (payments.isEmpty) {
      return;
    }

    final userIds = payments
        .map((payment) => payment['user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (userIds.isEmpty) {
      return;
    }

    try {
      final profiles = await _supabase
          .from('profiles')
          .select('id, name, phone, profile_photo_url')
          .inFilter('id', userIds);

      final profileMap = <String, Map<String, dynamic>>{
        for (final profile in profiles)
          profile['id'].toString(): Map<String, dynamic>.from(profile),
      };

      for (final payment in payments) {
        final userId = payment['user_id']?.toString();

        if (userId != null) {
          payment['profiles'] = profileMap[userId];
        }
      }
    } catch (_) {}
  }

  Future<void> _attachContracts(
    List<Map<String, dynamic>> payments,
  ) async {
    if (payments.isEmpty) return;
    final occupancies = await _getOccupancies();
    for (final payment in payments) {
      _attachContractToMap(payment, occupancies);
    }
  }
}
