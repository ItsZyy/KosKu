import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Mengubah error login menjadi pesan yang ramah pengguna.
String friendlyLoginErrorMessage(Object error) {
  // Error jaringan / koneksi.
  final isNetworkError = error is AuthRetryableFetchException ||
      error is http.ClientException ||
      error is SocketException ||
      error is TimeoutException;

  if (isNetworkError) {
    return 'Tidak dapat terhubung ke server. '
        'Periksa koneksi internet kamu dan coba lagi.';
  }

  if (error is AuthException) {
    final message = error.message.toLowerCase();

    final isInvalidCredentials =
        message.contains('invalid login credentials') ||
            message.contains('invalid email or password') ||
            message.contains('invalid email/password') ||
            (message.contains('password') &&
                message.contains('incorrect'));

    if (isInvalidCredentials) {
      return 'Email atau password yang kamu masukkan salah.';
    }
  }

  final text = error.toString();

  // Kredensial salah / profil tidak ditemukan.
  if (text.contains('Profil pengguna tidak ditemukan')) {
    return 'Email atau password yang kamu masukkan salah.';
  }

  // Akun nonaktif.
  if (text.contains('Akun kamu sudah tidak aktif')) {
    return 'Akun kamu sudah tidak aktif. Silakan hubungi admin.';
  }

  // Error server atau error tidak dikenal.
  return 'Terjadi kesalahan. Silakan coba lagi beberapa saat.';
}