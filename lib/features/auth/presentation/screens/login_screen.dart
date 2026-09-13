import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/login_error_message.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

      final message = friendlyLoginErrorMessage(e);

      await _showLoginErrorDialog(message);
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

  Future<void> _showLoginErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 40,
          ),
          title: const Text('Login Gagal'),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Coba Lagi'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
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
      ),
    );
  }
}
