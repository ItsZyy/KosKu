import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/facility_model.dart';

class FacilityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _tableFacilities = 'facilities';

  Future<List<FacilityModel>> getFacilities() async {
    final data = await _supabase
        .from(_tableFacilities)
        .select()
        .order('name', ascending: true);

    return data
        .map<FacilityModel>(
          (item) => FacilityModel.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<FacilityModel> updateFacilityPrice({
    required String id,
    required double price,
  }) async {
    final data = await _supabase
        .from(_tableFacilities)
        .update({'price': price})
        .eq('id', id)
        .select()
        .single();

    await _supabase.rpc('sync_pending_payment_facility_prices');

    return FacilityModel.fromMap(Map<String, dynamic>.from(data));
  }
}
