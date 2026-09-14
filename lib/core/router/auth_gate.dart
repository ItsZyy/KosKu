import 'package:flutter/material.dart';

import '../../features/auth/data/services/auth_service.dart';
import '../../shared/loading_widget.dart';
import 'app_router.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _handleEntry();
  }

  Future<void> _handleEntry() async {
    String? role;

    try {
      role = await _authService.resolveSessionRole();
    } catch (_) {
      role = null;
    }

    if (!mounted) return;

    final route = role == 'admin'
        ? AppRouter.adminDashboard
        : role == 'user'
        ? AppRouter.userDashboard
        : AppRouter.login;

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingWidget(),
    );
  }
}