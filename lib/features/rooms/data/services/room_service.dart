import 'dart:convert';
import 'dart:io';

import 'package:kosku/features/rooms/data/models/facility_model.dart';
import 'package:kosku/features/rooms/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _storageBucket = 'room-images';
  static const String _tableRooms = 'rooms';
  static const String _tableFacilities = 'facilities';
  static const String _tableRoomFacilities = 'room_facilities';

  static String storagePathToPublicUrl(String path) {
    return Supabase.instance.client.storage
        .from(_storageBucket)
        .getPublicUrl(path);
  }

  Future<List<String>> uploadImages({
    required String roomId,
    required List<File> images,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final List<String> paths = [];

    for (final image in images) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${paths.length}.jpg';
      final filePath = 'rooms/$roomId/$fileName';

      await _supabase.storage.from(_storageBucket).upload(
            filePath,
            image,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      paths.add(filePath);
    }

    return paths;
  }

  static List<String> parseImageUrls(dynamic value) {
    if (value == null) return <String>[];

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return <String>[];

      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.whereType<String>().toList();
        }
      } on FormatException catch (_) {
        return <String>[trimmed];
      }
    }

    return <String>[];
  }

  static String encodeImageUrls(List<String> paths) {
    return jsonEncode(paths);
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

  // admin - ambil daftar fasilitas aktif dari tabel facilities
  Future<List<FacilityModel>> getFacilities({bool activeOnly = true}) async {
    var query = _supabase.from(_tableFacilities).select();

    if (activeOnly) {
      query = query.eq('is_active', true);
    }

    final data = await query.order('name', ascending: true);

    return data
        .map<FacilityModel>((item) => FacilityModel.fromMap(item))
        .toList();
  }

  // admin - ambil fasilitas yang dimiliki sebuah kamar
  Future<List<FacilityModel>> getRoomFacilities(String roomId) async {
    final data = await _supabase
        .from(_tableRoomFacilities)
        .select('''
          facility_id,
          facilities (
            id,
            name,
            price,
            description,
            is_active
          )
        ''')
        .eq('room_id', roomId);

    final List<FacilityModel> result = [];

    for (final item in data) {
      final facilityData = item['facilities'];

      if (facilityData is Map) {
        result.add(
          FacilityModel.fromMap(Map<String, dynamic>.from(facilityData)),
        );
      }
    }

    return result;
  }

  // admin - tambah kamar
  Future<RoomModel> createRoom({
    required String roomNumber,
    required double price,
    required int capacity,
    String status = 'kosong',
    String? description,
    List<String> facilityIds = const [],
    List<File> images = const [],
  }) async {
    final data = await _supabase
        .from(_tableRooms)
        .insert({
          'room_number': roomNumber,
          'price': price,
          'capacity': capacity,
          'status': status,
          'description': description,
          'image_url': null,
        })
        .select()
        .single();

    final roomId = data['id'] as String;

    try {
      if (facilityIds.isNotEmpty) {
        await _replaceRoomFacilities(roomId, facilityIds);
      }

      if (images.isNotEmpty) {
        final paths = await uploadImages(roomId: roomId, images: images);
        final encoded = encodeImageUrls(paths);

        await _supabase
            .from(_tableRooms)
            .update({'image_url': encoded})
            .eq('id', roomId);
      }
    } catch (e) {
      // Best-effort cleanup agar tidak meninggalkan kamar yatim ketika
      // proses insert fasilitas / upload foto gagal.
      try {
        await _supabase.from(_tableRoomFacilities).delete().eq('room_id', roomId);
      } catch (_) {}
      try {
        await _deleteStorageFiles(roomId);
      } catch (_) {}
      try {
        await _supabase.from(_tableRooms).delete().eq('id', roomId);
      } catch (_) {}
      throw Exception('Gagal membuat kamar: $e');
    }

    return RoomModel.fromMap(data);
  }

  // admin - ubah kamar
  Future<void> updateRoom({
    required String id,
    required String roomNumber,
    required double price,
    required int capacity,
    required String status,
    String? description,
    List<String> facilityIds = const [],
    List<File> images = const [],
  }) async {
    final currentRoomData = await _supabase
        .from(_tableRooms)
        .select('image_url')
        .eq('id', id)
        .maybeSingle();

    if (currentRoomData == null) {
      throw Exception('Kamar tidak ditemukan');
    }

    final existingPaths = parseImageUrls(currentRoomData['image_url']);
    final allPaths = <String>[...existingPaths];

    if (images.isNotEmpty) {
      final newPaths = await uploadImages(roomId: id, images: images);
      allPaths.addAll(newPaths);
    }

    final imageUrl = allPaths.isEmpty ? null : encodeImageUrls(allPaths);

    await _supabase
        .from(_tableRooms)
        .update({
          'room_number': roomNumber,
          'price': price,
          'capacity': capacity,
          'status': status,
          'description': description,
          'image_url': imageUrl,
        })
        .eq('id', id);

    await _replaceRoomFacilities(id, facilityIds);
  }

  // admin - hapus kamar
  Future<void> deleteRoom(String id) async {
    // Hapus relasi fasilitas kamar terlebih dahulu.
    await _supabase.from(_tableRoomFacilities).delete().eq('room_id', id);

    // Hapus foto-foto kamar di storage (jika policy mengizinkan).
    await _deleteStorageFiles(id);

    // Hapus baris kamar.
    await _supabase.from(_tableRooms).delete().eq('id', id);
  }

  // Helpers ----------------------------------------------------------------

  Future<void> _replaceRoomFacilities(
    String roomId,
    List<String> facilityIds,
  ) async {
    await _supabase.from(_tableRoomFacilities).delete().eq('room_id', roomId);

    if (facilityIds.isEmpty) {
      return;
    }

    final rows = facilityIds
        .where((id) => id.trim().isNotEmpty)
        .map((facilityId) => {
              'room_id': roomId,
              'facility_id': facilityId,
            })
        .toList();

    if (rows.isEmpty) {
      return;
    }

    await _supabase.from(_tableRoomFacilities).insert(rows);
  }

  Future<void> _deleteStorageFiles(String roomId) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(_storageBucket)
          .list(path: 'rooms/$roomId');

      if (files.isEmpty) {
        return;
      }

      final paths = files
          .map((f) => 'rooms/$roomId/${f.name}')
          .toList();

      await _supabase.storage.from(_storageBucket).remove(paths);
    } catch (_) {
      // Hapus foto di storage best-effort. Jangan gagalkan delete kamar
      // hanya karena storage tidak bisa diakses.
    }
  }
}
