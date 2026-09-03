import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/complaint_model.dart';

class ComplaintService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ADMIN

  // Jumlah laporan aktif
  Future<int> getActiveComplaints() async {
    final data = await _supabase.from('complaints').select('id').inFilter(
      'status',
      ['waiting', 'process'],
    );

    return data.length;
  }

  // Admin - mengambil statistik laporan
  Future<Map<String, int>> getComplaintStats() async {
    final data = await _supabase.from('complaints').select('id, status');

    int total = data.length;
    int menunggu = 0;
    int diproses = 0;
    int selesai = 0;

    for (final item in data) {
      final status = item['status']?.toString();

      if (status == 'waiting') {
        menunggu++;
      } else if (status == 'process') {
        diproses++;
      } else if (status == 'completed') {
        selesai++;
      }
    }

    return {
      'total': total,
      'menunggu': menunggu,
      'diproses': diproses,
      'selesai': selesai,
    };
  }

  // Admin - mengambil semua laporan
  Future<List<ComplaintModel>> getComplaints() async {
    final data = await _supabase
        .from('complaints')
        .select('''
          id,
          user_id,
          room_id,
          type,
          message,
          photo_url,
          status,
          resolved_at,
          created_at,
          profiles (
            name
          ),
          rooms (
            room_number
          )
        ''')
        .order('created_at', ascending: false);

    return data
        .map<ComplaintModel>((item) => ComplaintModel.fromMap(item))
        .toList();
  }

  // Admin - mengubah status laporan
  Future<void> updateComplaintStatus({
    required String id,
    required String status,
  }) async {
    final Map<String, dynamic> updateData = {'status': status};

    if (status == 'completed') {
      updateData['resolved_at'] = DateTime.now().toIso8601String();
    } else {
      updateData['resolved_at'] = null;
    }

    await _supabase.from('complaints').update(updateData).eq('id', id);
  }

  // USER

  // User - mengambil semua keluhan miliknya sendiri
  Future<List<Map<String, dynamic>>> getMyComplaints() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data = await _supabase
        .from('complaints')
        .select('''
          id,
          user_id,
          room_id,
          type,
          message,
          photo_url,
          status,
          resolved_at,
          created_at,
          rooms (
            room_number
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // User - upload foto keluhan
  Future<String> uploadImage(File image) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final extension = image.path.split('.').last.toLowerCase();

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

    final filePath = '${user.id}/$fileName';

    await _supabase.storage
        .from('complaint-images')
        .upload(filePath, image, fileOptions: const FileOptions(upsert: false));

    return filePath;
  }

  // User - membuat laporan baru
  Future<void> createComplaint({
    required String title,
    required String description,
    String? photoUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    // Ambil kamar aktif milik user
    final occupancy = await _supabase
        .from('occupancies')
        .select('room_id')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .maybeSingle();

    if (occupancy == null) {
      throw Exception('Data kamar penghuni tidak ditemukan');
    }

    final roomId = occupancy['room_id'];

    // Simpan laporan
    await _supabase.from('complaints').insert({
      'user_id': user.id,
      'room_id': roomId,
      'type': title,
      'message': description,
      'photo_url': photoUrl,
      'status': 'waiting',
    });
  }
}
