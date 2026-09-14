import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_input_formatter.dart';
import '../../data/models/facility_model.dart';

class AdminFacilityForm extends StatefulWidget {
  final FacilityModel? initialFacility;

  final Future<void> Function({
    required String name,
    required double price,
    String? description,
    required bool isActive,
  })
  onSubmit;

  const AdminFacilityForm({
    super.key,
    this.initialFacility,
    required this.onSubmit,
  });

  @override
  State<AdminFacilityForm> createState() => _AdminFacilityFormState();
}

class _AdminFacilityFormState extends State<AdminFacilityForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;

  bool _isSubmitting = false;

  bool get _isEdit => widget.initialFacility != null;

  @override
  void initState() {
    super.initState();

    final facility = widget.initialFacility;

    if (facility != null) {
      _nameController.text = facility.name;
      _priceController.text = _formatPrice(facility.price);
      _descriptionController.text = facility.description ?? '';
      _isActive = facility.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

    return digits.isEmpty ? 0 : double.parse(digits);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        price: _parsePrice(_priceController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: _isActive,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Fasilitas berhasil diperbarui'
                : 'Fasilitas berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Gagal memperbarui fasilitas: $e'
                : 'Gagal menambahkan fasilitas: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nama Fasilitas',
              hintText: 'Contoh: Wi-Fi, AC, Kasur',
              prefixIcon: Icon(Icons.checklist_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama fasilitas wajib diisi';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [MoneyInputFormatter()],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Harga Fasilitas',
              hintText: 'Contoh: 50.000',
              prefixIcon: Icon(Icons.payments_outlined),
              prefixText: 'Rp ',
            ),
            validator: (value) {
              final price = _parsePrice(value ?? '');

              if (value == null || value.trim().isEmpty) {
                return 'Harga fasilitas wajib diisi';
              }

              if (price <= 0) {
                return 'Harga fasilitas harus lebih dari 0';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            textInputAction: TextInputAction.done,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (Opsional)',
              hintText: 'Contoh: Termasuk biaya listrik',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
              title: Text('Fasilitas Aktif', style: AppTextStyles.titleSmall),
              subtitle: Text(
                'Fasilitas nonaktif tidak muncul saat '
                'pemilihan fasilitas kamar.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isSubmitting
                    ? 'Menyimpan...'
                    : _isEdit
                    ? 'Simpan Perubahan'
                    : 'Simpan Fasilitas',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}