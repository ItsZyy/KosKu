import 'package:flutter/material.dart';

import '../../data/models/facility_model.dart';
import 'room_facilities_card.dart';

/// Pemetaan icon untuk nama fasilitas yang umum.
/// Bisa diperluas bila ada fasilitas baru yang perlu icon tertentu.
IconData _iconForFacility(String name) {
  final n = name.toLowerCase();
  if (n.contains('kasur') || n.contains('bed')) {
    return Icons.bed_outlined;
  }
  if (n.contains('lemari')) {
    return Icons.checkroom_outlined;
  }
  if (n.contains('meja')) {
    return Icons.chair_outlined;
  }
  if (n.contains('tv')) {
    return Icons.tv_outlined;
  }
  if (n.contains('wifi') || n.contains('wi-fi') || n.contains('wi fi')) {
    return Icons.wifi;
  }
  if (n.contains('mandi') || n.contains('km')) {
    return Icons.shower_outlined;
  }
  if (n.contains('laundry') || n.contains('cuci')) {
    return Icons.local_laundry_service_outlined;
  }
  if (n.contains('ac')) {
    return Icons.ac_unit_outlined;
  }
  if (n.contains('kulkas') || n.contains('kitchen')) {
    return Icons.kitchen_outlined;
  }
  return Icons.check_circle_outline;
}

/// Mengonversi daftar [FacilityModel] dari database menjadi
/// opsi yang siap dipakai oleh [RoomFacilitiesCard].
List<RoomFacilityOption> buildRoomFacilityOptions(
  List<FacilityModel> facilities,
) {
  return facilities
      .where((f) => f.isActive)
      .map(
        (f) => RoomFacilityOption.fromFacility(
          f,
          icon: _iconForFacility(f.name),
        ),
      )
      .toList();
}
