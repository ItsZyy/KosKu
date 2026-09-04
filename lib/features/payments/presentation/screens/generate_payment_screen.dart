import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tenants/data/models/tenant_model.dart';
import '../../../tenants/data/services/tenant_service.dart';
import '../../data/services/payment_service.dart';

/// Admin -> pilih penghuni -> periode -> jatuh tempo -> generate_payment().
class GeneratePaymentScreen extends StatefulWidget {
  const GeneratePaymentScreen({super.key});

  @override
  State<GeneratePaymentScreen> createState() => _GeneratePaymentScreenState();
}

class _GeneratePaymentScreenState extends State<GeneratePaymentScreen> {
  final _paymentService = PaymentService();
  final _tenantService = TenantService();

  List<TenantModel> _tenants = [];
  TenantModel? _selectedTenant;

  DateTime _period = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _dueDate = DateTime(DateTime.now().year, DateTime.now().month, 10);

  bool _isLoadingTenants = true;
  String? _tenantsError;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoadingTenants = true;
      _tenantsError = null;
    });

    try {
      final tenants = await _tenantService.getTenants();
      if (!mounted) return;
      setState(() {
        _tenants = tenants;
        _isLoadingTenants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tenantsError = e.toString();
        _isLoadingTenants = false;
      });
    }
  }

  String _formatPeriod(DateTime date) {
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

  Future<void> _pickPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _period,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih Periode Tagihan',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _period = DateTime(picked.year, picked.month, 1);
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih Jatuh Tempo',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dueDate = picked;
    });
  }

  Future<void> _generate() async {
    if (_selectedTenant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih penghuni terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final paymentId = await _paymentService.generatePayment(
        userId: _selectedTenant!.userId,
        roomId: _selectedTenant!.roomId,
        period: _period.toIso8601String(),
        dueDate: _dueDate.toIso8601String(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan berhasil dibuat'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, {'payment_id': paymentId});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat tagihan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buat Tagihan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Buat tagihan untuk penghuni. Total dihitung otomatis di database.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildTenantSelector(),
            const SizedBox(height: 20),
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            _buildDueDateSelector(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantSelector() {
    if (_isLoadingTenants) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tenantsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gagal memuat daftar penghuni.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadTenants,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      );
    }

    return _SectionCard(
      title: 'Penghuni',
      child: _tenants.isEmpty
          ? Text(
              'Belum ada penghuni aktif.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : DropdownButtonFormField<TenantModel>(
              isExpanded: true,
              initialValue: _selectedTenant,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pilih penghuni',
              ),
              items: _tenants
                  .map(
                    (tenant) => DropdownMenuItem(
                      value: tenant,
                      child: Text(
                        '${tenant.name} — Kamar ${tenant.roomNumber}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (tenant) {
                      setState(() {
                        _selectedTenant = tenant;
                      });
                    },
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return _SectionCard(
      title: 'Periode Tagihan',
      child: _buildPickerRow(
        label: _formatPeriod(_period),
        onTap: _isSaving ? null : _pickPeriod,
      ),
    );
  }

  Widget _buildDueDateSelector() {
    return _SectionCard(
      title: 'Jatuh Tempo',
      child: _buildPickerRow(
        label: '${_dueDate.day} ${_formatPeriod(_dueDate)}',
        onTap: _isSaving ? null : _pickDueDate,
      ),
    );
  }

  Widget _buildPickerRow({required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _generate,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.receipt_long),
        label: Text(_isSaving ? 'Membuat...' : 'Buat Tagihan'),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
