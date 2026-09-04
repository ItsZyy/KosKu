import 'package:flutter/material.dart';

import 'room_facilities_card.dart';

/// Single source of truth untuk daftar fasilitas kamar di UI.
/// Dipakai oleh RoomFacilitiesCard sehingga mudah diperluas ketika
/// database sudah mendukung tabel `facilities` terpisah.
final List<RoomFacilityOption> kRoomFacilityOptions = [
  RoomFacilityOption(key: 'Meja', label: 'Meja', icon: Icons.chair_outlined),
  RoomFacilityOption(key: 'WiFi', label: 'WiFi', icon: Icons.wifi),
  RoomFacilityOption(key: 'Kasur', label: 'Kasur', icon: Icons.bed_outlined),
  RoomFacilityOption(key: 'KM Dalam', label: 'KM Dalam', icon: Icons.shower_outlined),
  RoomFacilityOption(key: 'Lemari', label: 'Lemari', icon: Icons.checkroom_outlined),
  RoomFacilityOption(key: 'Laundry', label: 'Laundry', icon: Icons.local_laundry_service_outlined),
];

/// TODO(facilities): `rooms.facilities` saat ini masih berupa `text`.
/// Konversi dari `List<String>` UI ke format persistence.
/// Saat ini di-join dengan koma sesuai schema lama. Ketika schema
/// sudah migrasi ke tabel `facilities` + `room_facilities` (relasi),
/// ubah fungsi ini saja agar UI tidak perlu diubah.
String encodeFacilities(List<String> selected) {
  return selected.join(', ');
}