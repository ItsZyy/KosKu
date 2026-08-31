import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/profile_service.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/logout_card.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ProfileService _profileService = ProfileService();

  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.getProfile();

      if (!mounted) return;

      setState(() {
        profile = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil profil: $e')));
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = profile?['name']?.toString() ?? 'Pemilik Kos';
    final email = profile?['email']?.toString() ?? '-';
    final phone = profile?['phone']?.toString() ?? '-';
    final address = profile?['address']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pemilik')),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeaderCard(
                name: name,
                onEdit: () {
                  // Edit profil dibuat di tahap berikutnya.
                },
              ),

              const SizedBox(height: 20),

              ProfileInfoCard(
                name: name,
                email: email,
                phone: phone,
                address: address,
              ),

              const SizedBox(height: 20),

              AccountSettingsCard(
                onChangePassword: () {
                  // Ubah password dibuat di tahap berikutnya.
                },
                onNotification: () {
                  // Pengaturan notifikasi dibuat di tahap berikutnya.
                },
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
