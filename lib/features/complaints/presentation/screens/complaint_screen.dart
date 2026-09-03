import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/complaint_service.dart';
import '../widgets/complaint_form_card.dart';
import '../widgets/complaint_history_card.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final ComplaintService _complaintService = ComplaintService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _complaints = [];

  File? _selectedImage;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // LOAD RIWAYAT KELUHAN
  Future<void> _loadComplaints() async {
    try {
      final data = await _complaintService.getMyComplaints();

      if (!mounted) return;

      setState(() {
        _complaints = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil riwayat keluhan: $e')),
      );
    }
  }

  // PILIH FOTO
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  // KIRIM KELUHAN
  Future<void> _submitComplaint() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul laporan wajib diisi')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deskripsi wajib diisi')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageUrl;

      // Upload foto jika user memilih foto
      if (_selectedImage != null) {
        imageUrl = await _complaintService.uploadImage(_selectedImage!);
      }

      // Simpan laporan ke database
      await _complaintService.createComplaint(
        title: title,
        description: description,
        photoUrl: imageUrl,
      );

      _titleController.clear();
      _descriptionController.clear();

      if (!mounted) return;

      setState(() {
        _selectedImage = null;
      });

      await _loadComplaints();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FORM LAPORAN
              ComplaintFormCard(
                titleController: _titleController,
                descriptionController: _descriptionController,
                selectedImage: _selectedImage,
                onPickImage: _pickImage,
                onSubmit: _submitComplaint,
                isSubmitting: _isSubmitting,
              ),

              const SizedBox(height: 24),

              // RIWAYAT KELUHAN
              ComplaintHistoryCard(
                complaints: _complaints,
                onViewAll: () {
                  // Nanti diarahkan ke halaman
                  // seluruh riwayat keluhan.
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
