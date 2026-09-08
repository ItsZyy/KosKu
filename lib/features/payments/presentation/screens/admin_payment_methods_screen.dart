import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/services/payment_method_service.dart';
import '../widgets/admin_payment_method_card.dart';
import 'admin_add_payment_method_screen.dart';

class AdminPaymentMethodsScreen extends StatefulWidget {
  const AdminPaymentMethodsScreen({super.key});

  @override
  State<AdminPaymentMethodsScreen> createState() =>
      _AdminPaymentMethodsScreenState();
}

class _AdminPaymentMethodsScreenState extends State<AdminPaymentMethodsScreen> {
  final _paymentMethodService = PaymentMethodService();

  List<PaymentMethodModel> _paymentMethods = [];

  bool _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final methods = await _paymentMethodService.getPaymentMethods();

      if (!mounted) return;

      setState(() {
        _paymentMethods = methods;
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

  Future<void> _addPaymentMethod() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminAddPaymentMethodScreen()),
    );

    if (!mounted) return;

    _loadPaymentMethods();
  }

  Future<void> _deletePaymentMethod(PaymentMethodModel paymentMethod) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Metode Pembayaran?'),
          content: Text(
            paymentMethod.type == 'bank'
                ? 'Rekening ${paymentMethod.bankName ?? ''} '
                      'akan dihapus.'
                : 'Metode pembayaran QRIS akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _paymentMethodService.deletePaymentMethod(paymentMethod.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metode pembayaran berhasil dihapus')),
      );

      _loadPaymentMethods();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus metode pembayaran: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPaymentMethod,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
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

    if (_paymentMethods.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentMethods,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Text('Metode Pembayaran', style: AppTextStyles.headlineLarge),

          const SizedBox(height: 8),

          Text(
            'Kelola rekening bank dan QRIS yang '
            'digunakan penghuni untuk melakukan pembayaran.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          ..._paymentMethods.map((paymentMethod) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AdminPaymentMethodCard(
                paymentMethod: paymentMethod,
                onDelete: () {
                  _deletePaymentMethod(paymentMethod);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Belum Ada Metode Pembayaran',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Tambahkan rekening bank atau QRIS '
              'agar penghuni dapat melakukan pembayaran.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Metode'),
            ),
          ],
        ),
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
              'Gagal Memuat Metode Pembayaran',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              _error!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadPaymentMethods,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
