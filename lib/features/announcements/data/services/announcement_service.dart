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
}
