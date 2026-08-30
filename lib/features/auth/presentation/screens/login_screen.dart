import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../dashboard/presentation/screens/user_dashboard_screen.dart';
import '../../../dashboard/presentation/screens/admin_main_screen.dart';

import '../widgets/login_header.dart';
import '../widgets/login_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _profileService = ProfileService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      final role = await _profileService.getRole();

      if (!mounted) return;
      if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const LoginHeader(),
                const SizedBox(height: 32),
                LoginCard(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onSubmit: _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
