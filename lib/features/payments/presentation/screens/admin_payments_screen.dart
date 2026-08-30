import 'package:flutter/material.dart';

import '../../data/services/payment_service.dart';
import '../widgets/payment_card.dart';
import '../widgets/payment_summary.dart';
import '../widgets/payment_filter.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final PaymentService _paymentService = PaymentService();

  List<Map<String, dynamic>> _payments = [];

  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'Semua';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // LOAD DATA

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

  // FILTER + SEARCH

  List<Map<String, dynamic>> get _filteredPayments {
    final search = _searchController.text.trim().toLowerCase();

    return _payments.where((payment) {
      final status = payment['status']?.toString() ?? '';

      final profile = payment['profiles'] as Map<String, dynamic>?;

      final room = payment['rooms'] as Map<String, dynamic>?;

      final name = profile?['name']?.toString().toLowerCase() ?? '';

      final roomNumber = room?['room_number']?.toString().toLowerCase() ?? '';

      bool matchesFilter = true;

      if (_selectedFilter == 'Lunas') {
        matchesFilter = status == 'dikonfirmasi';
      } else if (_selectedFilter == 'Menunggu') {
        matchesFilter = status == 'menunggu';
      } else if (_selectedFilter == 'Belum Bayar') {
        matchesFilter = status == 'ditolak';
      }

      final matchesSearch =
          name.contains(search) || roomNumber.contains(search);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  // SUMMARY

  int get _totalBill {
    int total = 0;

    for (final payment in _payments) {
      total += (payment['amount'] as num?)?.toInt() ?? 0;
    }

    return total;
  }

  int get _paidBill {
    int total = 0;

    for (final payment in _payments) {
      if (payment['status'] == 'dikonfirmasi') {
        total += (payment['amount'] as num?)?.toInt() ?? 0;
      }
    }

    return total;
  }

  int get _unpaidBill {
    return _totalBill - _paidBill;
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

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SUMMARY
          PaymentSummary(
            totalBill: _totalBill,
            paidBill: _paidBill,
            unpaidBill: _unpaidBill,
          ),

          const SizedBox(height: 16),

          // FILTER + SEARCH
          PaymentFilter(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            searchController: _searchController,
            onSearchChanged: (_) {
              setState(() {});
            },
          ),

          const SizedBox(height: 16),

          // PAYMENT LIST
          ..._buildPaymentList(),
        ],
      ),
    );
  }

  // ERROR

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold),
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

  // PAYMENT LIST

  List<Widget> _buildPaymentList() {
    final payments = _filteredPayments;

    if (payments.isEmpty) {
      return [
        const SizedBox(height: 40),
        const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 56),
              SizedBox(height: 12),
              Text(
                'Tidak ada tagihan',
                style: TextStyle(fontWeight: FontWeight.bold),
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
          // Detail pembayaran dibuat berikutnya.
        },
      );
    }).toList();
  }
}
