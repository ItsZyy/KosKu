import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contract_model.dart';

class ContractService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ContractModel>> getContracts({String? statusFilter}) async {
    final data = await _supabase
        .from('occupancies')
        .select('''
          id,
          user_id,
          room_id,
          contract_start,
          contract_end,
          rent_price,
          payment_interval_months,
          payment_day,
          status,
          profiles!occupancies_user_id_fkey (
            id,
            name,
            phone,
            profile_photo_url
          )
        ''')
        .order('contract_start', ascending: false);

    final list = List<Map<String, dynamic>>.from(data);

    await _attachRoomNumbers(list);

    var contracts = list
        .map<ContractModel>((item) => ContractModel.fromMap(item))
        .toList();

    if (statusFilter != null && statusFilter.isNotEmpty) {
      final wanted = statusFilter.toLowerCase();

      contracts = contracts
          .where((contract) => contract.status.toLowerCase() == wanted)
          .toList();
    }

    return contracts;
  }

  Future<ContractModel?> getContractDetail(String occupancyId) async {
    final data = await _supabase
        .from('occupancies')
        .select('''
          id,
          user_id,
          room_id,
          contract_start,
          contract_end,
          rent_price,
          payment_interval_months,
          payment_day,
          status,
          profiles!occupancies_user_id_fkey (
            id,
            name,
            phone,
            profile_photo_url
          )
        ''')
        .eq('id', occupancyId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);

    await _attachRoomNumbers([map]);

    return ContractModel.fromMap(map);
  }

  Future<bool> renewContract(String occupancyId) async {
    final result = await _supabase.rpc(
      'renew_contract',
      params: {'p_occupancy_id': occupancyId},
    );

    return result == true;
  }

  Future<bool> completeContract(String occupancyId) async {
    final result = await _supabase.rpc(
      'complete_contract',
      params: {'p_occupancy_id': occupancyId},
    );

    return result == true;
  }

  Future<void> _attachRoomNumbers(
    List<Map<String, dynamic>> occupancies,
  ) async {
    if (occupancies.isEmpty) {
      return;
    }

    final roomIds = occupancies
        .map((item) => item['room_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (roomIds.isEmpty) {
      return;
    }

    final rooms = await _supabase
        .from('rooms')
        .select('id, room_number')
        .inFilter('id', roomIds);

    final roomMap = <String, Map<String, dynamic>>{
      for (final room in rooms)
        room['id'].toString(): Map<String, dynamic>.from(room),
    };

    for (final item in occupancies) {
      final roomId = item['room_id']?.toString();

      if (roomId != null && roomMap.containsKey(roomId)) {
        item['rooms'] = roomMap[roomId];
      }
    }
  }
}
