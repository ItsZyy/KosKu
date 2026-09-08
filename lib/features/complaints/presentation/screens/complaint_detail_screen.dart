import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/complaint_model.dart';
import '../../data/services/complaint_service.dart';
import '../widgets/complaint_detail_header_card.dart';
import '../widgets/complaint_detail_content_card.dart';
import '../widgets/complaint_status_action_card.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final ComplaintModel complaint;
  final String? userName;
  final String? roomNumber;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
    this.userName,
    this.roomNumber,
  });

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final ComplaintService _complaintService = ComplaintService();

  late String _currentStatus;
  late String _selectedStatus;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _currentStatus = widget.complaint.status;
    _selectedStatus = widget.complaint.status;
  }

  void _selectStatus(String status) {
    if (_isUpdating) return;

    setState(() {
      _selectedStatus = status;
    });
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == _currentStatus || _isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _complaintService.updateComplaintStatus(
        id: widget.complaint.id,
        status: _selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        _currentStatus = _selectedStatus;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status keluhan berhasil diubah menjadi '
            '${_statusLabel(_currentStatus)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengubah status keluhan',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'process':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    ComplaintDetailHeaderCard(
                      complaint: widget.complaint,
                      currentStatus: _currentStatus,
                    ),
                    const SizedBox(height: 16),
                    ComplaintDetailContentCard(
                      complaint: widget.complaint,
                      userName: widget.userName,
                      roomNumber: widget.roomNumber,
                    ),
                    const SizedBox(height: 16),
                    ComplaintStatusActionCard(
                      currentStatus: _selectedStatus,
                      isUpdating: _isUpdating,
                      onStatusChanged: _selectStatus,
                      onUpdate: _updateStatus,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primary,
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 4),
          Text(
            'Detail Keluhan',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
