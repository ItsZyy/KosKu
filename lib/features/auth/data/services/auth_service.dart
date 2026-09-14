import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Deep link yang dipakai Supabase untuk mengembalikan user ke aplikasi
  // setelah membuka link reset password dari email.
  static const String passwordRecoveryRedirectUrl = 'kosku://reset-password';

  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get supabase => _supabase;

  // Login pengguna
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

  // Mengecek session dan role pengguna
  Future<String?> resolveSessionRole() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      return null;
    }

    final user = session.user;

    final profile = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      await _supabase.auth.signOut();
      return null;
    }

    final role = profile['role']?.toString().toLowerCase();

    if (role == 'admin') {
      return 'admin';
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
        return null;
      }

      return 'user';
    }

    await _supabase.auth.signOut();
    return null;
  }

  // Mendaftarkan akun baru
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Mengirim link reset password
  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? passwordRecoveryRedirectUrl,
    );
  }

  // Mengubah password dari alur forgot-password/recovery.
  // Tidak membutuhkan password lama karena sesi recovery sudah valid
  // dari deep link Supabase. Dipisahkan dari changePassword() yang hanya
  // untuk user yang sudah login.
  Future<void> updatePassword({required String newPassword}) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Mengubah password pengguna
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

  // Logout pengguna
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
