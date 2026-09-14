// Layar untuk membuat laporan/keluhan baru dari penghuni.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/complaint_service.dart';
import '../widgets/complaint_form_card.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi judul dan deskripsi laporan'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? photoUrl;

      if (_selectedImage != null) {
        photoUrl = await _complaintService.uploadImage(_selectedImage!);
      }

      await _complaintService.createComplaint(
        title: title,
        description: description,
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ComplaintFormCard(
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedImage: _selectedImage,
          onPickImage: _showImagePickerOptions,
          onSubmit: _submit,
          isSubmitting: _isSubmitting,
        ),
      ),
    );
  }
}