import 'package:flutter/material.dart';
import '../../../profile/data/profile_service.dart';
import '../../../rooms/data/room_service.dart';
import '../../../payments/data/payment_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _profileService = ProfileService();
  final _roomService = RoomService();
  final _paymentService = PaymentService();

  String? userName;

  Map<String, dynamic>? room;
  Map<String, dynamic>? payment;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRoom();
    _loadPayment();
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

            const Text(
              'Pengumuman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                title: Text('Pengumuman Kos'),
                subtitle: Text('Belum ada pengumuman terbaru.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
