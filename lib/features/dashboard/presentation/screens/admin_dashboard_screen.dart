import 'dart:async';

import 'package:flutter/material.dart';

import '../../../rooms/data/services/room_service.dart';
import '../../../payments/data/services/payment_service.dart';
import '../../../complaints/data/services/complaint_service.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/services/activity_service.dart';
import '../../../activities/presentation/screens/activities_screen.dart';
import '../../data/services/dashboard_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_button_card.dart';
import '../widgets/activity_feed.dart';
import '../../../announcements/presentation/screens/admin_announcements_screen.dart';
import '../../../rooms/presentation/screens/add_room_screen.dart';
import '../../../rooms/presentation/screens/admin_facilities_screen.dart';
import '../../../payments/presentation/screens/admin_payment_methods_screen.dart';
import '../../../contracts/presentation/pages/contracts_page.dart';

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
  final _activityService = ActivityService();

  int totalRooms = 0;
  int occupiedRooms = 0;
  int tenantCount = 0;
  int totalIncome = 0;
  int activeComplaints = 0;
  List<ActivityModel>? activities;

  @override
  void initState() {
    super.initState();
    _loadRoomStats();
    _loadTenantCount();
    _loadIncome();
    _loadActiveComplaints();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final data = await _activityService.getRecentActivities();

    if (!mounted) return;

    setState(() {
      activities = data;
    });
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
                    subtitle: 'Total pemasukan',
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
            Row(
              children: [
                const Text(
                  'Aktivitas Terkini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (activities != null && activities!.length > 3)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActivitiesScreen(),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (activities == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else
              ActivityFeed(activities: activities!.take(3).toList()),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContractsPage(),
                  ),
                );
              },
            ),
            ActionButtonCard(
              title: 'Kelola Metode Pembayaran',
              icon: Icons.payment,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPaymentMethodsScreen(),
                  ),
                );
              },
            ),
            ActionButtonCard(
              title: 'Kelola Fasilitas',
              icon: Icons.checklist_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminFacilitiesScreen(),
                  ),
                );
              },
            ),
            ActionButtonCard(
              title: 'Kelola Pengumuman',
              icon: Icons.campaign_sharp,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAnnouncementsScreen(),
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
