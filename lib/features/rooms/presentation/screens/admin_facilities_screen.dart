import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_input_formatter.dart';
import '../../data/models/facility_model.dart';
import '../../data/services/facility_service.dart';
import '../widgets/admin_facility_card.dart';

class AdminFacilitiesScreen extends StatefulWidget {
  const AdminFacilitiesScreen({super.key});

  @override
  State<AdminFacilitiesScreen> createState() => _AdminFacilitiesScreenState();
}

class _AdminFacilitiesScreenState extends State<AdminFacilitiesScreen> {
  final _facilityService = FacilityService();

  List<FacilityModel> _facilities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final facilities = await _facilityService.getFacilities();

      if (!mounted) return;

      setState(() {
        _facilities = facilities;
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

  Future<void> _editPrice(FacilityModel facility) async {
    final controller = TextEditingController(
      text: facility.price > 0 ? _formatPrice(facility.price) : '',
    );

    final formKey = GlobalKey<FormState>();

    final price = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Harga'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(facility.name, style: AppTextStyles.titleMedium),
                if (facility.description != null &&
                    facility.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    facility.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MoneyInputFormatter()],
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Harga Fasilitas',
                    hintText: 'Contoh: 50.000',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final parsed = _parsePrice(value ?? '');

                    if (value == null || value.trim().isEmpty) {
                      return 'Harga wajib diisi';
                    }

                    if (parsed < 0) {
                      return 'Harga tidak valid';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                Navigator.pop(context, _parsePrice(controller.text));
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (price == null) return;

    try {
      await _facilityService.updateFacilityPrice(id: facility.id, price: price);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harga ${facility.name} berhasil diperbarui')),
      );

      await _loadFacilities();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui harga: $e')));
    }
  }

  String _formatPrice(double price) {
    if (price <= 0) {
      return '';
    }

    final digits = price.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  double _parsePrice(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return 0;
    }

    return double.parse(digits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Fasilitas')),
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

    if (_facilities.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFacilities,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text('Kelola Fasilitas', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Atur harga fasilitas yang dikenakan kepada penghuni.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ..._facilities.map((facility) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AdminFacilityCard(
                facility: facility,
                onEdit: () => _editPrice(facility),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.checklist_outlined, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Fasilitas',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada fasilitas yang tersedia.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal Memuat Fasilitas',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFacilities,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
