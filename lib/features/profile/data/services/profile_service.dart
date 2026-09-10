import 'dart:typed_data';

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

  String? getEmail() {
    return _supabase.auth.currentUser?.email;
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu.');
    }

    final userId = user.id;
    final extension = fileExtension.toLowerCase().replaceAll('.', '');
    final filePath = '$userId/profile.$extension';

    await _supabase.storage
        .from('profile-images')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$extension',
            upsert: true,
          ),
        );

    await _supabase
        .from('profiles')
        .update({'profile_photo_url': filePath})
        .eq('id', userId);

    return filePath;
  }

  Future<void> deleteProfilePhoto() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu.');
    }

    final profile = await getProfile();
    final photoPath = profile?.profilePhotoUrl;

    if (photoPath != null && photoPath.isNotEmpty) {
      await _supabase.storage.from('profile-images').remove([photoPath]);
    }

    await _supabase
        .from('profiles')
        .update({'profile_photo_url': null})
        .eq('id', user.id);
  }

  Future<String?> getProfilePhotoUrl(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) {
      return null;
    }

    final signedUrl = await _supabase.storage
        .from('profile-images')
        .createSignedUrl(photoPath, 3600);

    return signedUrl;
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? kosAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Anda harus login terlebih dahulu.');
    }

    await _supabase
        .from('profiles')
        .update({
          'name': name,
          'phone': phone,
          'address': address,
          'kos_address': kosAddress,
          'emergency_contact_name': emergencyContactName,
          'emergency_contact_phone': emergencyContactPhone,
          'emergency_contact_relation': emergencyContactRelation,
        })
        .eq('id', user.id);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
