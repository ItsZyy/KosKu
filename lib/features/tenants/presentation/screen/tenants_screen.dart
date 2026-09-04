import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/tenant_list.dart';
import '../widgets/tenant_search.dart';
import '../widgets/tenant_summary.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<TenantItem> _tenants = const [
    TenantItem(
      name: 'Alfikar Radestian',
      roomNumber: '02',
      joinedDate: '12 Jan 2026',
      status: 'Aktif',
    ),
    TenantItem(
      name: 'Dessray',
      roomNumber: '06',
      joinedDate: '05 Feb 2026',
      status: 'Aktif',
    ),
    TenantItem(
      name: 'Risyad Adrian Abbas',
      roomNumber: '05',
      joinedDate: '20 Jan 2026',
      status: 'Aktif',
    ),
    TenantItem(
      name: 'Galang Agung Munggaran',
      roomNumber: '04',
      joinedDate: '15 Jan 2026',
      status: 'Aktif',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    // Filtering akan kita sambungkan setelah data Supabase masuk.
  }

  void _handleDetail(TenantItem tenant) {
    // Detail penghuni akan dibuat setelah screen utama selesai.
  }

  void _handleAddTenant() {
    // Form tambah penghuni akan dibuat setelahnya.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Penghuni')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TenantSearch(
                controller: _searchController,
                onChanged: _handleSearch,
              ),
              const SizedBox(height: 16),

              TenantSummary(
                totalTenants: _tenants.length,
                occupiedRooms: _tenants.length,
              ),
              const SizedBox(height: 20),

              Text('Daftar Penghuni', style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),

              TenantList(tenants: _tenants, onDetail: _handleDetail),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleAddTenant,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Tambah Penghuni'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
