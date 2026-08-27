import 'package:flutter/material.dart';

import '../../data/models/announcement_model.dart';
import '../../data/services/announcement_service.dart';
import '../widgets/announcement_card.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat pengumuman';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: _buildBody(),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        return AnnouncementCard(announcement: _announcements[index]);
      },
    );
  }
}
