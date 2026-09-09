import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/occupancy_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/occupancy_service.dart';
import '../../data/services/profile_service.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/logout_card.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/room_detail_card.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final OccupancyService _occupancyService = OccupancyService();
  final ImagePicker _imagePicker = ImagePicker();

  ProfileModel? _profile;
  OccupancyModel? _occupancy;

  bool _isLoading = true;
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
      final occupancy = await _occupancyService.getActiveOccupancy();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _occupancy = occupancy;
        _isLoading = false;
      });

      if (profile?.profilePhotoUrl != null &&
          profile!.profilePhotoUrl!.isNotEmpty) {
        final signedUrl = await _profileService.getProfilePhotoUrl(
          profile.profilePhotoUrl,
        );

        if (!mounted) return;

        setState(() {
          _profilePhotoUrl = signedUrl;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _profilePhotoUrl = null;
        });
      }
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

      await _loadProfile();

      if (!mounted) return;

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

      await _loadProfile();

      if (!mounted) return;

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

  Future<void> _editProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  Future<void> _changePassword() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
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

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
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
    final occupancy = _occupancy;

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
                roomNumber: occupancy?.roomNumber,
                profilePhotoUrl: _profilePhotoUrl,
                isUploadingPhoto: _isUploadingPhoto,
                onEdit: _editProfile,
                onEditPhoto: _editPhoto,
              ),
              const SizedBox(height: 20),
              ProfileInfoCard(
                title: 'Informasi Kontak',
                name: profile.name,
                email: _profileService.getEmail() ?? '-',
                phone: profile.phone ?? '-',
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
                  dueDate: 'Tanggal ${occupancy.paymentDay} setiap bulan',
                  facilities: occupancy.facilities,
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Belum ada data kamar aktif.'),
                  ),
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
