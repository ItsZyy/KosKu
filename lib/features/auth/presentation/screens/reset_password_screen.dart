// Halaman membuat password baru dari link reset password (deep link).
// Diakses setelah user membuka link recovery dari email dan masuk ke
// aplikasi melalui deep link Supabase. Tidak meminta password lama karena
// sesi recovery sudah valid dari Supabase.
import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../main.dart' show passwordRecoveryInProgress;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _authService = AuthService();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      _showMessage('Konfirmasi password tidak cocok.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updatePassword(newPassword: newPassword);

      await _authService.logout();

      if (!mounted) return;

      _showMessage('Password berhasil diperbarui. Silakan login dengan password baru.');

      passwordRecoveryInProgress = false;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      _showMessage('Gagal memperbarui password: $message', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBackToLogin() {
    passwordRecoveryInProgress = false;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: _isLoading ? null : _handleBackToLogin,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Buat Password Baru',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan password baru untuk mengganti password lama akun kamu.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Password Baru', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Minimal 8 karakter',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      final password = value ?? '';

                      if (password.isEmpty) {
                        return 'Password baru wajib diisi.';
                      }

                      if (password.length < 8) {
                        return 'Password minimal 8 karakter.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Konfirmasi Password Baru',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) {
                        _handleSavePassword();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Ulangi password baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      final confirm = value ?? '';

                      if (confirm.isEmpty) {
                        return 'Konfirmasi password wajib diisi.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSavePassword,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text('Simpan Password Baru'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isLoading ? null : _handleBackToLogin,
                    child: const Text('Kembali ke Login'),
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