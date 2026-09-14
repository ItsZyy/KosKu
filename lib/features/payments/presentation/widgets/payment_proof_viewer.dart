// Widget untuk viewer bukti pembayaran (AdminPaymentDetailScreen & PaymentDetailScreen)
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PaymentProofViewer extends StatelessWidget {
  final String imageUrl;

  const PaymentProofViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: const Text('Bukti Pembayaran'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(80),
                panEnabled: true,
                scaleEnabled: true,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.overlayWhite,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFailedState();
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                'Gunakan dua jari untuk memperbesar dan memindahkan gambar.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.overlayWhite,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 64, color: AppColors.textDisabled),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Bukti pembayaran gagal dimuat.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}