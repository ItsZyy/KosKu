import 'dart:convert';
import 'dart:io';

import 'package:kosku/features/complaints/data/models/complaint_model.dart';
import 'package:kosku/features/payments/data/models/payment_model.dart';
import 'package:kosku/features/rooms/data/models/facility_model.dart';
import 'package:kosku/features/rooms/data/models/room_detail_model.dart';
import 'package:kosku/features/rooms/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _storageBucket = 'room-images';

  static const String _tableRooms = 'rooms';
  static const String _tableFacilities = 'facilities';
  static const String _tableRoomFacilities = 'room_facilities';

  // ============================================================
  // STORAGE
  // ============================================================

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

      await _supabase.storage
          .from(_storageBucket)
          .upload(
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
    if (value == null) {
      return [];
    }

    if (value is String) {
      final trimmed = value.trim();

      if (trimmed.isEmpty) {
        return [];
      }

      try {
        final decoded = jsonDecode(trimmed);

        if (decoded is List) {
          return decoded.whereType<String>().toList();
        }
      } on FormatException {
        return [trimmed];
      }
    }

    return [];
  }

  static String encodeImageUrls(List<String> paths) {
    return jsonEncode(paths);
  }

  // ============================================================
  // USER
  // ============================================================

  // User - melihat kamar yang sedang ditempati
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
            price,
            capacity,
            status,
            description,
            image_url,
            created_at
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

  // ============================================================
  // ADMIN - STATISTIK
  // ============================================================

  // Admin - statistik kamar
  Future<Map<String, int>> getRoomStats() async {
    final data = await _supabase.from(_tableRooms).select('id, status');

    final total = data.length;

    final terisi = data.where((room) {
      return room['status'] == 'Terisi';
    }).length;

    return {'total': total, 'terisi': terisi};
  }

  // ============================================================
  // ADMIN - DAFTAR KAMAR
  // ============================================================

  // Admin - melihat semua kamar
  Future<List<RoomModel>> getRooms() async {
    final data = await _supabase
        .from(_tableRooms)
        .select()
        .order('room_number', ascending: true);

    return data.map<RoomModel>((item) => RoomModel.fromMap(item)).toList();
  }

  // ============================================================
  // ADMIN - DETAIL KAMAR
  // ============================================================

  // Admin - melihat detail kamar
  Future<RoomDetailModel?> getRoomDetail(String roomId) async {
    // ------------------------------------------------------------
    // 1. DATA KAMAR
    // ------------------------------------------------------------

    final roomData = await _supabase
        .from(_tableRooms)
        .select('''
          id,
          room_number,
          price,
          capacity,
          status,
          description,
          image_url,
          created_at
        ''')
        .eq('id', roomId)
        .maybeSingle();

    if (roomData == null) {
      return null;
    }

    final room = RoomModel.fromMap(Map<String, dynamic>.from(roomData));

    // ------------------------------------------------------------
    // 2. FASILITAS KAMAR
    // ------------------------------------------------------------

    final facilitiesData = await _supabase
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

    final List<FacilityModel> facilities = [];

    for (final item in facilitiesData) {
      final facilityData = item['facilities'];

      if (facilityData is Map) {
        facilities.add(
          FacilityModel.fromMap(Map<String, dynamic>.from(facilityData)),
        );
      }
    }

    // ------------------------------------------------------------
    // 3. PENGHUNI AKTIF
    // ------------------------------------------------------------

    final occupancyData = await _supabase
        .from('occupancies')
        .select('''
          user_id,
          contract_start,
          contract_end,
          rent_price,
          status,
          profiles!occupancies_user_id_fkey (
            name,
            phone,
            profile_photo_url
          )
        ''')
        .eq('room_id', roomId)
        .eq('status', 'active')
        .maybeSingle();

    RoomDetailUser? user;

    if (occupancyData != null) {
      final profileData = occupancyData['profiles'];

      String? name;
      String? phone;
      String? profilePhotoUrl;

      if (profileData is Map) {
        name = profileData['name']?.toString();
        phone = profileData['phone']?.toString();
        profilePhotoUrl = profileData['profile_photo_url']?.toString();
      }

      user = RoomDetailUser(
        userId: occupancyData['user_id'].toString(),
        name: name ?? '-',
        phone: phone,
        profilePhotoUrl: profilePhotoUrl,
        contractStart: _parseDate(occupancyData['contract_start']),
        contractEnd: _parseDate(occupancyData['contract_end']),
        rentPrice: (occupancyData['rent_price'] as num?)?.toDouble() ?? 0,
        occupancyStatus: occupancyData['status']?.toString(),
      );
    }

    // ------------------------------------------------------------
    // 4. PEMBAYARAN
    // ------------------------------------------------------------

    final List<Payment> payments = [];

    if (user != null) {
      final paymentsData = await _supabase
          .from('payments')
          .select('''
            id,
            user_id,
            room_id,
            payment_type,
            amount,
            period,
            due_date,
            proof_url,
            status,
            confirmed_by,
            confirmed_at,
            created_at,
            payment_items (
              id,
              payment_id,
              item_type,
              description,
              amount,
              created_at
            )
          ''')
          .eq('room_id', roomId)
          .eq('user_id', user.userId)
          .order('period', ascending: false);

      payments.addAll(
        paymentsData.map<Payment>(
          (item) => Payment.fromMap(Map<String, dynamic>.from(item)),
        ),
      );
    }

    // ------------------------------------------------------------
    // 5. KELUHAN
    // ------------------------------------------------------------

    final List<ComplaintModel> complaints = [];

    if (user != null) {
      final complaintsData = await _supabase
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
            created_at
          ''')
          .eq('room_id', roomId)
          .eq('user_id', user.userId)
          .order('created_at', ascending: false);

      complaints.addAll(
        complaintsData.map<ComplaintModel>(
          (item) => ComplaintModel.fromMap(Map<String, dynamic>.from(item)),
        ),
      );
    }

    // ------------------------------------------------------------
    // 6. GABUNGKAN SEMUA DATA
    // ------------------------------------------------------------

    return RoomDetailModel(
      room: room,
      facilities: facilities,
      user: user,
      payments: payments,
      complaints: complaints,
    );
  }

  // ============================================================
  // ADMIN - PENGHUNI KAMAR
  // ============================================================

  // Admin - melihat user yang menempati kamar
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

  // ============================================================
  // FACILITIES
  // ============================================================

  // Admin - mengambil daftar fasilitas
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

  // Admin - mengambil fasilitas yang dimiliki sebuah kamar
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

  // ============================================================
  // ADMIN - TAMBAH KAMAR
  // ============================================================

  // Admin - tambah kamar
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
      // Best-effort cleanup agar tidak meninggalkan
      // data kamar yatim jika proses gagal.

      try {
        await _supabase
            .from(_tableRoomFacilities)
            .delete()
            .eq('room_id', roomId);
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

  // ============================================================
  // ADMIN - UBAH KAMAR
  // ============================================================

  // Admin - ubah kamar
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

  // ============================================================
  // ADMIN - HAPUS KAMAR
  // ============================================================

  // Admin - hapus kamar
  Future<void> deleteRoom(String id) async {
    // Hapus relasi fasilitas kamar terlebih dahulu.
    await _supabase.from(_tableRoomFacilities).delete().eq('room_id', id);

    // Hapus foto-foto kamar dari storage.
    await _deleteStorageFiles(id);

    // Hapus data kamar.
    await _supabase.from(_tableRooms).delete().eq('id', id);
  }

  // ============================================================
  // HELPERS
  // ============================================================

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
        .map((facilityId) => {'room_id': roomId, 'facility_id': facilityId})
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

      final paths = files.map((file) => 'rooms/$roomId/${file.name}').toList();

      await _supabase.storage.from(_storageBucket).remove(paths);
    } catch (_) {
      // Best-effort.
      // Gagal menghapus storage tidak menggagalkan
      // proses utama hapus kamar.
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
