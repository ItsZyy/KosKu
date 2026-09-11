import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
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

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      final role = await _profileService.getRole();

      if (!mounted) {
        return;
      }

      if (role == 'user') {
        Navigator.pushReplacementNamed(context, AppRouter.userDashboard);
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
      } else {
        await _authService.logout();

        if (!mounted) {
          return;
        }

        throw Exception('Role pengguna tidak valid.');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $message'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, AppRouter.forgotPassword);
  }

  void _handleRegister() {
    Navigator.pushNamed(context, AppRouter.register);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 380;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 32,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 32),
                  LoginCard(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                    onSubmit: _handleLogin,
                    onForgotPassword: _handleForgotPassword,
                    onRegister: _handleRegister,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
