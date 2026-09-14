import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/payment_status.dart';
import '../../data/services/payment_service.dart';
import '../widgets/payment_card.dart';
import 'admin_payment_detail_screen.dart';

class AdminRevenueReportScreen extends StatefulWidget {
  const AdminRevenueReportScreen({super.key});

  @override
  State<AdminRevenueReportScreen> createState() => _AdminRevenueReportScreenState();
}

class _AdminRevenueReportScreenState extends State<AdminRevenueReportScreen> {
  final PaymentService _paymentService = PaymentService();

  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _error;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

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
      final data = await _paymentService.getPayments();

      if (!mounted) return;

      setState(() {
        _payments = data;
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

  int _calcTotal(Map<String, dynamic> payment) {
    final items = payment['payment_items'];

    if (items is List && items.isNotEmpty) {
      int sum = 0;
      for (final item in items) {
        sum += (item['amount'] as num?)?.toInt() ?? 0;
      }
      return sum;
    }

    return (payment['amount'] as num?)?.toInt() ?? 0;
  }

  String _formatRupiah(int amount) {
    return formatRupiah(amount);
  }

  List<Map<String, dynamic>> get _filteredPayments {
    return _payments.where((payment) {
      // Gunakan tanggal konfirmasi sebagai acuan.
      // Jika belum dikonfirmasi, gunakan tanggal dibuat/transaksi agar tetap muncul di daftar.
      final confirmedAtStr = payment['confirmed_at']?.toString();
      final createdAtStr = payment['created_at']?.toString();
      
      final dateStr = (confirmedAtStr != null && confirmedAtStr.isNotEmpty) 
          ? confirmedAtStr 
          : createdAtStr;

      if (dateStr == null || dateStr.isEmpty) return false;

      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;

      return date.month == _selectedMonth && date.year == _selectedYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pendapatan'),
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

    final payments = _filteredPayments;
    
    int totalRevenue = 0;
    for (final payment in payments) {
      if (payment['status']?.toString() == PaymentStatus.confirmed.value) {
        totalRevenue += _calcTotal(payment);
      }
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMonthYearPicker(),
          const SizedBox(height: 24),
          _buildSummary(totalRevenue, payments.length),
          const SizedBox(height: 24),
          const Text(
            'Daftar Transaksi',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          ..._buildPaymentList(payments),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    final years = List.generate(10, (index) => DateTime.now().year - 5 + index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<int>(
            value: _selectedMonth,
            underline: const SizedBox(),
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(_months[index]),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMonth = value;
                });
              }
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: _selectedYear,
            underline: const SizedBox(),
            items: years.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedYear = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(int totalRevenue, int totalTransactions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Total Pendapatan',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.overlayWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(totalRevenue),
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalTransactions Transaksi',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentList(List<Map<String, dynamic>> payments) {
    if (payments.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'Tidak ada transaksi pada periode ini',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return payments.map((payment) {
      return PaymentCard(
        payment: payment,
        onTap: () {
          final paymentId = payment['id']?.toString();
          if (paymentId == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPaymentDetailScreen(
                paymentId: paymentId,
              ),
            ),
          );
        },
      );
    }).toList();
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
              'Gagal memuat laporan',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
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
