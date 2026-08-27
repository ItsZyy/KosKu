import 'package:flutter/material.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../rooms/data/services/room_service.dart';
import '../../../payments/data/services/payment_service.dart';
import '../../../announcements/data/models/announcement_model.dart';
import '../../../announcements/data/services/announcement_service.dart';
import '../../../announcements/presentation/widgets/announcement_card.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _profileService = ProfileService();
  final _roomService = RoomService();
  final _paymentService = PaymentService();
  final _announcementService = AnnouncementService();

  String? userName;

  Map<String, dynamic>? room;
  Map<String, dynamic>? payment;
  AnnouncementModel? announcement;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRoom();
    _loadPayment();
    _loadAnnouncement();
  }

  Future<void> _loadRoom() async {
    final profile = await _profileService.getProfile();
    if (profile == null) return;
    final data = await _roomService.getRoom();

    if (data != null && mounted) {
      setState(() {
        room = data;
      });
    }
  }

  Future<void> _loadUser() async {
    final profile = await _profileService.getProfile();

    if (profile != null && mounted) {
      setState(() {
        userName = profile['name'];
      });
    }
  }

  Future<void> _loadPayment() async {
    final data = await _paymentService.getPayment();

    if (data != null && mounted) {
      setState(() {
        payment = data;
      });
    }
  }

  Future<void> _loadAnnouncement() async {
    final data = await _announcementService.getAnnouncements();

    if (data.isNotEmpty && mounted) {
      setState(() {
        announcement = data.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KosKu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${userName ?? 'Penghuni'} 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Selamat datang di KosKu',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            const Text(
              'Tagihan Bulan Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rp ${payment?['amount'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      payment?['status'] ?? '-',
                      style: TextStyle(color: Colors.red),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Lihat Pembayaran'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Informasi Kamar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room?['room_number'] ?? '-',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text('Kapasitas: ${room?['capacity'] ?? '-'} orang'),

                    SizedBox(height: 4),

                    Text('Status: ${room?['status'] ?? '-'}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            announcement != null
                ? AnnouncementCard(announcement: announcement!)
                : const Card(
                    child: ListTile(
                      title: Text('Pengumuman'),
                      subtitle: Text('Belum ada pengumuman terbaru'),
                    ),
                  ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
