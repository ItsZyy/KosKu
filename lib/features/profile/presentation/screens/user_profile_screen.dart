import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/logout_card.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/room_detail_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileService _profileService = ProfileService();

  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
    }
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur edit profil akan segera dibuat')),
    );
  }

  void _editPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ubah foto akan segera dibuat')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ubah password akan segera dibuat')),
    );
  }

  void _notification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan notifikasi akan segera dibuat')),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await _profileService.logout();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: RefreshIndicator(
          onRefresh: _loadProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 300),
              Center(child: Text('Data profil tidak ditemukan')),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    final emergencyContact = [
      if (profile.emergencyContactName != null &&
          profile.emergencyContactName!.isNotEmpty)
        profile.emergencyContactName!,
      if (profile.emergencyContactPhone != null &&
          profile.emergencyContactPhone!.isNotEmpty)
        profile.emergencyContactPhone!,
      if (profile.emergencyContactRelation != null &&
          profile.emergencyContactRelation!.isNotEmpty)
        profile.emergencyContactRelation!,
    ].join('\n');

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderCard(
                name: profile.name,
                roleLabel: 'Penghuni',
                roomNumber: '03',
                onEdit: _editProfile,
                onEditPhoto: _editPhoto,
              ),
              const SizedBox(height: 20),
              ProfileInfoCard(
                title: 'Informasi Kontak',
                name: profile.name,
                email: '-',
                phone: profile.phone ?? '-',
                address: emergencyContact.isEmpty ? '-' : emergencyContact,
                addressLabel: 'Kontak Darurat',
              ),
              const SizedBox(height: 20),
              RoomDetailCard(
                roomNumber: '03',
                contractStart: 'Juni 2026',
                contractEnd: 'Juni 2027',
                rentPrice: 'Rp 1.650.000',
                dueDate: 'Tanggal 5 setiap bulan',
                facilities: const ['Kasur', 'Kamar Mandi', 'WiFi'],
              ),
              const SizedBox(height: 20),
              AccountSettingsCard(
                onChangePassword: _changePassword,
                onNotification: _notification,
              ),
              const SizedBox(height: 20),
              LogoutCard(onLogout: _logout),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
