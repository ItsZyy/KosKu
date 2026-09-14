import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/services/payment_method_service.dart';
import '../widgets/admin_payment_method_form.dart';

class AdminEditPaymentMethodScreen extends StatelessWidget {
  final PaymentMethodModel paymentMethod;

  AdminEditPaymentMethodScreen({super.key, required this.paymentMethod});

  final _paymentMethodService = PaymentMethodService();

  Future<void> _updatePaymentMethod({
    required String type,
    String? bankName,
    String? accountNumber,
    String? accountName,
    File? qrisImage,
  }) async {
    if (type == 'bank') {
      await _paymentMethodService.updateBank(
        id: paymentMethod.id,
        bankName: bankName!,
        accountNumber: accountNumber!,
        accountName: accountName!,
      );

      return;
    }

    if (type == 'qris') {
      String? qrisPath;

      if (qrisImage != null) {
        qrisPath = await _paymentMethodService.uploadQris(qrisImage);
      }

      await _paymentMethodService.updateQris(
        id: paymentMethod.id,
        qrisImageUrl: qrisPath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Metode Pembayaran')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Metode Pembayaran',
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Perbarui informasi rekening atau QRIS '
                'yang digunakan penghuni.',
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
                  child: AdminPaymentMethodForm(
                    initialPaymentMethod: paymentMethod,
                    onSubmit: _updatePaymentMethod,
                  ),
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
