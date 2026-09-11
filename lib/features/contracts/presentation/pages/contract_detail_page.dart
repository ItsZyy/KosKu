import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../data/models/contract_model.dart';
import '../../data/services/contract_service.dart';
import '../widgets/contract_status_badge.dart';

class ContractDetailPage extends StatefulWidget {
  final ContractModel contract;

  const ContractDetailPage({super.key, required this.contract});

  @override
  State<ContractDetailPage> createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<ContractDetailPage> {
  final ContractService _contractService = ContractService();

  ContractModel? _contract;

  bool _isLoading = true;
  bool _isActing = false;

  ContractModel get _data => _contract ?? widget.contract;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await _contractService.getContractDetail(
        widget.contract.occupancyId,
      );

      if (!mounted) {
        return;
      }

      if (data == null) {
        setState(() {
          _isLoading = false;
        });

        _showMessage('Kontrak tidak ditemukan.');
        return;
      }

      setState(() {
        _contract = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage('Gagal memuat detail kontrak.');
    }
  }

  Future<void> _renewContract() async {
    await _confirmAndRun(
      confirmTitle: 'Perpanjang Kontrak',
      confirmMessage: 'Perpanjang kontrak ${_data.displayName} selama 6 bulan?',
      confirmLabel: 'Perpanjang',
      action: () => _contractService.renewContract(_data.occupancyId),
      successMessage: 'Kontrak berhasil diperpanjang 6 bulan.',
    );
  }

  Future<void> _completeContract() async {
    await _confirmAndRun(
      confirmTitle: 'Selesaikan Kontrak',
      confirmMessage:
          'Selesaikan kontrak ${_data.displayName}? Penghuni akan menjadi '
          'nonaktif dan keluar dari kamar.',
      confirmLabel: 'Selesaikan',
      action: () => _contractService.completeContract(_data.occupancyId),
      successMessage: 'Kontrak berhasil diselesaikan.',
    );
  }

  Future<void> _confirmAndRun({
    required String confirmTitle,
    required String confirmMessage,
    required String confirmLabel,
    required Future<bool> Function() action,
    required String successMessage,
  }) async {
    if (_isActing) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(confirmTitle),
          content: Text(confirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isActing = true;
    });

    try {
      final success = await action();

      if (!mounted) {
        return;
      }

      if (!success) {
        _showMessage('Aksi gagal. Silakan coba lagi.');
        return;
      }

      await _loadDetail();

      if (!mounted) {
        return;
      }

      _showMessage(successMessage);

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isActing = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Kontrak ${_data.displayName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetail,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildInformation(),
                  const SizedBox(height: 16),
                  _buildCharging(),
                  const SizedBox(height: 24),
                  _buildActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final resolvedPhotoUrl = ProfileService.resolveProfilePhotoUrl(
      _data.profilePhotoUrl,
    );

    final hasPhoto = resolvedPhotoUrl != null && resolvedPhotoUrl.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primarySoft,
              backgroundImage: hasPhoto ? NetworkImage(resolvedPhotoUrl) : null,
              child: hasPhoto
                  ? null
                  : const Icon(
                      Icons.person,
                      size: 28,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_data.displayName, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Kamar ${_data.roomNumber ?? '-'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ContractStatusBadge(status: _data.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInformation() {
    return _SectionCard(
      title: 'Informasi Kontrak',
      children: [
        _InfoRow(label: 'No. Telepon', value: _data.tenantPhone ?? '-'),
        _InfoRow(
          label: 'Periode Kontrak',
          value: _formatPeriod(_data.contractStart, _data.contractEnd),
        ),
        _InfoRow(label: 'Status', value: _data.isActive ? 'Aktif' : 'Selesai'),
        _InfoRow(label: 'Kamar', value: 'Kamar ${_data.roomNumber ?? '-'}'),
      ],
    );
  }

  Widget _buildCharging() {
    return _SectionCard(
      title: 'Biaya Sewa',
      children: [
        _InfoRow(
          label: 'Harga Sewa',
          value: _formatRupiah(_data.rentPrice),
          emphasize: true,
        ),
        _InfoRow(
          label: 'Jangka Pembayaran',
          value: _data.paymentIntervalMonths != null
              ? '${_data.paymentIntervalMonths} bulan'
              : '-',
        ),
        _InfoRow(
          label: 'Tanggal Pembayaran',
          value: _data.paymentDay != null ? 'Tanggal ${_data.paymentDay}' : '-',
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (_data.isInactive) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.archive_outlined, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kontrak ini sudah selesai. Tidak ada aksi yang tersedia.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isActing ? null : _renewContract,
            icon: _isActing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.update),
            label: const Text('Perpanjang 6 Bulan'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isActing ? null : _completeContract,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Selesaikan Kontrak'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ),
      ],
    );
  }

  String _formatPeriod(String? start, String? end) {
    String format(String? value) {
      if (value == null) {
        return '-';
      }

      final date = DateTime.tryParse(value);

      if (date == null) {
        return value;
      }

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    return '${format(start)} - ${format(end)}';
  }

  String _formatRupiah(double? amount) {
    if (amount == null) {
      return '-';
    }

    final text = amount.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return 'Rp ${buffer.toString()}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMedium.copyWith(
                color: emphasize ? AppColors.primary : AppColors.textPrimary,
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
