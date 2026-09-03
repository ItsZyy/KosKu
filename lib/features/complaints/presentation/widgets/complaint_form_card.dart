import 'dart:io';

import 'package:flutter/material.dart';

class ComplaintFormCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const ComplaintFormCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedImage,
    required this.onPickImage,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Buat Laporan atau Keluhan Baru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Sampaikan kendala Anda agar kami segera tindak lanjuti.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // JUDUL LAPORAN
            const Text(
              'Judul Laporan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Contoh: Lampu teras mati',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DESKRIPSI
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Jelaskan detail kerusakan atau kendala yang Anda alami...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.notes_outlined),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // UPLOAD FOTO
            const Text(
              'Unggah Foto',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: isSubmitting ? null : onPickImage,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 140),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan Foto (Opsional)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ketuk untuk memilih foto',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: isSubmitting ? null : onPickImage,
                  icon: const Icon(Icons.change_circle_outlined),
                  label: const Text('Ganti Foto'),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(isSubmitting ? 'Mengirim...' : 'Kirim Laporan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
