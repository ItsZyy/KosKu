import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';
import '../widgets/edit_profile_actions.dart';
import '../widgets/edit_profile_section.dart';
import '../widgets/profile_text_field.dart';

class EditAdminProfileScreen extends StatefulWidget {
  const EditAdminProfileScreen({super.key});

  @override
  State<EditAdminProfileScreen> createState() => _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState extends State<EditAdminProfileScreen> {
  final ProfileService _profileService = ProfileService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  ProfileModel? _profile;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _profile = profile;

      _nameController.text = profile.name;
      _emailController.text = _profileService.getEmail() ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.kosAddress ?? '';

      setState(() {
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

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama lengkap wajib diisi')));
      return;
    }

    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alamat kosan wajib diisi')));
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _profileService.updateProfile(
        name: name,
        phone: phone.isEmpty ? null : phone,
        kosAddress: address,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profil')),
        body: const Center(child: Text('Data profil tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          children: [
            EditProfileSection(
              title: 'Informasi Pemilik',
              child: Column(
                children: [
                  ProfileTextField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: 'Masukkan nama lengkap',
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Alamat Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: 'Alamat email',
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Nomor Telepon',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Masukkan nomor telepon',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Alamat Kosan',
                    controller: _addressController,
                    icon: Icons.home_outlined,
                    hint: 'Masukkan alamat kosan',
                    keyboardType: TextInputType.streetAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            EditProfileActions(
              isSaving: _isSaving,
              onSave: _saveProfile,
              onCancel: _cancel,
            ),
          ],
        ),
      ),
    );
  }
}
