import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String addressLabel;
  final String nameLabel;

  const ProfileInfoCard({
    super.key,
    this.title = 'Informasi Pemilik',
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.addressLabel = 'Alamat Kostan',
    this.nameLabel = 'Nama Lengkap',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _buildInfo(Icons.person_outline, nameLabel, name),

            const Divider(),

            _buildInfo(Icons.email_outlined, 'Email', email),

            const Divider(),

            _buildInfo(Icons.phone_outlined, 'Nomor Telepon', phone),

            const Divider(),

            _buildInfo(Icons.home_outlined, addressLabel, address),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
