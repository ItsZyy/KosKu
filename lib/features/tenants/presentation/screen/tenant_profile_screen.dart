import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/models/occupancy_model.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/data/services/occupancy_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../profile/presentation/widgets/profile_header_card.dart';
import '../../../profile/presentation/widgets/profile_info_card.dart';
import '../../../profile/presentation/widgets/room_detail_card.dart';
import '../../data/models/tenant_model.dart';

class TenantProfileScreen extends StatefulWidget {
  final TenantModel tenant;

  const TenantProfileScreen({super.key, required this.tenant});

  @override
  State<TenantProfileScreen> createState() => _TenantProfileScreenState();
}

class _TenantProfileScreenState extends State<TenantProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final OccupancyService _occupancyService = OccupancyService();

  ProfileModel? _profile;
  OccupancyModel? _occupancy;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = widget.tenant.userId;

      final profile = await _profileService.getProfileById(userId);

      final occupancy = await _occupancyService.getActiveOccupancyByUserId(
        userId,
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _occupancy = occupancy;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatPrice(double price) {
    final value = price.toStringAsFixed(0);
    final parts = <String>[];

    for (var i = value.length; i > 0; i -= 3) {
      final start = i - 3 < 0 ? 0 : i - 3;
      parts.insert(0, value.substring(start, i));
    }

    return 'Rp ${parts.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil ${widget.tenant.name}')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    if (_profile == null) {
      return const Center(child: Text('Profil penghuni tidak ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;
    final occupancy = _occupancy;

    final photoUrl = ProfileService.resolveProfilePhotoUrl(
      profile.profilePhotoUrl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderCard(
          name: profile.name,
          roleLabel: 'Penghuni',
          roomNumber:
              occupancy?.roomNumber ?? widget.tenant.roomNumber,
          profilePhotoUrl: photoUrl,
        ),
        const SizedBox(height: 20),
        ProfileInfoCard(
          title: 'Informasi Kontak',
          name: profile.name,
          email: '-',
          phone: profile.phone ?? widget.tenant.phone ?? '-',
          address: profile.address ?? '',
          addressLabel: 'Asal Kota',
          emergencyName: profile.emergencyContactName,
          emergencyPhone: profile.emergencyContactPhone,
          emergencyRelation: profile.emergencyContactRelation,
        ),
        const SizedBox(height: 20),
        if (occupancy != null)
          RoomDetailCard(
            roomNumber: occupancy.roomNumber,
            contractStart: _formatDate(occupancy.contractStart),
            contractEnd: _formatDate(occupancy.contractEnd),
            rentPrice: _formatPrice(occupancy.rentPrice),
            dueDate:
                'Tanggal ${occupancy.contractStart.day} setiap '
                '${occupancy.paymentIntervalMonths} bulan',
            facilities: occupancy.facilities,
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Belum ada data kamar aktif.'),
            ),
          ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('Gagal memuat profil penghuni'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}