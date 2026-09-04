import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/services/room_service.dart';
import '../widgets/room_basic_info_card.dart';
import '../widgets/room_facilities_card.dart';
import '../widgets/room_facility_catalog.dart';
import '../widgets/room_form_actions.dart';
import '../widgets/room_photo_upload_card.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _roomService = RoomService();
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _capacity = 1;

  final Set<String> _selectedFacilities = <String>{};

  // TODO: DB currently supports only rooms.image_url (single text).
  // Future implementation should use a dedicated room_images table
  // for multiple room photos. UI uses List<XFile> agar migrasi tinggal
  // dilakukan di layer service/repository.
  final List<XFile> _photos = <XFile>[];

  bool _isLoading = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _roomNumberController.addListener(_markDirty);
    _priceController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateRoomNumber(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nomor kamar wajib diisi';
    return null;
  }

  String? _validatePrice(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Harga sewa wajib diisi';
    final n = num.tryParse(v);
    if (n == null || n <= 0) return 'Harga harus berupa angka lebih dari 0';
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isLoading) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() {
        _photos.add(picked);
        _isDirty = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e')),
      );
    }
  }

  void _removePhoto(int index) {
    if (_isLoading) return;
    setState(() {
      _photos.removeAt(index);
      _isDirty = true;
    });
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final priceStr = _priceController.text.trim();
    final price = double.parse(priceStr);

    setState(() => _isLoading = true);
    try {
      final imageFiles = _photos.map((x) => File(x.path)).toList();

      // TODO: saat DB mendukung multi-image, ganti dengan upload semua
      // foto dan simpan ke tabel room_images.
      final imageUrl = await _roomService.uploadFirstImageOrNull(imageFiles);

      await _roomService.createRoom(
        roomNumber: _roomNumberController.text.trim(),
        price: price,
        capacity: _capacity,
        status: 'kosong',
        facilities: encodeFacilities(_selectedFacilities.toList()),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      _isDirty = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamar berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan kamar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan perubahan?'),
          content: const Text(
            'Perubahan yang belum disimpan akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, keluar'),
            ),
          ],
        );
      },
    );
    return res ?? false;
  }

  Future<void> _handleCancel() async {
    if (_isLoading) return;
    if (_isDirty) {
      final ok = await _confirmDiscardChanges();
      if (!ok || !mounted) return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (_isDirty && !_isLoading) {
          final ok = await _confirmDiscardChanges();
          if (ok && mounted) navigator.pop();
        } else {
          if (mounted) navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _handleCancel,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Kembali',
          ),
          title: const Text('Tambah Kamar'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Tambahkan kamar baru ke kos Anda. Lengkapi informasi dasar, fasilitas, dan foto untuk membantu calon penghuni.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                RoomBasicInfoCard(
                  roomNumberController: _roomNumberController,
                  priceController: _priceController,
                  descriptionController: _descriptionController,
                  capacity: _capacity,
                  onCapacityChanged: (v) {
                    if (_isLoading) return;
                    setState(() {
                      _capacity = v < 1 ? 1 : v;
                      _isDirty = true;
                    });
                  },
                  roomNumberValidator: _validateRoomNumber,
                  priceValidator: _validatePrice,
                ),
                const SizedBox(height: 16),
                RoomFacilitiesCard(
                  options: kRoomFacilityOptions,
                  selected: _selectedFacilities.toList(),
                  enabled: !_isLoading,
                  onChanged: (next) {
                    if (_isLoading) return;
                    setState(() {
                      _selectedFacilities
                        ..clear()
                        ..addAll(next);
                      _isDirty = true;
                    });
                  },
                ),
                const SizedBox(height: 16),
                RoomPhotoUploadCard(
                  photos: _photos,
                  enabled: !_isLoading,
                  onAddPhoto: _pickImage,
                  onRemovePhoto: _removePhoto,
                ),
                const SizedBox(height: 24),
                RoomFormActions(
                  isLoading: _isLoading,
                  onCancel: _handleCancel,
                  onSave: _saveRoom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}