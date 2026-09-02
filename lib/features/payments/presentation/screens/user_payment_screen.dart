import 'package:flutter/material.dart';

import '../../data/services/payment_service.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_history_card.dart';

class UserPaymentScreen extends StatefulWidget {
  const UserPaymentScreen({super.key});

  @override
  State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  final _paymentService = PaymentService();

  Map<String, dynamic>? _payment;
  Map<String, dynamic>? _paymentInfo;
  List<Map<String, dynamic>> _paymentHistory = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final payment = await _paymentService.getPayment();
      final history = await _paymentService.getPaymentHistory();
      final paymentInfo = await _paymentService.getPaymentInfo();

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
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pembayaran: $e')),
      );
    }
  }

  String _formatRupiah(dynamic amount) {
    if (amount == null) {
      return '-';
    }

    final value = int.tryParse(amount.toString());

    if (value == null) {
      return amount.toString();
    }

    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String _formatPeriod(dynamic period) {
    if (period == null) {
      return '-';
    }

    final date = DateTime.tryParse(period.toString());

    if (date == null) {
      return period.toString();
    }

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final payment = _payment;

    return Scaffold(
      appBar: AppBar(title: const Text('Tagihan')),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Pembayaran',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Kelola tagihan dan riwayat transaksi Anda.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // DETAIL PEMBAYARAN
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: payment == null
                      ? const Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada tagihan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatPeriod(payment['period']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                _StatusBadge(
                                  status: payment['status']?.toString() ?? '-',
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                const Icon(Icons.payments_outlined, size: 28),
                                const SizedBox(width: 10),
                                Text(
                                  _formatRupiah(payment['amount']),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Column(
                                children: [
                                  _PaymentRow(
                                    title: 'Total Pembayaran',
                                    value: _formatRupiah(payment['amount']),
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (payment['status']?.toString().toLowerCase() ==
                                'pending')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Nanti diarahkan ke halaman
                                    // upload bukti pembayaran.
                                  },
                                  child: const Text('Bayar Sekarang'),
                                ),
                              ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // METODE PEMBAYARAN
              // =========================
              if (_paymentInfo != null)
                PaymentMethodCard(
                  bankName: _paymentInfo!['bank_name']?.toString() ?? '-',
                  accountNumber:
                      _paymentInfo!['account_number']?.toString() ?? '-',
                  accountName: _paymentInfo!['account_name']?.toString() ?? '-',
                  qrisImageUrl: _paymentInfo!['qris_image_url']?.toString(),
                )
              else
                const Card(
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                ),

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
      ),
    );
  }
}

// =========================
// PAYMENT ROW
// =========================

class _PaymentRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _PaymentRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// =========================
// STATUS BADGE
// =========================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'dikonfirmasi':
        label = 'Lunas';
        break;

      case 'rejected':
      case 'ditolak':
        label = 'Ditolak';
        break;

      case 'pending':
      case 'menunggu':
        label = 'Menunggu Pembayaran';
        break;

      default:
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.orange.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
