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

  Future<Map<String, int>> getRoomStats() async {
    final data = await _supabase.from(_tableRooms).select('id, status');

    final total = data.length;

    final terisi = data.where((room) {
      return room['status'] == 'Terisi';
    }).length;

    return {'total': total, 'terisi': terisi};
  }

  Future<List<RoomModel>> getRooms() async {
    final data = await _supabase
        .from(_tableRooms)
        .select()
        .order('room_number', ascending: true);

    return data.map<RoomModel>((item) => RoomModel.fromMap(item)).toList();
  }

  Future<RoomDetailModel?> getRoomDetail(String roomId) async {
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

    final occupantsData = await _supabase.rpc(
      'get_room_occupants',
      params: {'p_room_id': roomId},
    );

    final List<RoomDetailUser> users = [];

    for (final item in occupantsData) {
      final occupancy = Map<String, dynamic>.from(item);

      users.add(
        RoomDetailUser(
          userId: occupancy['user_id'].toString(),
          name: occupancy['name']?.toString() ?? '-',
          phone: occupancy['phone']?.toString(),
          profilePhotoUrl: occupancy['profile_photo_url']?.toString(),
          contractStart: _parseDate(occupancy['contract_start']),
          contractEnd: _parseDate(occupancy['contract_end']),
          rentPrice: (occupancy['rent_price'] as num?)?.toDouble() ?? 0,
          occupancyStatus: occupancy['status']?.toString(),
        ),
      );
    }

    final List<Payment> payments = [];

    final paymentsData = await _supabase
        .from('payments')
        .select('''
          id,
          user_id,
          room_id,
          description,
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
        .order('period', ascending: false);

    payments.addAll(
      paymentsData.map<Payment>(
        (item) => Payment.fromMap(Map<String, dynamic>.from(item)),
      ),
    );

    final List<ComplaintModel> complaints = [];

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
        .order('created_at', ascending: false);

    complaints.addAll(
      complaintsData.map<ComplaintModel>(
        (item) => ComplaintModel.fromMap(Map<String, dynamic>.from(item)),
      ),
    );

    return RoomDetailModel(
      room: room,
      facilities: facilities,
      users: users,
      payments: payments,
      complaints: complaints,
    );
  }

  Future<List<Map<String, dynamic>>> getAvailableUsers() async {
    final activeOccupancies = await _supabase
        .from('occupancies')
        .select('user_id')
        .eq('status', 'active');

    final occupiedUserIds = activeOccupancies
        .map<String>((item) => item['user_id'].toString())
        .toSet();

    final profiles = await _supabase
        .from('profiles')
        .select('''
          id,
          name,
          phone,
          profile_photo_url
        ''')
        .eq('role', 'user')
        .order('name', ascending: true);

    return profiles
        .where((profile) {
          final id = profile['id']?.toString();

          if (id == null) {
            return false;
          }

          return !occupiedUserIds.contains(id);
        })
        .map<Map<String, dynamic>>(
          (profile) => Map<String, dynamic>.from(profile),
        )
        .toList();
  }

  Future<void> addOccupancy({
    required String roomId,
    required String userId,
    required DateTime contractStart,
    required DateTime contractEnd,
    required double rentPrice,
    required int paymentIntervalMonths,
    required int paymentDay,
  }) async {
    final existing = await _supabase
        .from('occupancies')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'active')
        .maybeSingle();

    if (existing != null) {
      throw Exception('User tersebut masih memiliki kamar aktif.');
    }

    final room = await _supabase
        .from(_tableRooms)
        .select('capacity, status')
        .eq('id', roomId)
        .maybeSingle();

    if (room == null) {
      throw Exception('Kamar tidak ditemukan.');
    }

    if (room['status'] == 'Perbaikan') {
      throw Exception('Kamar sedang dalam perbaikan.');
    }

    final capacity = (room['capacity'] as num?)?.toInt() ?? 1;

    final activeOccupancies = await _supabase
        .from('occupancies')
        .select('id')
        .eq('room_id', roomId)
        .eq('status', 'active');

    final currentOccupantCount = activeOccupancies.length;

    if (currentOccupantCount >= capacity) {
      throw Exception('Kamar sudah penuh ($currentOccupantCount/$capacity).');
    }

    await _supabase.from('occupancies').insert({
      'room_id': roomId,
      'user_id': userId,
      'contract_start': contractStart.toIso8601String().split('T').first,
      'contract_end': contractEnd.toIso8601String().split('T').first,
      'rent_price': rentPrice,
      'status': 'active',
      'payment_interval_months': paymentIntervalMonths,
      'payment_day': paymentDay,
    });

    await _supabase
        .from(_tableRooms)
        .update({'status': 'Terisi'})
        .eq('id', roomId);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getRoomUsers() async {
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

    final Map<String, List<Map<String, dynamic>>> users = {};

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

      users.putIfAbsent(roomId, () => []);

      users[roomId]!.add({
        'name': profile?['name']?.toString(),
        'user_id': item['user_id']?.toString(),
        'contract_start': item['contract_start']?.toString(),
        'contract_end': item['contract_end']?.toString(),
      });
    }

    return users;
  }

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

  Future<void> updateRoom({
    required String id,
    required String roomNumber,
    required double price,
    required int capacity,
    required String status,
    String? description,
    List<String> facilityIds = const [],
    List<String> retainedImagePaths = const [],
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

    final retainedPaths = existingPaths
        .where((path) => retainedImagePaths.contains(path))
        .toList();

    List<String> newPaths = [];

    if (images.isNotEmpty) {
      newPaths = await uploadImages(roomId: id, images: images);
    }

    final allPaths = <String>[...retainedPaths, ...newPaths];

    final imageUrl = allPaths.isEmpty ? null : encodeImageUrls(allPaths);

    final pathsToDelete = existingPaths
        .where((path) => !retainedPaths.contains(path))
        .toList();

    if (pathsToDelete.isNotEmpty) {
      try {
        await _supabase.storage.from(_storageBucket).remove(pathsToDelete);
      } catch (_) {}
    }

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

  Future<void> deleteRoom(String id) async {
    await _supabase.from(_tableRoomFacilities).delete().eq('room_id', id);

    await _deleteStorageFiles(id);

    await _supabase.from(_tableRooms).delete().eq('id', id);
  }

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
    } catch (_) {}
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  Future<List<Map<String, dynamic>>> getUsersForOccupantSelection() async {
    final response = await _supabase
        .from('profiles')
        .select('''
          id,
          name,
          phone,
          profile_photo_url,
          occupancies!left(
            room_id,
            status,
            rooms(
              room_number
            )
          )
        ''')
        .eq('role', 'user')
        .order('name');

    return (response as List).map((item) {
      final data = Map<String, dynamic>.from(item);

      String? roomNumber;

      final occupancies = data['occupancies'];

      if (occupancies is List) {
        for (final occupancy in occupancies) {
          if (occupancy is! Map<String, dynamic>) {
            continue;
          }

          if (occupancy['status'] != 'active') {
            continue;
          }

          final room = occupancy['rooms'];

          if (room is Map<String, dynamic>) {
            roomNumber = room['room_number'] as String?;
          }

          break;
        }
      }

      return {
        'id': data['id'],
        'name': data['name'],
        'phone': data['phone'],
        'profile_photo_url': data['profile_photo_url'],
        'room_number': roomNumber,
      };
    }).toList();
  }

  Future<List<RoomModel>> getAvailableRooms() async {
    final roomsData = await _supabase
        .from(_tableRooms)
        .select()
        .order('room_number', ascending: true);

    final occupanciesData = await _supabase
        .from('occupancies')
        .select('room_id')
        .eq('status', 'active');

    final Map<String, int> occupantCounts = {};

    for (final occupancy in occupanciesData) {
      final roomId = occupancy['room_id']?.toString();

      if (roomId == null) {
        continue;
      }

      occupantCounts[roomId] = (occupantCounts[roomId] ?? 0) + 1;
    }

    final rooms = roomsData
        .map<RoomModel>(
          (item) => RoomModel.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();

    return rooms.where((room) {
      if (room.status.toLowerCase() == 'perbaikan') {
        return false;
      }

      final occupantCount = occupantCounts[room.id] ?? 0;

      return occupantCount < room.capacity;
    }).toList();
  }
}
