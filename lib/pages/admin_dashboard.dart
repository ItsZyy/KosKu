import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService();

  int totalRooms = 0;
  int occupiedRooms = 0;
  int tenantCount = 0;
  int totalIncome = 0;

  @override
  void initState() {
    super.initState();
    _loadRoomStats();
    _loadTenantCount();
    _loadIncome();
  }

  Future<void> _loadRoomStats() async {
    final data = await _authService.getRoomStats();

    if (!mounted) return;

    setState(() {
      totalRooms = data['total'] ?? 0;
      occupiedRooms = data['terisi'] ?? 0;
    });
  }

  Future<void> _loadTenantCount() async {
    final data = await _authService.getTenantCount();

    if (!mounted) return;

    setState(() {
      tenantCount = data;
    });
  }

  Future<void> _loadIncome() async {
    final data = await _authService.getTotalIncome();

    if (!mounted) return;

    setState(() {
      totalIncome = data;
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
                  child: _buildStatCard(
                    'Total Kamar',
                    '$occupiedRooms / $totalRooms',
                    'Kamar terisi',
                    Icons.meeting_room,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Jumlah Penghuni',
                    '$tenantCount',
                    'Penghuni aktif',
                    Icons.people,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pendapatan',
                    'Rp $totalIncome',
                    'Bulan ini',
                    Icons.payments,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Keluhan Aktif',
                    '3',
                    'Perlu ditangani',
                    Icons.report_problem,
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

            _buildActionButton(context, 'Tambah Kamar', Icons.add_home, () {}),

            _buildActionButton(
              context,
              'Tambah Penghuni',
              Icons.person_add,
              () {},
            ),

            _buildActionButton(
              context,
              'Kelola Kontrak',
              Icons.description,
              () {},
            ),

            _buildActionButton(
              context,
              'Kelola Pembayaran',
              Icons.payment,
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }
}
