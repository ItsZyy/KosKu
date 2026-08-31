import 'package:flutter/material.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Keluar / Logout',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        onTap: onLogout,
      ),
    );
  }
}
