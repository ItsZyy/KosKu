import 'package:flutter/material.dart';

import 'custom_text_field.dart';
import 'primary_button.dart';

class RegisterAccountForm extends StatefulWidget {
  final String email;
  final String password;
  final String confirmPassword;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final VoidCallback onNext;
  final bool isLoading;

  const RegisterAccountForm({
    super.key,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  State<RegisterAccountForm> createState() => _RegisterAccountFormState();
}

class _RegisterAccountFormState extends State<RegisterAccountForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
    _confirmPasswordController = TextEditingController(
      text: widget.confirmPassword,
    );

    _emailController.addListener(() {
      widget.onEmailChanged(_emailController.text);
    });

    _passwordController.addListener(() {
      widget.onPasswordChanged(_passwordController.text);
    });

    _confirmPasswordController.addListener(() {
      widget.onConfirmPasswordChanged(_confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    widget.onNext();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (value != _passwordController.text) {
      return 'Password tidak sama';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Email',
            hintText: 'Masukkan email',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Password',
            hintText: 'Masukkan password',
            prefixIcon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Konfirmasi Password',
            hintText: 'Masukkan ulang password',
            prefixIcon: Icons.lock_reset_outlined,
            controller: _confirmPasswordController,
            obscureText: true,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Lanjut',
            onPressed: _handleNext,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
