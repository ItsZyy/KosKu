import 'package:flutter/material.dart';

import 'package:kosku/features/rooms/data/models/room_detail_model.dart';
import 'package:kosku/features/rooms/data/services/room_service.dart';

import '../widgets/room_detail_header.dart';
import '../widgets/room_image_carousel.dart';
import '../widgets/room_info_card.dart';
import '../widgets/room_facilities_detail_card.dart';
import '../widgets/room_payment_summary_card.dart';
import '../widgets/room_complaint_summary_card.dart';
import '../widgets/room_user_management_card.dart';
import '../widgets/room_detail_bottom_action.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _roomService.getRoomDetail(widget.roomId);

      if (!mounted) {
        return;
      }

      if (result == null) {
        setState(() {
          _detail = null;
          _errorMessage = 'Data kamar tidak ditemukan.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _detail = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Gagal memuat detail kamar.';
        _isLoading = false;
      });

      debugPrint('RoomDetailScreen error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildBody(),
      bottomNavigationBar: _detail == null
          ? null
          : RoomDetailBottomAction(
              label: 'Edit Kamar',
              icon: Icons.edit_outlined,
              onPressed: _onEditRoom,
            ),
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
                  onEdit: _onEditRoom,
                  onDelete: _onDeleteRoom,
                ),
                const SizedBox(height: 16),

                RoomInfoCard(room: room),
                const SizedBox(height: 16),

                RoomFacilitiesDetailCard(facilities: detail.facilities),
                const SizedBox(height: 16),

                RoomPaymentSummaryCard(payments: detail.payments),
                const SizedBox(height: 16),

                RoomComplaintSummaryCard(complaints: detail.complaints),
                const SizedBox(height: 16),

                RoomUserManagementCard(
                  users: detail.users,
                  capacity: room.capacity,
                  onAddUser: _onAddUser,
                  onEditUser: _onEditUser,
                  onRemoveUser: _onRemoveUser,
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

  void _onEditRoom() {
    // Navigasi ke EditRoomScreen akan disambungkan nanti.
  }

  void _onAddUser() {
    // Navigasi ke halaman tambah penghuni akan disambungkan nanti.
  }

  void _onEditUser(RoomDetailUser user) {
    // Fitur edit penghuni akan disambungkan nanti.
  }

  void _onRemoveUser(RoomDetailUser user) {
    // Fitur hapus penghuni akan disambungkan nanti.
  }

  Future<void> _onDeleteRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kamar'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            'Kamar ${_detail?.room.roomNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // Fungsi hapus kamar akan disambungkan ke RoomService nanti.
  }
}
