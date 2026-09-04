import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';
import '../../data/services/payment_service.dart';
import '../widgets/payment_items_section.dart';
import '../widgets/payment_status_badge.dart';

/// Halaman detail tagihan: menampilkan payments + payment_items.
class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;
  final Payment? initial;
  final bool isAdmin;

  const PaymentDetailScreen({
    super.key,
    required this.paymentId,
    this.initial,
    this.isAdmin = false,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final _paymentService = PaymentService();

  Payment? _payment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payment = widget.initial;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final payment = await _paymentService.getPaymentDetail(widget.paymentId);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tagihan')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final payment = _payment;

    if (payment == null) {
      return _buildError('Tagihan tidak ditemukan.');
    }

    if (_error != null) {
      return _buildError(_error!);
    }

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(payment),
          const SizedBox(height: 24),
          _buildSummary(payment),
          const SizedBox(height: 24),
          _buildDetailRows(payment),
          if (payment.proofUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            _buildProofSection(payment.proofUrl!),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Payment payment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tagihan ${PaymentFormatter.period(payment.period)}',
                style: AppTextStyles.headlineLarge,
              ),
              if (payment.roomNumber != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Kamar ${payment.roomNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (widget.isAdmin && payment.userName != null) ...[
                const SizedBox(height: 4),
                Text(
                  payment.userName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        PaymentStatusBadge(status: payment.status),
      ],
    );
  }

  Widget _buildSummary(Payment payment) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Tagihan',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PaymentFormatter.rupiah(payment.amount),
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: PaymentItemsSection(payment: payment),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRows(Payment payment) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Jatuh Tempo',
            value: PaymentFormatter.date(payment.dueDate),
          ),
          const Divider(color: AppColors.divider, height: 1),
          _InfoRow(label: 'Status', value: PaymentFormatter.statusLabel(payment.status)),
          const Divider(color: AppColors.divider, height: 1),
          _InfoRow(
            label: 'Dibuat',
            value: PaymentFormatter.date(payment.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSection(String proofUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bukti Pembayaran',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              proofUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat detail tagihan',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
