import 'dart:async';

import 'package:flutter/material.dart';
import '../../../rooms/data/services/room_service.dart';
import '../../../payments/data/services/payment_service.dart';
import '../../../complaints/data/services/complaint_service.dart';
import '../../data/services/dashboard_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_button_card.dart';
import '../../../announcements/presentation/screens/add_announcement_screen.dart';
import '../../../rooms/presentation/screens/add_room_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _roomService = RoomService();
  final _paymentService = PaymentService();
  final _complaintService = ComplaintService();
  final _dashboardService = DashboardService();

  int totalRooms = 0;
  int occupiedRooms = 0;
  int tenantCount = 0;
  int totalIncome = 0;
  int activeComplaints = 0;

  @override
  void initState() {
    super.initState();
    _loadRoomStats();
    _loadTenantCount();
    _loadIncome();
    _loadActiveComplaints();
  }

  Future<void> _loadRoomStats() async {
    final data = await _roomService.getRoomStats();

    if (!mounted) return;

    setState(() {
      totalRooms = data['total'] ?? 0;
      occupiedRooms = data['terisi'] ?? 0;
    });
  }

  Future<void> _loadTenantCount() async {
    final data = await _dashboardService.getTenantCount();

    if (!mounted) return;

    setState(() {
      tenantCount = data;
    });
  }

  Future<void> _loadIncome() async {
    final data = await _paymentService.getTotalIncome();

    if (!mounted) return;

    setState(() {
      totalIncome = data;
    });
  }

  Future<void> _loadActiveComplaints() async {
    final data = await _complaintService.getActiveComplaints();

    if (!mounted) return;

    setState(() {
      activeComplaints = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Halo, Pemilik Kos 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Kamar',
                    value: '$occupiedRooms / $totalRooms',
                    subtitle: 'Kamar terisi',
                    icon: Icons.meeting_room,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Jumlah Penghuni',
                    value: '$tenantCount',
                    subtitle: 'Penghuni aktif',
                    icon: Icons.people,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Pendapatan',
                    value: 'Rp $totalIncome',
                    subtitle: 'Bulan ini',
                    icon: Icons.payments,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Keluhan Aktif',
                    value: '$activeComplaints',
                    subtitle: 'Perlu ditangani',
                    icon: Icons.report_problem,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Aktivitas Terkini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: const Text('Belum Ada aktivitas terbaru'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ActionButtonCard(
              title: 'Tambah Kamar',
              icon: Icons.add_home,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRoomScreen(),
                  ),
                );
              },
            ),

            ActionButtonCard(
              title: 'Tambah Penghuni',
              icon: Icons.person_add,
              onPressed: () {},
            ),

            ActionButtonCard(
              title: 'Kelola Kontrak',
              icon: Icons.description,
              onPressed: () {},
            ),

            ActionButtonCard(
              title: 'Kelola Pembayaran',
              icon: Icons.payment,
              onPressed: () {},
            ),

            ActionButtonCard(
              title: 'Tambah Pengumuman Baru',
              icon: Icons.campaign_sharp,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAnnouncementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
