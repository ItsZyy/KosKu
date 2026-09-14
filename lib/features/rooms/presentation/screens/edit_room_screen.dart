import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/facility_model.dart';
import '../../data/models/room_detail_model.dart';
import '../../data/models/room_model.dart';
import '../../data/services/room_service.dart';
import '../widgets/edit_room_photo_upload_card.dart';
import '../widgets/room_basic_info_card.dart';
import '../widgets/room_facilities_card.dart';
import '../widgets/room_form_actions.dart';

class EditRoomScreen extends StatefulWidget {
  final String roomId;

  const EditRoomScreen({super.key, required this.roomId});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _roomService = RoomService();
  final _formKey = GlobalKey<FormState>();

  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<String> _selectedFacilityIds = {};

  List<FacilityModel> _facilities = [];
  List<String> _existingPhotoPaths = [];
  List<XFile> _newPhotos = [];

  RoomModel? _room;
  List<RoomDetailUser> _users = [];

  int _capacity = 1;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _roomService.getRoomDetail(widget.roomId),
        _roomService.getFacilities(),
      ]);

      final detail = results[0] as RoomDetailModel;
      final facilities = results[1] as List<FacilityModel>;

      if (!mounted) return;

      setState(() {
        _room = detail.room;
        _users = detail.users;
        _facilities = facilities;

        _roomNumberController.text = detail.room.roomNumber;
        _priceController.text = _formatPrice(detail.room.price);
        _descriptionController.text = detail.room.description ?? '';

        _capacity = detail.room.capacity;

        _existingPhotoPaths = List<String>.from(detail.room.imagePaths);

        _selectedFacilityIds
          ..clear()
          ..addAll(detail.facilities.map((facility) => facility.id));

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError('Gagal mengambil data kamar: $e');
    }
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();

    return value.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  double? _parsePrice(String value) {
    final cleaned = value
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned);
  }

  Future<void> _pickImages(ImageSource source) async {
    if (_isSaving) return;

    final picker = ImagePicker();

    final image = await picker.pickImage(source: source, imageQuality: 85);

    if (!mounted || image == null) return;

    setState(() {
      _newPhotos = [..._newPhotos, image];
    });
  }

  void _removeExistingPhoto(int index) {
    if (_isSaving) return;

    if (index < 0 || index >= _existingPhotoPaths.length) {
      return;
    }

    setState(() {
      _existingPhotoPaths.removeAt(index);
    });
  }

  void _removeNewPhoto(int index) {
    if (_isSaving) return;

    if (index < 0 || index >= _newPhotos.length) {
      return;
    }

    setState(() {
      _newPhotos.removeAt(index);
    });
  }

  void _onCapacityChanged(int value) {
    if (_isSaving) return;

    if (value < _users.length) {
      _showError(
        'Kapasitas tidak boleh kurang dari jumlah penghuni aktif '
        '(${_users.length} orang).',
      );
      return;
    }

    setState(() {
      _capacity = value;
    });
  }

  void _onFacilitiesChanged(List<String> ids) {
    if (_isSaving) return;

    setState(() {
      _selectedFacilityIds
        ..clear()
        ..addAll(ids);
    });
  }

  Future<void> _save() async {
    if (_room == null || _isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final roomNumber = _roomNumberController.text.trim();
    final price = _parsePrice(_priceController.text);

    if (roomNumber.isEmpty) {
      _showError('Nomor kamar wajib diisi.');
      return;
    }

    if (price == null || price <= 0) {
      _showError('Harga kamar harus lebih dari 0.');
      return;
    }

    if (_capacity < _users.length) {
      _showError(
        'Kapasitas minimal ${_users.length} orang karena '
        'masih ada penghuni aktif.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _roomService.updateRoom(
        id: widget.roomId,
        roomNumber: roomNumber,
        price: price,
        capacity: _capacity,
        status: _room!.status,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        facilityIds: _selectedFacilityIds.toList(),
        retainedImagePaths: _existingPhotoPaths,
        images: _newPhotos.map((photo) => File(photo.path)).toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data kamar berhasil diperbarui.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError('Gagal memperbarui kamar: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onCancel() {
    if (_isSaving) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Kamar')),
        body: const Center(child: Text('Data kamar tidak ditemukan.')),
      );
    }

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Kamar')),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoomBasicInfoCard(
                  roomNumberController: _roomNumberController,
                  priceController: _priceController,
                  capacity: _capacity,
                  descriptionController: _descriptionController,
                  onCapacityChanged: _onCapacityChanged,
                ),

                const SizedBox(height: 16),

                RoomFacilitiesCard(
                  options: _facilities
                      .map(
                        (facility) => RoomFacilityOption.fromFacility(facility),
                      )
                      .toList(),
                  selectedIds: _selectedFacilityIds.toList(),
                  enabled: !_isSaving,
                  onChanged: _onFacilitiesChanged,
                ),

                const SizedBox(height: 16),

                EditRoomPhotoUploadCard(
                  existingPhotoPaths: _existingPhotoPaths,
                  newPhotos: _newPhotos,
                  enabled: !_isSaving,
                  onAddPhoto: _pickImages,
                  onRemoveExistingPhoto: _removeExistingPhoto,
                  onRemoveNewPhoto: _removeNewPhoto,
                ),

                const SizedBox(height: 24),

                RoomFormActions(
                  isLoading: _isSaving,
                  onCancel: _onCancel,
                  onSave: _save,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
