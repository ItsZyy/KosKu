import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminPaymentMethodForm extends StatefulWidget {
  final Future<void> Function({
    required String type,
    String? bankName,
    String? accountNumber,
    String? accountName,
    File? qrisImage,
  })
  onSubmit;

  const AdminPaymentMethodForm({super.key, required this.onSubmit});

  @override
  State<AdminPaymentMethodForm> createState() => _AdminPaymentMethodFormState();
}

class _AdminPaymentMethodFormState extends State<AdminPaymentMethodForm> {
  final _formKey = GlobalKey<FormState>();

  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  final _imagePicker = ImagePicker();

  String _selectedType = 'bank';

  File? _qrisImage;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickQrisImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      _qrisImage = File(image.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == 'qris' && _qrisImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih gambar QRIS terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        type: _selectedType,
        bankName: _selectedType == 'bank'
            ? _bankNameController.text.trim()
            : null,
        accountNumber: _selectedType == 'bank'
            ? _accountNumberController.text.trim()
            : null,
        accountName: _selectedType == 'bank'
            ? _accountNameController.text.trim()
            : null,
        qrisImage: _selectedType == 'qris' ? _qrisImage : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metode pembayaran berhasil ditambahkan')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan metode pembayaran: $e')),
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
    final isBank = _selectedType == 'bank';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jenis Metode Pembayaran', style: AppTextStyles.titleMedium),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  value: 'bank',
                  title: 'Bank',
                  icon: Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  value: 'qris',
                  title: 'QRIS',
                  icon: Icons.qr_code_2_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (isBank) ...[
            Text('Informasi Rekening', style: AppTextStyles.titleMedium),

            const SizedBox(height: 12),

            TextFormField(
              controller: _bankNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Bank',
                hintText: 'Contoh: BCA',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama bank wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening',
                hintText: 'Masukkan nomor rekening',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor rekening wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _accountNameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Nama Pemilik Rekening',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama pemilik rekening wajib diisi';
                }

                return null;
              },
            ),
          ],

          if (!isBank) ...[
            Text('QRIS', style: AppTextStyles.titleMedium),

            const SizedBox(height: 12),

            Text(
              'Pilih gambar QRIS yang akan digunakan penghuni '
              'untuk melakukan pembayaran.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            _buildQrisPicker(),
          ],

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
                _isSubmitting ? 'Menyimpan...' : 'Simpan Metode Pembayaran',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedType == value;

    return InkWell(
      onTap: _isSubmitting
          ? null
          : () {
              setState(() {
                _selectedType = value;

                if (value == 'bank') {
                  _qrisImage = null;
                }
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisPicker() {
    if (_qrisImage == null) {
      return InkWell(
        onTap: _isSubmitting ? null : _pickQrisImage,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.textHint,
              ),

              const SizedBox(height: 12),

              Text('Pilih gambar QRIS', style: AppTextStyles.titleSmall),

              const SizedBox(height: 4),

              Text(
                'Tap untuk memilih dari galeri',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_qrisImage!, height: 280, fit: BoxFit.contain),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _pickQrisImage,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Ganti Gambar QRIS'),
          ),
        ),
      ],
    );
  }
}
