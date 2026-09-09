import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/services/auth_service.dart';
import '../widgets/edit_profile_actions.dart';
import '../widgets/edit_profile_section.dart';
import '../widgets/password_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSaving = false;

  Future<void> _savePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      _showMessage('Password saat ini wajib diisi');
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage('Password baru wajib diisi');
      return;
    }

    if (newPassword.length < 8) {
      _showMessage('Password baru minimal 8 karakter');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage('Konfirmasi password wajib diisi');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Konfirmasi password tidak cocok');
      return;
    }

    if (currentPassword == newPassword) {
      _showMessage('Password baru harus berbeda dari password lama');
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      final message = e.toString().contains('Invalid login credentials')
          ? 'Password saat ini salah'
          : 'Gagal mengubah password';

      _showMessage(message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Ganti Password', style: AppTextStyles.titleLarge),
        leading: IconButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          children: [
            Container(
              width: 89,
              height: 87,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E3F6),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 4),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gunakan password yang kuat dan mudah kamu ingat untuk menjaga keamanan akun.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            EditProfileSection(
              title: 'Password',
              child: Column(
                children: [
                  PasswordTextField(
                    label: 'Password Saat Ini',
                    hint: 'Masukkan password saat ini',
                    controller: _currentPasswordController,
                  ),
                  const SizedBox(height: 20),
                  PasswordTextField(
                    label: 'Password Baru',
                    hint: 'Minimal 8 karakter',
                    controller: _newPasswordController,
                  ),
                  const SizedBox(height: 20),
                  PasswordTextField(
                    label: 'Konfirmasi Password Baru',
                    hint: 'Ulangi password baru',
                    controller: _confirmPasswordController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            EditProfileActions(
              isSaving: _isSaving,
              onSave: _savePassword,
              onCancel: () {
                if (!_isSaving) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
