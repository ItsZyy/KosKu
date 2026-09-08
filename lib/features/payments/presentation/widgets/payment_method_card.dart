// Widget untuk UserPaymentScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class PaymentMethodCard extends StatefulWidget {
  final String type;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? qrisImageUrl;

  const PaymentMethodCard({
    super.key,
    required this.type,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.qrisImageUrl,
  });

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  bool _isDownloading = false;

  bool get _isBank => widget.type == 'bank';

  bool get _isQris => widget.type == 'qris';

  bool get _hasBankData {
    return widget.bankName != null &&
        widget.bankName!.isNotEmpty &&
        widget.accountNumber != null &&
        widget.accountNumber!.isNotEmpty &&
        widget.accountName != null &&
        widget.accountName!.isNotEmpty;
  }

  bool get _hasQrisData {
    return widget.qrisImageUrl != null && widget.qrisImageUrl!.isNotEmpty;
  }

  Future<void> _copyAccountNumber() async {
    if (widget.accountNumber == null || widget.accountNumber!.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: widget.accountNumber!));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor rekening berhasil disalin'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _downloadQris() async {
    if (!_hasQrisData) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.qrisImageUrl!));

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
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QRIS gagal diunduh'),
          duration: Duration(seconds: 2),
        ),
      );
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
    final showBank = _isBank && _hasBankData;
    final showQris = _isQris && _hasQrisData;

    // Jangan tampilkan card kalau datanya kosong.
    if (!showBank && !showQris) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER
            // =========================
            Row(
              children: [
                Icon(_isQris ? Icons.qr_code_2 : Icons.credit_card),
                const SizedBox(width: 10),
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =========================
            // BANK
            // =========================
            if (showBank) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance, size: 28),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bankName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.accountNumber!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              IconButton(
                                onPressed: _copyAccountNumber,
                                tooltip: 'Salin nomor rekening',
                                icon: const Icon(Icons.copy_outlined, size: 20),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'a.n. ${widget.accountName!}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // =========================
            // QRIS
            // =========================
            if (showQris) ...[
              if (showBank) const SizedBox(height: 16),

              const Text('QRIS', style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.qrisImageUrl!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }

                      return const SizedBox(
                        height: 240,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 240,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 40),
                              SizedBox(height: 8),
                              Text('QRIS tidak dapat ditampilkan'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // DOWNLOAD QRIS
              // =========================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDownloading ? null : _downloadQris,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  label: Text(
                    _isDownloading ? 'Menyimpan QRIS...' : 'Simpan QRIS',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Scan QRIS menggunakan aplikasi pembayaran Anda, '
                'atau simpan QRIS ke galeri.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // =========================
            // INFO
            // =========================
            Text(
              'Silakan lakukan pembayaran melalui metode di atas.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
