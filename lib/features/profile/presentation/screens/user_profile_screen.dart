import 'package:flutter/material.dart';

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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Logout akan segera diproses')),
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER PROFIL
            ProfileHeaderCard(
              name: 'Ezy M Ikbal',
              roleLabel: 'Penghuni',
              roomNumber: '03',
              onEdit: _editProfile,
              onEditPhoto: _editPhoto,
            ),

            const SizedBox(height: 20),

            // INFORMASI KONTAK
            ProfileInfoCard(
              title: 'Informasi Kontak',
              name: 'Ezy M Ikbal',
              email: 'ezymikbal@gmail.com',
              phone: '+62 812-1503-5275',
              address: 'Ibunya Ezy\n+62 812-3456-789',
              addressLabel: 'Kontak Darurat',
            ),

            const SizedBox(height: 20),

            // DETAIL KAMAR
            RoomDetailCard(
              roomNumber: '03',
              contractStart: 'Juni 2026',
              contractEnd: 'Juni 2027',
              rentPrice: 'Rp 1.650.000',
              dueDate: 'Tanggal 5 setiap bulan',
              facilities: const ['Kasur', 'Kamar Mandi', 'WiFi'],
            ),

            const SizedBox(height: 20),

            // PENGATURAN AKUN
            AccountSettingsCard(
              onChangePassword: _changePassword,
              onNotification: _notification,
            ),

            const SizedBox(height: 20),

            // LOGOUT
            LogoutCard(onLogout: _logout),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
