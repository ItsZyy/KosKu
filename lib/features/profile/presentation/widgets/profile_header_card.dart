import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String roleLabel;
  final String? roomNumber;
  final String? profilePhotoUrl;
  final bool isUploadingPhoto;
  final VoidCallback? onEdit;
  final VoidCallback? onEditPhoto;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    this.roleLabel = 'Pemilik Kos',
    this.roomNumber,
    this.profilePhotoUrl,
    this.isUploadingPhoto = false,
    this.onEdit,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: hasPhoto
                      ? NetworkImage(profilePhotoUrl!)
                      : null,
                  child: isUploadingPhoto
                      ? const CircularProgressIndicator()
                      : hasPhoto
                      ? null
                      : Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (onEditPhoto != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: Theme.of(context).colorScheme.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: isUploadingPhoto ? null : onEditPhoto,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(roleLabel, style: const TextStyle(color: Colors.grey)),
            if (roomNumber != null && roomNumber!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_outlined, size: 17),
                  const SizedBox(width: 4),
                  Text(
                    'Kamar $roomNumber',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (onEdit != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profil'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
