import 'dart:io';

import 'package:kosku/features/rooms/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload foto kamar ke Supabase Storage.
  // Mengembalikan public URL.
  Future<String> uploadImage(File image) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final filePath = 'rooms/$fileName';

    await _supabase.storage
        .from('room-images')
        .upload(
          filePath,
          image,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    return _supabase.storage.from('room-images').getPublicUrl(filePath);
  }

  /// Upload banyak foto. Karena DB saat ini hanya menyimpan satu
  /// `rooms.image_url`, hanya foto pertama yang dipakai. Field
  /// TODO: migrasi ke tabel `room_images` (room_id, url, position)
  /// untuk multi-image.
  Future<String?> uploadFirstImageOrNull(List<File> images) async {
    if (images.isEmpty) return null;
    return uploadImage(images.first);
  }

  // user - melihat kamar yang sedang ditempati
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
            id,
            room_number,
            capacity,
            status,
            facilities,
            description,
            image_url
          )
        ''')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .maybeSingle();

    if (data == null) {
      return null;
    }

    final room = data['rooms'];

    if (room == null) {
      return null;
    }

    return {
      'room_id': data['room_id'],
      'contract_start': data['contract_start'],
      'contract_end': data['contract_end'],
      'rent_price': data['rent_price'],
      'status': data['status'],
      'room': room,
    };
  }

  // admin - statistik kamar
  Future<Map<String, int>> getRoomStats() async {
    final data = await _supabase.from('rooms').select('id, status');

    final total = data.length;

    final terisi = data.where((room) {
      return room['status'] == 'Terisi';
    }).length;

    return {'total': total, 'terisi': terisi};
  }

  // admin - lihat semua kamar
  Future<List<RoomModel>> getRooms() async {
    final data = await _supabase
        .from('rooms')
        .select()
        .order('room_number', ascending: true);

    return data.map<RoomModel>((item) => RoomModel.fromMap(item)).toList();
  }

  // admin - lihat user yang menempati kamar
  Future<Map<String, Map<String, dynamic>>> getRoomUsers() async {
    final data = await _supabase
        .from('occupancies')
        .select('''
          room_id,
          user_id,
          status,
          contract_start,
          contract_end,
          profiles!occupancies_user_id_fkey (
            id,
            name
          )
        ''')
        .eq('status', 'active');

    final Map<String, Map<String, dynamic>> users = {};

    for (final item in data) {
      final roomId = item['room_id']?.toString();

      if (roomId == null) {
        continue;
      }

      final profileData = item['profiles'];

      Map<String, dynamic>? profile;

      if (profileData is Map) {
        profile = Map<String, dynamic>.from(profileData);
      }

      users[roomId] = {
        'name': profile?['name']?.toString(),
        'user_id': item['user_id']?.toString(),
        'contract_start': item['contract_start']?.toString(),
        'contract_end': item['contract_end']?.toString(),
      };
    }

    return users;
  }

  // admin - tambah kamar
  Future<void> createRoom({
    required String roomNumber,
    required double price,
    required int capacity,
    required String status,
    required String facilities,
    required String description,
    String? imageUrl,
  }) async {
    await _supabase.from('rooms').insert({
      'room_number': roomNumber,
      'price': price,
      'capacity': capacity,
      'status': status,
      'facilities': facilities,
      'description': description,
      'image_url': imageUrl,
    });
  }

  // admin - ubah kamar
  Future<void> updateRoom({
    required String id,
    required String roomNumber,
    required double price,
    required int capacity,
    required String status,
    required String facilities,
    required String description,
    String? imageUrl,
  }) async {
    await _supabase
        .from('rooms')
        .update({
          'room_number': roomNumber,
          'price': price,
          'capacity': capacity,
          'status': status,
          'facilities': facilities,
          'description': description,
          'image_url': imageUrl,
        })
        .eq('id', id);
  }

  // admin - hapus kamar
  Future<void> deleteRoom(String id) async {
    await _supabase.from('rooms').delete().eq('id', id);
  }
}