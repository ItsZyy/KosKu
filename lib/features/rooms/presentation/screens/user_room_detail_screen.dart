import 'package:flutter/material.dart';

import 'package:kosku/features/rooms/data/models/room_detail_model.dart';
import 'package:kosku/features/rooms/data/services/room_service.dart';

import '../widgets/room_detail_header.dart';
import '../widgets/room_image_carousel.dart';
import '../widgets/room_info_card.dart';
import '../widgets/room_facilities_detail_card.dart';
import '../widgets/room_user_management_card.dart';

class UserRoomDetailScreen extends StatefulWidget {
  final String roomId;

  const UserRoomDetailScreen({super.key, required this.roomId});

  @override
  State<UserRoomDetailScreen> createState() => _UserRoomDetailScreenState();
}

class _UserRoomDetailScreenState extends State<UserRoomDetailScreen> {
  final RoomService _roomService = RoomService();

  RoomDetailModel? _detail;

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadRoomDetail();
  }

  Future<void> _loadRoomDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _roomService.getRoomDetail(widget.roomId);

      if (!mounted) {
        return;
      }

      setState(() {
        _detail = result;
        _isLoading = false;

        if (result == null) {
          _errorMessage = 'Data kamar tidak ditemukan.';
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint('UserRoomDetailScreen error: $e');

      setState(() {
        _errorMessage = 'Gagal memuat detail kamar.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_detail == null) {
      return const Center(child: Text('Data kamar tidak tersedia.'));
    }

    return _buildContent(_detail!);
  }

  Widget _buildContent(RoomDetailModel detail) {
    final room = detail.room;

    return RefreshIndicator(
      onRefresh: _loadRoomDetail,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: RoomDetailHeader(
              onBack: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                RoomImageCarousel(
                  imageUrls: room.imagePaths
                      .map(RoomService.storagePathToPublicUrl)
                      .toList(),
                ),
                const SizedBox(height: 16),
                RoomInfoCard(room: room),
                const SizedBox(height: 16),
                RoomFacilitiesDetailCard(facilities: detail.facilities),
                const SizedBox(height: 16),
                RoomUserManagementCard(
                  users: detail.users,
                  capacity: room.capacity,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadRoomDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
