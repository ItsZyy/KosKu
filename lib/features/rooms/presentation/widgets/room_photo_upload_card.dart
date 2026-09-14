// Widget untuk AddRoomScreen & EditRoomScreen
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/services/room_service.dart';
import 'section_card.dart';

class RoomPhotoUploadCard extends StatelessWidget {
  final List<XFile> photos;
  final List<String> existingPhotoPaths;
  final bool enabled;

  final Future<void> Function(ImageSource source) onAddPhoto;
  final ValueChanged<int> onRemovePhoto;
  final ValueChanged<int> onRemoveExistingPhoto;

  const RoomPhotoUploadCard({
    super.key,
    required this.photos,
    this.existingPhotoPaths = const [],
    required this.onAddPhoto,
    required this.onRemovePhoto,
    this.onRemoveExistingPhoto = _defaultRemoveExistingPhoto,
    this.enabled = true,
  });

  static void _defaultRemoveExistingPhoto(int index) {}

  Future<void> _showSourceSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.textPrimary,
                ),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_outlined,
                  color: AppColors.textPrimary,
                ),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await onAddPhoto(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPhotos = existingPhotoPaths.length + photos.length;

    return SectionCard(
      title: 'Foto Kamar',
      subtitle: 'Opsional. Tambahkan beberapa foto untuk memperlihatkan kamar.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: totalPhotos + 1,
            itemBuilder: (context, index) {
              if (index == totalPhotos) {
                return _AddPhotoTile(
                  enabled: enabled,
                  onTap: () => _showSourceSheet(context),
                );
              }

              if (index < existingPhotoPaths.length) {
                final path = existingPhotoPaths[index];

                return _ExistingPhotoTile(
                  path: path,
                  enabled: enabled,
                  onRemove: () {
                    onRemoveExistingPhoto(index);
                  },
                );
              }

              final newPhotoIndex = index - existingPhotoPaths.length;

              return _PhotoTile(
                file: File(photos[newPhotoIndex].path),
                enabled: enabled,
                onRemove: () {
                  onRemovePhoto(newPhotoIndex);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ExistingPhotoTile extends StatelessWidget {
  final String path;
  final bool enabled;
  final VoidCallback onRemove;

  const _ExistingPhotoTile({
    required this.path,
    required this.enabled,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = RoomService.storagePathToPublicUrl(path);

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: AppColors.inputBackground,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.inputBackground,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Lama',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: AppColors.error.withValues(alpha: 0.9),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onRemove : null,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, color: AppColors.onError, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddPhotoTile({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: DottedBorderBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: enabled ? AppColors.primary : AppColors.textDisabled,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                'Tambah Foto',
                style: AppTextStyles.labelMedium.copyWith(
                  color: enabled ? AppColors.primary : AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final File file;
  final bool enabled;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.file,
    required this.enabled,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.inputBackground,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Baru',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: AppColors.error.withValues(alpha: 0.9),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onRemove : null,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, color: AppColors.onError, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primarySoft.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const radius = 12.0;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;

      while (distance < metric.length) {
        final next = distance + 6;

        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );

        distance = next + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
