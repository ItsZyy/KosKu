import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String addressLabel;
  final String nameLabel;
  final String? emergencyName;
  final String? emergencyPhone;
  final String? emergencyRelation;

  const ProfileInfoCard({
    super.key,
    this.title = 'Informasi Pemilik',
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
    this.addressLabel = 'Alamat Kostan',
    this.nameLabel = 'Nama Lengkap',
    this.emergencyName,
    this.emergencyPhone,
    this.emergencyRelation,
  });

  @override
  Widget build(BuildContext context) {
    final hasEmergencyContact =
        emergencyName != null ||
        emergencyPhone != null ||
        emergencyRelation != null;

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
            const SizedBox(height: 18),
            _InfoItem(
              icon: Icons.person_outline,
              label: nameLabel,
              value: name,
            ),
            const Divider(height: 24),
            _InfoItem(icon: Icons.email_outlined, label: 'Email', value: email),
            const Divider(height: 24),
            _InfoItem(
              icon: Icons.phone_outlined,
              label: 'Nomor Telepon',
              value: phone,
            ),
            if (address.isNotEmpty) ...[
              const Divider(height: 24),
              _InfoItem(
                icon: Icons.home_outlined,
                label: addressLabel,
                value: address,
              ),
            ],
            if (hasEmergencyContact) ...[
              const Divider(height: 24),
              _EmergencySection(
                name: emergencyName ?? '-',
                phone: emergencyPhone ?? '-',
                relation: emergencyRelation ?? '-',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21),
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
    );
  }
}

class _EmergencySection extends StatelessWidget {
  final String name;
  final String phone;
  final String relation;

  const _EmergencySection({
    required this.name,
    required this.phone,
    required this.relation,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contact_emergency_outlined, size: 21, color: primary),
            const SizedBox(width: 12),
            const Text(
              'Kontak Darurat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _EmergencyItem(icon: Icons.person_outline, label: 'Nama', value: name),
        const SizedBox(height: 16),
        _EmergencyItem(
          icon: Icons.phone_outlined,
          label: 'Nomor Telepon',
          value: phone,
        ),
        const SizedBox(height: 16),
        _EmergencyItem(
          icon: Icons.people_outline,
          label: 'Hubungan',
          value: relation,
        ),
      ],
    );
  }
}

class _EmergencyItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EmergencyItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21),
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
    );
  }
}
