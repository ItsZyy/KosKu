import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get supabase => _supabase;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Login gagal.');
    }

    final profile = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      await _supabase.auth.signOut();
      throw Exception('Profil pengguna tidak ditemukan.');
    }

    final role = profile['role']?.toString().toLowerCase();

    if (role == 'admin') {
      return response;
    }

    if (role == 'user') {
      final occupancy = await _supabase
          .from('occupancies')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .limit(1)
          .maybeSingle();

      if (occupancy == null) {
        await _supabase.auth.signOut();
        throw Exception('Akun kamu sudah tidak aktif. Silakan hubungi admin.');
      }

      return response;
    }

    await _supabase.auth.signOut();

    throw Exception('Role pengguna tidak valid.');
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _supabase.auth.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      throw Exception('Sesi login tidak ditemukan.');
    }

    await _supabase.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );

    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
