import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/profile_model.dart';
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

  ProfileModel? profile;
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Pemilik')),
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

    final name = profile!.name;
    final phone = profile!.phone ?? '-';

    final emergencyContact = [
      if (profile!.emergencyContactName != null &&
          profile!.emergencyContactName!.isNotEmpty)
        profile!.emergencyContactName!,
      if (profile!.emergencyContactPhone != null &&
          profile!.emergencyContactPhone!.isNotEmpty)
        profile!.emergencyContactPhone!,
      if (profile!.emergencyContactRelation != null &&
          profile!.emergencyContactRelation!.isNotEmpty)
        profile!.emergencyContactRelation!,
    ].join('\n');

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
              ProfileHeaderCard(name: name, onEdit: () {}),
              const SizedBox(height: 20),
              ProfileInfoCard(
                name: name,
                email: '-',
                phone: phone,
                address: emergencyContact.isEmpty ? '-' : emergencyContact,
              ),
              const SizedBox(height: 20),
              AccountSettingsCard(
                onChangePassword: () {},
                onNotification: () {},
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
