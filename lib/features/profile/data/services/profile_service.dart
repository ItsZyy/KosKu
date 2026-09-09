import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfileModel?> getProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return ProfileModel.fromMap(data);
  }

  Future<String?> getRole() async {
    final profile = await getProfile();

    return profile?.role;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
