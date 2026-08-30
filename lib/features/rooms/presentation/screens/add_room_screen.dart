import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/room_service.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _roomService = RoomService();
  final _picker = ImagePicker();

  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _facilitiesController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _status = 'Kosong';

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  bool _isLoading = false;

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _facilitiesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = pickedImage;
        _imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  Future<void> _saveRoom() async {
    if (_roomNumberController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _capacityController.text.trim().isEmpty ||
        _facilitiesController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua data wajib diisi')));
      return;
    }

    final price = double.tryParse(_priceController.text.trim());

    final capacity = int.tryParse(_capacityController.text.trim());

    if (price == null || capacity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga dan kapasitas harus berupa angka')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload foto akan kita sambungkan setelah RoomService
      // memiliki method uploadImage().
      String? imageUrl;

      await _roomService.createRoom(
        roomNumber: _roomNumberController.text.trim(),
        price: price,
        capacity: capacity,
        status: _status,
        facilities: _facilitiesController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamar berhasil ditambahkan')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan kamar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kamar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nomor Kamar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _roomNumberController,
              decoration: const InputDecoration(
                hintText: 'Contoh: 04',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Harga Kamar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 1500000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Kapasitas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 2',
                suffixText: ' orang',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Kosong', child: Text('Kosong')),
                DropdownMenuItem(value: 'Terisi', child: Text('Terisi')),
                DropdownMenuItem(value: 'Perbaikan', child: Text('Perbaikan')),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        _status = value;
                      });
                    },
            ),

            const SizedBox(height: 20),

            const Text(
              'Fasilitas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _facilitiesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Kasur, Lemari, Wifi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Deskripsi kamar...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Foto Kamar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (_imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRoom,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Kamar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
