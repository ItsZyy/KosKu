import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  ProfileModel? profile;
  bool isLoading = true;
  bool isUploadingPhoto = false;
  String? profilePhotoUrl;

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

      if (data?.profilePhotoUrl != null && data!.profilePhotoUrl!.isNotEmpty) {
        final signedUrl = await _profileService.getProfilePhotoUrl(
          data.profilePhotoUrl,
        );

        if (!mounted) return;

        setState(() {
          profilePhotoUrl = signedUrl;
        });
      }
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

  Future<void> _pickProfilePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        isUploadingPhoto = true;
      });

      final Uint8List bytes = await image.readAsBytes();

      final extension = image.name.contains('.')
          ? image.name.split('.').last
          : 'jpg';

      final path = await _profileService.uploadProfilePhoto(
        bytes: bytes,
        fileExtension: extension,
      );

      final signedUrl = await _profileService.getProfilePhotoUrl(path);

      if (!mounted) return;

      setState(() {
        profilePhotoUrl = signedUrl;
        isUploadingPhoto = false;

        if (profile != null) {
          profile = ProfileModel(
            id: profile!.id,
            name: profile!.name,
            phone: profile!.phone,
            profilePhotoUrl: path,
            emergencyContactName: profile!.emergencyContactName,
            emergencyContactPhone: profile!.emergencyContactPhone,
            emergencyContactRelation: profile!.emergencyContactRelation,
            role: profile!.role,
            createdAt: profile!.createdAt,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
    }
  }

  Future<void> _deleteProfilePhoto() async {
    try {
      setState(() {
        isUploadingPhoto = true;
      });

      await _profileService.deleteProfilePhoto();

      if (!mounted) return;

      setState(() {
        profilePhotoUrl = null;
        isUploadingPhoto = false;

        if (profile != null) {
          profile = ProfileModel(
            id: profile!.id,
            name: profile!.name,
            phone: profile!.phone,
            profilePhotoUrl: null,
            emergencyContactName: profile!.emergencyContactName,
            emergencyContactPhone: profile!.emergencyContactPhone,
            emergencyContactRelation: profile!.emergencyContactRelation,
            role: profile!.role,
            createdAt: profile!.createdAt,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus foto: $e')));
    }
  }

  Future<void> _showPhotoOptions() async {
    if (isUploadingPhoto) return;

    final hasPhoto = profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto();
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Hapus foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteProfilePhoto();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
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
              ProfileHeaderCard(
                name: name,
                profilePhotoUrl: profilePhotoUrl,
                onEdit: () {},
                onEditPhoto: _showPhotoOptions,
              ),
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
