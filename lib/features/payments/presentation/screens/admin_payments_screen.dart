import 'package:flutter/material.dart';

import '../../data/services/payment_service.dart';
import '../widgets/payment_card.dart';

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

  List<Map<String, dynamic>> get _filteredPayments {
    if (_selectedFilter == 'Semua') {
      return _payments;
    }

    return _payments.where((payment) {
      return payment['status'] == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tagihan')),
      body: Column(
        children: [
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('menunggu'),
                _buildFilterChip('dikonfirmasi'),
                _buildFilterChip('ditolak'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          filter == 'Semua'
              ? 'Semua'
              : filter[0].toUpperCase() + filter.substring(1),
        ),
        selected: _selectedFilter == filter,
        onSelected: (_) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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

    final payments = _filteredPayments;

    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56),
            SizedBox(height: 12),
            Text(
              'Belum ada pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];

          return PaymentCard(
            payment: payment,
            onTap: () {
              // Detail pembayaran akan kita buat berikutnya.
            },
          );
        },
      ),
    );
  }
}
