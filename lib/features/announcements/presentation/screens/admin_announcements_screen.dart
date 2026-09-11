import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/announcement_model.dart';
import '../../data/services/announcement_service.dart';
import '../widgets/announcement_card.dart';
import 'add_announcement_screen.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final AnnouncementService _announcementService = AnnouncementService();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final data = await _announcementService.getAnnouncements();

      if (!mounted) return;

      setState(() {
        _announcements = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat pengumuman';
      });
    }
  }

  Future<void> _deleteAnnouncement(AnnouncementModel announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: Text('Yakin ingin menghapus "${announcement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _announcementService.deleteAnnouncement(announcement.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil dihapus')),
      );

      await _loadAnnouncements();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pengumuman: $e')),
      );
    }
  }

  Future<void> _openAddAnnouncement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
    );

    if (!mounted) return;

    _loadAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pengumuman')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAnnouncement,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pengumuman'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_announcements.isEmpty) {
      return const Center(child: Text('Belum ada pengumuman'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: _announcements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final announcement = _announcements[index];

        return Stack(
          children: [
            AnnouncementCard(announcement: announcement),
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteAnnouncement(announcement);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}