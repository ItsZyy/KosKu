import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/payment_status.dart';
import '../../data/services/payment_method_service.dart';
import '../../data/services/payment_service.dart';
import '../widgets/payment_header_card.dart';
import '../widgets/payment_history_card.dart';
import '../widgets/payment_method_card.dart';
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
  List<Map<String, dynamic>> _paymentInfo = [];
  List<Map<String, dynamic>> _paymentHistory = [];

  bool _isLoading = true;
  bool _showAllHistory = false;
  String _historyFilter = 'Semua';
  String? _error;

  @override
  void initState() {
    super.initState();
    _paymentService.subscribeToPayments(_onPaymentsChanged);
    _loadPayments();
  }

  @override
  void dispose() {
    _paymentService.unsubscribeFromPayments(_onPaymentsChanged);
    super.dispose();
  }

  void _onPaymentsChanged() {
    if (!mounted) return;
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

      final history = allHistory.where((p) {
        final proofUrl = p['proof_url']?.toString();
        final paymentMethod = p['payment_method']?.toString().toLowerCase();

        return (proofUrl != null && proofUrl.isNotEmpty) ||
            paymentMethod == 'cash';
      }).toList();

      final paymentInfo = await _paymentMethodService
          .getPaymentMethodsForUser();

      if (!mounted) return;

      setState(() {
        _payment = payment;
        _paymentHistory = history;
        _paymentInfo = paymentInfo;
        _isLoading = false;

        if (_paymentHistory.length <= 3) {
          _showAllHistory = false;
        }
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

    if (!mounted) return;

    await _loadPayments();
  }

  void _toggleHistory() {
    setState(() {
      _showAllHistory = !_showAllHistory;
    });
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_historyFilter == 'Semua') {
      return _paymentHistory;
    }

    return _paymentHistory.where((payment) {
      final rawStatus = payment['status']?.toString();

      final proofUrl = payment['proof_url']?.toString();

      final isCash =
          payment['payment_method']?.toString().toLowerCase() == 'cash';

      final dueDate = DateTime.tryParse(payment['due_date']?.toString() ?? '');

      final display = resolvePaymentDisplayStatus(
        status: rawStatus,
        hasProof: proofUrl != null && proofUrl.isNotEmpty,
        isCash: isCash,
        dueDate: dueDate,
      );

      return display.label == _historyFilter;
    }).toList();
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

    final displayedHistory = _showAllHistory
        ? _filteredHistory
        : _filteredHistory.take(3).toList();

    final hasMoreHistory = _filteredHistory.length > 3;

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pembayaran', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Bayar dan lihat riwayat tagihan Anda.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
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
            PaymentMethodCard(paymentInfo: _paymentInfo),
            const SizedBox(height: 24),
            _buildHistoryFilter(),
            const SizedBox(height: 12),
            PaymentHistoryCard(payments: displayedHistory),
            if (hasMoreHistory)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _toggleHistory,
                    icon: Icon(
                      _showAllHistory
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      _showAllHistory ? 'Sembunyikan' : 'Lihat Semua',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in paymentStatusFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: _historyFilter == filter,
                onSelected: (_) {
                  setState(() {
                    _historyFilter = filter;
                  });
                },
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: _historyFilter == filter
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                side: BorderSide(
                  color: _historyFilter == filter
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
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
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
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
