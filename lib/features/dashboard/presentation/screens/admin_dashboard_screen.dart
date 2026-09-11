import 'dart:async';

import 'package:flutter/material.dart';

import '../../../rooms/data/services/room_service.dart';
import '../../../payments/data/services/payment_service.dart';
import '../../../complaints/data/services/complaint_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/services/activity_service.dart';
import '../../../activities/presentation/screens/activities_screen.dart';
import '../../data/services/dashboard_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_button_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/admin_dashboard_header.dart';
import '../../../announcements/presentation/screens/admin_announcements_screen.dart';
import '../../../rooms/presentation/screens/add_room_screen.dart';
import '../../../rooms/presentation/screens/admin_facilities_screen.dart';
import '../../../payments/presentation/screens/admin_payment_methods_screen.dart';
import '../../../contracts/presentation/pages/contracts_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenProfile;

  const AdminDashboardScreen({super.key, this.onOpenProfile});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _roomService = RoomService();
  final _paymentService = PaymentService();
  final _complaintService = ComplaintService();
  final _dashboardService = DashboardService();
  final _activityService = ActivityService();
  final _profileService = ProfileService();

  int totalRooms = 0;
  int occupiedRooms = 0;
  int tenantCount = 0;
  int totalIncome = 0;
  int activeComplaints = 0;
  List<ActivityModel>? activities;

  String? userName;
  String? profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadRoomStats();
    _loadTenantCount();
    _loadIncome();
    _loadActiveComplaints();
    _loadActivities();
    _loadUser();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadRoomStats(),
      _loadTenantCount(),
      _loadIncome(),
      _loadActiveComplaints(),
      _loadActivities(),
      _loadUser(),
    ]);
  }

  Future<void> _loadUser() async {
    try {
      final profile = await _profileService.getProfile();

      if (profile != null && mounted) {
        setState(() {
          userName = profile.name;
        });

        if (profile.profilePhotoUrl != null &&
            profile.profilePhotoUrl!.isNotEmpty) {
          final signedUrl = await _profileService.getProfilePhotoUrl(
            profile.profilePhotoUrl,
          );

          if (mounted) {
            setState(() {
              profilePhotoUrl = signedUrl;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('AdminDashboard load user error: $e');
    }
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

  void _openActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActivitiesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AdminDashboardHeader(
                    userName: userName,
                    profilePhotoUrl: profilePhotoUrl,
                    onProfileTap: widget.onOpenProfile,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Kamar',
                            value: '$totalRooms / $occupiedRooms',
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
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (activities != null && activities!.length > 3)
                          TextButton(
                            onPressed: _openActivities,
                            child: const Text('Lihat Semua'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (activities == null)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}