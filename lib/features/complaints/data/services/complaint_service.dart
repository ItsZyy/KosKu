import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/complaint_model.dart';

class ComplaintService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Jumlah laporan aktif
  Future<int> getActiveComplaints() async {
    final data = await _supabase.from('complaints').select('id').inFilter(
      'status',
      ['Menunggu', 'Diproses'],
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

      if (status == 'Menunggu') {
        menunggu++;
      } else if (status == 'Diproses') {
        diproses++;
      } else if (status == 'Selesai') {
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
        .select()
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

    if (status == 'Selesai') {
      updateData['resolved_at'] = DateTime.now().toIso8601String();
    } else {
      updateData['resolved_at'] = null;
    }

    await _supabase.from('complaints').update(updateData).eq('id', id);
  }
}
