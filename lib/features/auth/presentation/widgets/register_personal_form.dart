import 'package:flutter/material.dart';

import 'custom_text_field.dart';
import 'primary_button.dart';

class RegisterPersonalForm extends StatefulWidget {
  final String name;
  final String phone;
  final String address;
  final String emergencyName;
  final String emergencyPhone;
  final String? emergencyRelation;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onEmergencyNameChanged;
  final ValueChanged<String> onEmergencyPhoneChanged;
  final ValueChanged<String?> onEmergencyRelationChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLoading;

  const RegisterPersonalForm({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.emergencyRelation,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onAddressChanged,
    required this.onEmergencyNameChanged,
    required this.onEmergencyPhoneChanged,
    required this.onEmergencyRelationChanged,
    required this.onNext,
    required this.onBack,
    this.isLoading = false,
  });

  @override
  State<RegisterPersonalForm> createState() => _RegisterPersonalFormState();
}

class _RegisterPersonalFormState extends State<RegisterPersonalForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;

  final List<String> _relations = [
    'Ayah',
    'Ibu',
    'Kakak',
    'Adik',
    'Paman',
    'Bibi',
    'Teman',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
    _emergencyNameController = TextEditingController(
      text: widget.emergencyName,
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.emergencyPhone,
    );

    _nameController.addListener(() {
      widget.onNameChanged(_nameController.text);
    });

    _phoneController.addListener(() {
      widget.onPhoneChanged(_phoneController.text);
    });

    _addressController.addListener(() {
      widget.onAddressChanged(_addressController.text);
    });

    _emergencyNameController.addListener(() {
      widget.onEmergencyNameChanged(_emergencyNameController.text);
    });

    _emergencyPhoneController.addListener(() {
      widget.onEmergencyPhoneChanged(_emergencyPhoneController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.emergencyRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih hubungan kontak darurat'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onNext();
  }

  String? _requiredValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }

    return null;
  }

  String? _phoneValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }

    if (value.trim().length < 10) {
      return '$field tidak valid';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline,
            controller: _nameController,
            validator: (value) => _requiredValidator(value, 'Nama lengkap'),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Nomor WhatsApp',
            hintText: 'Masukkan nomor WhatsApp',
            prefixIcon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) => _phoneValidator(value, 'Nomor WhatsApp'),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Alamat Asal',
            hintText: 'Masukkan alamat asal',
            prefixIcon: Icons.home_outlined,
            controller: _addressController,
            keyboardType: TextInputType.streetAddress,
            validator: (value) => _requiredValidator(value, 'Alamat'),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kontak Darurat',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nama Kontak Darurat',
            hintText: 'Masukkan nama kontak darurat',
            prefixIcon: Icons.contact_emergency_outlined,
            controller: _emergencyNameController,
            validator: (value) =>
                _requiredValidator(value, 'Nama kontak darurat'),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Nomor Kontak Darurat',
            hintText: 'Masukkan nomor kontak darurat',
            prefixIcon: Icons.phone_in_talk_outlined,
            controller: _emergencyPhoneController,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                _phoneValidator(value, 'Nomor kontak darurat'),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hubungan',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: widget.emergencyRelation,
            decoration: InputDecoration(
              hintText: 'Pilih hubungan',
              prefixIcon: const Icon(Icons.family_restroom_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            items: _relations
                .map(
                  (relation) => DropdownMenuItem<String>(
                    value: relation,
                    child: Text(relation),
                  ),
                )
                .toList(),
            onChanged: widget.isLoading
                ? null
                : widget.onEmergencyRelationChanged,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isLoading ? null : widget.onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Lanjut',
                  onPressed: _handleNext,
                  isLoading: widget.isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
