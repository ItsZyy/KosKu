import 'package:kosku/features/rooms/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // mengambil kamar yang sedang di tempati oleh penghuni #user/penghuni
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
          room_number,
          capacity,
          status,
          facilities,
          description
        )
      ''')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return data['rooms'];
  }

  // statik room di dashboard admin #pemilik
  Future<Map<String, int>> getRoomStats() async {
    final data = await _supabase.from('rooms').select('id, status');

    int total = data.length;
    int terisi = data.where((room) => room['status'] == 'Terisi').length;

    return {'total': total, 'terisi': terisi};
  }

  // admin room management

  //mengambil semua kamar
  Future<List<RoomModel>> getRooms() async {
    final data = await _supabase
        .from('rooms')
        .select()
        .order('room_number', ascending: true);

    return data.map<RoomModel>((item) => RoomModel.fromMap(item)).toList();
  }

  //tambah kamar
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

  // Edit/ubah kamar
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

  // hapus kamar
  Future<void> deleteRoom(String id) async {
    await _supabase.from('rooms').delete().eq('id', id);
  }
}
