import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get supabase => _supabase;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
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
