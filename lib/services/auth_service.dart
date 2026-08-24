import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<String?> getRole() async {
    final profile = await getProfile();

    if (profile == null) {
      return null;
    }

    return profile['role'] as String?;
  }

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
}
