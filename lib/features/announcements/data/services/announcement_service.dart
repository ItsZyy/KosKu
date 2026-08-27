import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/announcement_model.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final data = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false);

    return data
        .map<AnnouncementModel>((item) => AnnouncementModel.fromMap(item))
        .toList();
  }

  // Upload foto ke Supabase Storage
  Future<String> uploadImage(File image) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final filePath = 'announcements/$fileName';

    await _supabase.storage
        .from('announcement-images')
        .upload(
          filePath,
          image,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    final imageUrl = _supabase.storage
        .from('announcement-images')
        .getPublicUrl(filePath);

    return imageUrl;
  }

  // Tambah pengumuman
  Future<void> createAnnouncement({
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    await _supabase.from('announcements').insert({
      'created_by': user.id,
      'title': title,
      'message': message,
      'image_url': imageUrl,
    });
  }
}
