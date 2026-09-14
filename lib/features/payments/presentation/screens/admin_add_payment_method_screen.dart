import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/services/payment_method_service.dart';
import '../widgets/admin_payment_method_form.dart';

class AdminAddPaymentMethodScreen extends StatelessWidget {
  AdminAddPaymentMethodScreen({super.key});

  final _paymentMethodService = PaymentMethodService();

  Future<void> _savePaymentMethod({
    required String type,
    String? bankName,
    String? accountNumber,
    String? accountName,
    File? qrisImage,
  }) async {
    if (type == 'bank') {
      await _paymentMethodService.createBank(
        bankName: bankName!,
        accountNumber: accountNumber!,
        accountName: accountName!,
      );

      return;
    }

    if (type == 'qris') {
      if (qrisImage == null) {
        throw Exception('Gambar QRIS belum dipilih');
      }

      final qrisPath = await _paymentMethodService.uploadQris(qrisImage);

      await _paymentMethodService.createQris(qrisImageUrl: qrisPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Metode Pembayaran')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Metode Pembayaran',
                style: AppTextStyles.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                'Tambahkan rekening bank atau QRIS '
                'yang dapat digunakan penghuni.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AdminPaymentMethodForm(onSubmit: _savePaymentMethod),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
