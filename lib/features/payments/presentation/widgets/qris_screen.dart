import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class QrisScreen {
  static Future<void> show(BuildContext context, {required String imageUrl}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _QrisBottomSheet(imageUrl: imageUrl),
    );
  }
}

class _QrisBottomSheet extends StatefulWidget {
  final String imageUrl;

  const _QrisBottomSheet({required this.imageUrl});

  @override
  State<_QrisBottomSheet> createState() => _QrisBottomSheetState();
}

class _QrisBottomSheetState extends State<_QrisBottomSheet> {
  bool _isDownloading = false;

  Future<void> _downloadQris() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Gagal mengunduh QRIS');
      }

      final Uint8List imageBytes = response.bodyBytes;

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: 'KosKu_QRIS_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      final success = result['isSuccess'] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'QRIS berhasil disimpan ke galeri'
                : 'QRIS gagal disimpan',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QRIS gagal diunduh')));
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.qr_code_2, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'QRIS Pembayaran',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Scan QRIS menggunakan aplikasi pembayaran Anda.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 280,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 48),
                          SizedBox(height: 12),
                          Text('QRIS tidak dapat ditampilkan'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadQris,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(
                _isDownloading ? 'Menyimpan QRIS...' : 'Unduh QRIS',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simpan QRIS ke galeri jika ingin digunakan nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
