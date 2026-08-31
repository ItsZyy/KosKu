import 'package:flutter/material.dart';

import '../../data/models/room_model.dart';
import '../../data/services/room_service.dart';
import '../widgets/room_summary.dart';
import '../widgets/room_filter.dart';
import '../widgets/room_card.dart';
import 'add_room_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final RoomService _roomService = RoomService();

  List<RoomModel> _rooms = [];

  Map<String, Map<String, dynamic>> _roomUsers = {};

  bool _isLoading = true;

  String? _error;

  String _selectedFilter = 'Semua';

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rooms = await _roomService.getRooms();

      final roomUsers = await _roomService.getRoomUsers();

      if (!mounted) {
        return;
      }

      setState(() {
        _rooms = rooms;
        _roomUsers = roomUsers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<RoomModel> get _filteredRooms {
    final query = _searchQuery.trim().toLowerCase();

    return _rooms.where((room) {
      final user = _roomUsers[room.id];

      final userName = user?['name']?.toString().toLowerCase() ?? '';

      final roomNumber = room.roomNumber.toLowerCase();

      final matchesSearch =
          roomNumber.contains(query) || userName.contains(query);

      final matchesFilter =
          _selectedFilter == 'Semua' || room.status == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _totalRooms {
    return _rooms.length;
  }

  int get _occupiedRooms {
    return _rooms.where((room) {
      return room.status == 'Terisi';
    }).length;
  }

  int get _totalUsers {
    return _roomUsers.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamar')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _loadRooms,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoomSummary(
            totalRooms: _totalRooms,
            totalTenants: _totalUsers,
            occupiedRooms: _occupiedRooms,
          ),

          const SizedBox(height: 16),

          _buildSearch(),

          const SizedBox(height: 12),

          RoomFilter(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          const SizedBox(height: 16),

          ..._buildRoomList(),

          const SizedBox(height: 16),

          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari nomor kamar atau user...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  List<Widget> _buildRoomList() {
    final rooms = _filteredRooms;

    if (rooms.isEmpty) {
      return [
        const SizedBox(height: 40),

        const Center(
          child: Column(
            children: [
              Icon(Icons.meeting_room_outlined, size: 56),

              SizedBox(height: 12),

              Text(
                'Tidak ada kamar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ];
    }

    return rooms.map((room) {
      final user = _roomUsers[room.id];

      final userName = user?['name']?.toString();

      final contractStart = user?['contract_start']?.toString();

      final contractEnd = user?['contract_end']?.toString();

      return RoomCard(
        room: room,

        userName: userName,

        contractStart: contractStart,

        contractEnd: contractEnd,

        onDetail: () {
          _showMessage('Detail kamar ${room.roomNumber}');
        },

        onRent: () {
          _showMessage('Sewakan kamar ${room.roomNumber}');
        },

        onAddUser: () {
          _showMessage('Tambah user kamar ${room.roomNumber}');
        },

        onFinishRepair: () {
          _showMessage('Selesaikan perbaikan kamar ${room.roomNumber}');
        },
      );
    }).toList();
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final added = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddRoomScreen()),
              );

              if (added == true) {
                _loadRooms();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kamar'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showMessage('Lihat user');
            },
            icon: const Icon(Icons.people_outline),
            label: const Text('Lihat User'),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),

            const SizedBox(height: 12),

            const Text(
              'Gagal memuat kamar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(_error!, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadRooms,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
