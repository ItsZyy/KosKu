import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_model.dart';
import '../../data/services/payment_service.dart';
import '../../data/services/payment_method_service.dart';
import '../widgets/payment_header_card.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_history_card.dart';
import 'payment_detail_screen.dart';

class UserPaymentScreen extends StatefulWidget {
  const UserPaymentScreen({super.key});

  @override
  State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  final _paymentService = PaymentService();
  final _paymentMethodService = PaymentMethodService();

  Payment? _payment;

  // Banyak metode pembayaran
  List<Map<String, dynamic>> _paymentInfo = [];

  List<Map<String, dynamic>> _paymentHistory = [];

  bool _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payment = await _paymentService.getCurrentPayment();

      final allHistory = await _paymentService.getPaymentHistory();

      // Hanya tampilkan di riwayat pembayaran yang sudah pernah dikirim
      // (proof_url terisi). Tagihan yang belum dibayar tidak termasuk
      // riwayat karena sudah ditampilkan di bagian header.
      final history = allHistory.where((p) {
        final proofUrl = p['proof_url']?.toString();
        return proofUrl != null && proofUrl.isNotEmpty;
      }).toList();

      // Ambil metode pembayaran dari PaymentMethodService
      final paymentInfo = await _paymentMethodService
          .getPaymentMethodsForUser();

      if (!mounted) return;

      setState(() {
        _payment = payment;
        _paymentHistory = history;
        _paymentInfo = paymentInfo;
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

  Future<void> _openDetail(Payment payment) async {
    if (payment.id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentDetailScreen(paymentId: payment.id!, initial: payment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tagihan')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    final payment = _payment;

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // JUDUL
            // =========================
            Text('Detail Pembayaran', style: AppTextStyles.headlineLarge),

            const SizedBox(height: 8),

            Text(
              'Kelola tagihan dan riwayat transaksi Anda.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TAGIHAN
            // =========================
            if (payment == null)
              _buildEmptyState()
            else
              PaymentHeaderCard(
                payment: payment,
                onPay: () {
                  _openDetail(payment);
                },
              ),

            const SizedBox(height: 24),

            // =========================
            // METODE PEMBAYARAN
            // =========================
            _buildPaymentMethods(),

            const SizedBox(height: 24),

            // =========================
            // RIWAYAT PEMBAYARAN
            // =========================
            PaymentHistoryCard(
              payments: _paymentHistory,
              onViewAll: () {
                // Nanti diarahkan ke halaman
                // seluruh riwayat pembayaran.
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    // =========================
    // TIDAK ADA METODE
    // =========================
    if (_paymentInfo.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card),
                  SizedBox(width: 10),
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Metode pembayaran belum tersedia.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // =========================
    // DAFTAR METODE PEMBAYARAN
    // =========================
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metode Pembayaran', style: AppTextStyles.titleLarge),

        const SizedBox(height: 12),

        ..._paymentInfo.map((info) {
          final type = info['type']?.toString() ?? 'bank';

          final bankName = info['bank_name']?.toString();

          final accountNumber = info['account_number']?.toString();

          final accountName = info['account_name']?.toString();

          final qrisImageUrl = info['qris_image_url']?.toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PaymentMethodCard(
              type: type,
              bankName: bankName,
              accountNumber: accountNumber,
              accountName: accountName,
              qrisImageUrl: qrisImageUrl,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textHint,
          ),

          const SizedBox(height: 12),

          Text(
            'Belum ada tagihan',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Tagihan Anda akan muncul di sini.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),

            const SizedBox(height: 12),

            Text(
              'Gagal memuat pembayaran',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadPayments,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
