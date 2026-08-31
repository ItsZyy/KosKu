import 'package:flutter/material.dart';

import '../../data/models/complaint_model.dart';
import '../../data/services/complaint_service.dart';
import '../widgets/complaint_summary.dart';
import '../widgets/complaint_filter.dart';
import '../widgets/complaint_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ComplaintService _complaintService = ComplaintService();

  List<ComplaintModel> _complaints = [];

  int _total = 0;
  int _menunggu = 0;
  int _diproses = 0;
  int _selesai = 0;

  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final complaints = await _complaintService.getComplaints();
      final stats = await _complaintService.getComplaintStats();

      if (!mounted) {
        return;
      }

      setState(() {
        _complaints = complaints;
        _total = stats['total'] ?? 0;
        _menunggu = stats['menunggu'] ?? 0;
        _diproses = stats['diproses'] ?? 0;
        _selesai = stats['selesai'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ComplaintModel> get _filteredComplaints {
    final query = _searchQuery.trim().toLowerCase();

    return _complaints.where((complaint) {
      final matchesFilter =
          _selectedFilter == 'Semua' || complaint.status == _selectedFilter;

      final matchesSearch =
          complaint.type.toLowerCase().contains(query) ||
          complaint.message.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Keluhan')),
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
      onRefresh: _loadComplaints,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Kelola laporan kerusakan dan masalah teknis dari penghuni.',
          ),
          const SizedBox(height: 16),

          ComplaintSummary(
            total: _total,
            menunggu: _menunggu,
            diproses: _diproses,
            selesai: _selesai,
          ),

          const SizedBox(height: 16),

          _buildSearch(),

          const SizedBox(height: 12),

          ComplaintFilter(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            total: _total,
            menunggu: _menunggu,
            diproses: _diproses,
            selesai: _selesai,
          ),

          const SizedBox(height: 16),

          ..._buildComplaintList(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari keluhan...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  List<Widget> _buildComplaintList() {
    final complaints = _filteredComplaints;

    if (complaints.isEmpty) {
      return [
        const SizedBox(height: 40),
        const Center(
          child: Column(
            children: [
              Icon(Icons.report_problem_outlined, size: 56),
              SizedBox(height: 12),
              Text(
                'Tidak ada laporan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ];
    }

    return complaints.map((complaint) {
      return ComplaintCard(
        complaint: complaint,
        onDetail: () {
          _showMessage('Detail laporan: ${complaint.type}');
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
            const Text(
              'Gagal memuat laporan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComplaints,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
