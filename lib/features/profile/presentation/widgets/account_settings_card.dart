import 'package:flutter/material.dart';

class AccountSettingsCard extends StatelessWidget {
  final VoidCallback? onChangePassword;
  final VoidCallback? onNotification;

  const AccountSettingsCard({
    super.key,
    this.onChangePassword,
    this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Pengaturan Akun'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Ubah Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onChangePassword,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onNotification,
          ),
        ],
      ),
    );
  }
}
