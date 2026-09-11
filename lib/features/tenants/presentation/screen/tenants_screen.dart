import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/tenant_model.dart';
import '../../data/services/tenant_service.dart';
import '../widgets/tenant_list.dart';
import '../widgets/tenant_search.dart';
import '../widgets/tenant_summary.dart';
import 'tenant_profile_screen.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final TenantService _tenantService = TenantService();

  List<TenantModel> _tenants = [];
  List<TenantModel> _filteredTenants = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tenants = await _tenantService.getTenants();

      if (!mounted) return;

      setState(() {
        _tenants = tenants;
        _filteredTenants = tenants;
        _isLoading = false;
      });

      _handleSearch(_searchController.text);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String query) {
    final keyword = query.trim().toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        _filteredTenants = _tenants;
        return;
      }

      _filteredTenants = _tenants.where((tenant) {
        return tenant.name.toLowerCase().contains(keyword) ||
            tenant.roomNumber.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  void _handleDetail(TenantModel tenant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantProfileScreen(tenant: tenant),
      ),
    );
  }

  Future<void> _handleToggleStatus(TenantModel tenant) async {
    final isActive = tenant.status.toLowerCase() == 'active';

    final action = isActive ? 'menonaktifkan' : 'mengaktifkan';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isActive ? 'Nonaktifkan Penghuni' : 'Aktifkan Penghuni'),
          content: Text(
            isActive
                ? 'Apakah kamu yakin ingin menonaktifkan '
                      '${tenant.name}? Penghuni akan dikeluarkan '
                      'dari status aktif kamar.'
                : 'Apakah kamu yakin ingin mengaktifkan kembali '
                      '${tenant.name}? Sistem akan mengecek '
                      'kapasitas kamar terlebih dahulu.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      if (isActive) {
        await _tenantService.deactivateTenant(tenant.id);
      } else {
        await _tenantService.activateTenant(tenant.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tenant.name} berhasil $action.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _loadTenants();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal $action: $message'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleAddTenant() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur tambah penghuni belum tersedia'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Penghuni')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    final activeTenants = _tenants
        .where((tenant) => tenant.status.toLowerCase() == 'active')
        .toList();

    return RefreshIndicator(
      onRefresh: _loadTenants,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              totalTenants: activeTenants.length,
              occupiedRooms: activeTenants
                  .map((tenant) => tenant.roomId)
                  .toSet()
                  .length,
            ),
            const SizedBox(height: 20),
            Text('Daftar Penghuni', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            TenantList(
              tenants: _filteredTenants,
              onDetail: _handleDetail,
              onToggleStatus: _handleToggleStatus,
            ),
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
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Gagal memuat penghuni', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTenants,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
