import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';
import '../widgets/edit_profile_actions.dart';
import '../widgets/edit_profile_photo.dart';
import '../widgets/edit_profile_section.dart';
import '../widgets/profile_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyRelationController =
      TextEditingController();

  ProfileModel? _profile;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  String? _profilePhotoUrl;

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
      _addressController.text = profile.address ?? '';
      _emergencyNameController.text = profile.emergencyContactName ?? '';
      _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
      _emergencyRelationController.text =
          profile.emergencyContactRelation ?? '';

      if (profile.profilePhotoUrl != null &&
          profile.profilePhotoUrl!.isNotEmpty) {
        _profilePhotoUrl = await _profileService.getProfilePhotoUrl(
          profile.profilePhotoUrl,
        );
      }

      if (!mounted) return;

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

  Future<void> _pickProfilePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final bytes = await image.readAsBytes();

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
        _profilePhotoUrl = signedUrl;
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
    }
  }

  Future<void> _deleteProfilePhoto() async {
    try {
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      await _profileService.deleteProfilePhoto();

      if (!mounted) return;

      setState(() {
        _profilePhotoUrl = null;
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus foto: $e')));
    }
  }

  Future<void> _editPhoto() async {
    if (_isUploadingPhoto) return;

    final hasPhoto = _profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty;

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

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama lengkap wajib diisi')));
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _profileService.updateProfile(
        name: name,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        emergencyContactRelation:
            _emergencyRelationController.text.trim().isEmpty
            ? null
            : _emergencyRelationController.text.trim(),
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
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
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
            EditProfilePhoto(
              name: _profile!.name,
              profilePhotoUrl: _profilePhotoUrl,
              isUploading: _isUploadingPhoto,
              onEditPhoto: _editPhoto,
            ),
            const SizedBox(height: 28),
            EditProfileSection(
              title: 'Informasi Pribadi',
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
                    label: 'Asal Kota',
                    controller: _addressController,
                    icon: Icons.home_outlined,
                    hint: 'Masukkan asal kota',
                    keyboardType: TextInputType.streetAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            EditProfileSection(
              title: 'Emergency Contact',
              isEmergency: true,
              child: Column(
                children: [
                  ProfileTextField(
                    label: 'Nama Kontak',
                    controller: _emergencyNameController,
                    icon: Icons.person_outline,
                    hint: 'Nama kontak darurat',
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Nomor Kontak',
                    controller: _emergencyPhoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Nomor kontak darurat',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Hubungan',
                    controller: _emergencyRelationController,
                    icon: Icons.family_restroom_outlined,
                    hint: 'Contoh: Ayah',
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
