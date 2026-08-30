import 'package:flutter/material.dart';

import '../../data/models/room_model.dart';
import '../../data/services/room_service.dart';
import '../widgets/room_card.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _roomService = RoomService();

  List<RoomModel> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _roomService.getRooms();

      if (!mounted) return;

      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil data kamar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kamar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
          ? const Center(child: Text('Belum ada kamar'))
          : RefreshIndicator(
              onRefresh: _loadRooms,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoomCard(
                      room: room,
                      onTap: () {
                        // Detail kamar nanti
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // AddRoomScreen nanti
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kamar'),
      ),
    );
  }
}
