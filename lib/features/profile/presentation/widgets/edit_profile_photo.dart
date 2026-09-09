import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EditProfilePhoto extends StatelessWidget {
  final String name;
  final String? profilePhotoUrl;
  final VoidCallback? onEditPhoto;
  final bool isUploading;

  const EditProfilePhoto({
    super.key,
    required this.name,
    this.profilePhotoUrl,
    this.onEditPhoto,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    color: Color(0x1A000000),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                backgroundImage: hasPhoto
                    ? NetworkImage(profilePhotoUrl!)
                    : null,
                child: isUploading
                    ? const CircularProgressIndicator()
                    : hasPhoto
                    ? null
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  onTap: isUploading ? null : onEditPhoto,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 19,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Ubah foto profil', style: AppTextStyles.bodySmall),
      ],
    );
  }
}
