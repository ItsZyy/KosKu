import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';

class RoomImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoomImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 288,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<RoomImageCarousel> createState() => _RoomImageCarouselState();
}

class _RoomImageCarouselState extends State<RoomImageCarousel> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.imageUrls.isNotEmpty;
    final hasQuickActions = widget.onEdit != null || widget.onDelete != null;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: hasImages
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.imageUrls[index],
                        width: double.infinity,
                        height: widget.height,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImageError();
                        },
                      );
                    },
                  )
                : _buildPlaceholder(),
          ),
          if (hasImages)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (widget.imageUrls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (index) {
                  final isActive = index == _currentIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.surface
                          : AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          if (hasQuickActions)
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  if (widget.onEdit != null)
                    _buildQuickAction(
                      icon: Icons.edit_outlined,
                      iconColor: AppColors.textPrimary,
                      onTap: widget.onEdit,
                      tooltip: 'Edit kamar',
                    ),
                  if (widget.onEdit != null && widget.onDelete != null)
                    const SizedBox(height: 8),
                  if (widget.onDelete != null)
                    _buildQuickAction(
                      icon: Icons.delete_outline,
                      iconColor: AppColors.error,
                      onTap: widget.onDelete,
                      tooltip: 'Hapus kamar',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.9),
      elevation: 4,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: AppColors.textHint),
          SizedBox(height: 8),
          Text('Belum ada foto kamar', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.inputBackground,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
