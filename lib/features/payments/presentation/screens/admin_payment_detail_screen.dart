import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_model.dart';
import '../../data/services/payment_service.dart';
import '../widgets/admin_payment_action_buttons.dart';
import '../widgets/admin_payment_header.dart';
import '../widgets/admin_payment_info_section.dart';
import '../widgets/admin_payment_proof_section.dart';
import '../widgets/admin_payment_tenant_card.dart';

class AdminPaymentDetailScreen extends StatefulWidget {
  final String paymentId;
  final Payment? initial;

  const AdminPaymentDetailScreen({
    super.key,
    required this.paymentId,
    this.initial,
  });

  @override
  State<AdminPaymentDetailScreen> createState() =>
      _AdminPaymentDetailScreenState();
}

class _AdminPaymentDetailScreenState extends State<AdminPaymentDetailScreen> {
  final PaymentService _paymentService = PaymentService();

  Payment? _payment;
  String? _proofSignedUrl;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payment = widget.initial;
    _paymentService.subscribeToPayments(_onPaymentsChanged);
    _loadDetail();
  }

  @override
  void dispose() {
    _paymentService.unsubscribeFromPayments(_onPaymentsChanged);
    super.dispose();
  }

  void _onPaymentsChanged() {
    if (!mounted) return;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final payment = await _paymentService.getPaymentDetail(widget.paymentId);

      String? signedUrl;

      if (payment?.hasSubmittedPayment == true) {
        signedUrl = await _paymentService.getProofSignedUrl(payment!.proofUrl);
      }

      if (!mounted) return;

      setState(() {
        _payment = payment;
        _proofSignedUrl = signedUrl;
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

  Future<Payment?> _refreshSilently() async {
    try {
      final payment = await _paymentService.getPaymentDetail(widget.paymentId);

      String? signedUrl;

      if (payment?.hasSubmittedPayment == true) {
        signedUrl = await _paymentService.getProofSignedUrl(payment!.proofUrl);
      }

      if (!mounted) return payment;

      setState(() {
        _payment = payment;
        _proofSignedUrl = signedUrl;
      });

      return payment;
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirm() async {
    if (_isBusy) return;

    final payment = _payment;

    if (payment == null || payment.id == null) {
      return;
    }

    final admin = Supabase.instance.client.auth.currentUser;

    if (admin == null) {
      _showSnack('Anda harus login sebagai admin terlebih dahulu.');
      return;
    }

    final confirmed = await _showConfirmDialog(payment);

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _paymentService.confirmPayment(
        paymentId: payment.id!,
        adminUserId: admin.id,
      );

      final refreshed = await _refreshSilently();

      if (!mounted) return;

      if (refreshed != null && !refreshed.isConfirmed) {
        throw Exception(
          'Status pembayaran tidak berubah menjadi '
          '"dikonfirmasi" di database.',
        );
      }

      setState(() {
        _isBusy = false;
      });

      _showSnack('Pembayaran berhasil dikonfirmasi.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBusy = false;
      });

      _showSnack('Gagal mengonfirmasi pembayaran: $e');
    }
  }

  Future<void> _reject() async {
    if (_isBusy) return;

    final payment = _payment;

    if (payment == null || payment.id == null) {
      return;
    }

    final admin = Supabase.instance.client.auth.currentUser;

    if (admin == null) {
      _showSnack('Anda harus login sebagai admin terlebih dahulu.');
      return;
    }

    final confirmed = await _showRejectDialog();

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _paymentService.rejectPayment(paymentId: payment.id!);

      final refreshed = await _refreshSilently();

      if (!mounted) return;

      if (refreshed != null && !refreshed.isRejected) {
        throw Exception(
          'Status pembayaran tidak berubah menjadi '
          '"ditolak" di database.',
        );
      }

      setState(() {
        _isBusy = false;
      });

      _showSnack('Pembayaran telah ditolak.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBusy = false;
      });

      _showSnack('Gagal menolak pembayaran: $e');
    }
  }

  Future<bool?> _showConfirmDialog(Payment payment) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogRow('Penghuni', payment.userName ?? '-'),
              _dialogRow('Kamar', payment.roomNumber ?? '-'),
              _dialogRow(
                'Periode',
                PaymentFormatter.periodRange(
                  payment.contractStart,
                  payment.contractEnd,
                  fallbackPeriod: payment.period,
                ),
              ),
              _dialogRow('Nominal', PaymentFormatter.rupiah(payment.totalAmount)),
              _dialogRow(
                'Metode',
                payment.isCash
                    ? 'Tunai'
                    : payment.paymentMethod == 'qris'
                    ? 'QRIS'
                    : 'Bank',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showRejectDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tolak Pembayaran?'),
          content: const Text('Pembayaran ini akan ditolak.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Pembayaran')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError(_error!);
    }

    final payment = _payment;

    if (payment == null) {
      return _buildError('Tagihan tidak ditemukan.');
    }

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          AdminPaymentHeader(payment: payment),
          const SizedBox(height: 20),
          AdminPaymentTenantCard(payment: payment),
          const SizedBox(height: 20),
          AdminPaymentInfoSection(payment: payment),
          const SizedBox(height: 20),
          if (!payment.isCash)
            AdminPaymentProofSection(
              payment: payment,
              proofSignedUrl: _proofSignedUrl,
            ),
          if (!payment.isCash) const SizedBox(height: 20),
          ..._buildActionArea(payment),
        ],
      ),
    );
  }

  List<Widget> _buildActionArea(Payment payment) {
    if (payment.isWaitingConfirmation) {
      return [
        AdminPaymentActionButtons(
          onReject: _reject,
          onConfirm: _confirm,
          isBusy: _isBusy,
        ),
      ];
    }

    if (payment.isConfirmed) {
      return [_buildConfirmedCard(payment)];
    }

    if (payment.isRejected) {
      return [_buildRejectedCard()];
    }

    return [_buildNoProofCard(payment)];
  }

  Widget _buildConfirmedCard(Payment payment) {
    return _buildStatusCard(
      icon: Icons.check_circle_outline,
      title: 'Pembayaran telah dikonfirmasi',
      backgroundColor: AppColors.successSoft,
      foregroundColor: AppColors.success,
      details: [
        if (payment.confirmedAt != null)
          'Tanggal konfirmasi: '
              '${PaymentFormatter.date(payment.confirmedAt)}',
      ],
    );
  }

  Widget _buildRejectedCard() {
    return _buildStatusCard(
      icon: Icons.cancel_outlined,
      title: 'Pembayaran ditolak',
      backgroundColor: AppColors.errorSoft,
      foregroundColor: AppColors.error,
    );
  }

  Widget _buildNoProofCard(Payment payment) {
    return _buildStatusCard(
      icon: Icons.info_outline,
      title: payment.isCash
          ? 'Pembayaran tunai belum dikirim'
          : 'Menunggu bukti pembayaran',
      backgroundColor: AppColors.warningSoft,
      foregroundColor: AppColors.warning,
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color foregroundColor,
    List<String> details = const [],
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foregroundColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                for (final detail in details) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
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
              'Gagal Memuat Detail Pembayaran',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
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
