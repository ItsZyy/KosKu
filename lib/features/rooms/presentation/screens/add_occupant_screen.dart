import 'package:flutter/material.dart';

import 'package:kosku/core/theme/app_colors.dart';
import 'package:kosku/core/theme/app_text_styles.dart';
import 'package:kosku/features/rooms/data/services/room_service.dart';

import '../widgets/occupant_contract_card.dart';
import '../widgets/occupant_selection_card.dart';

class AddOccupantScreen extends StatefulWidget {
  final String roomId;

  const AddOccupantScreen({super.key, required this.roomId});

  @override
  State<AddOccupantScreen> createState() => _AddOccupantScreenState();
}

class _AddOccupantScreenState extends State<AddOccupantScreen> {
  final RoomService _roomService = RoomService();

  List<Map<String, dynamic>> _users = [];

  Map<String, dynamic>? _selectedUser;

  DateTime _contractStart = DateTime.now();
  late DateTime _contractEnd;

  double _rentPrice = 0;

  final int _paymentIntervalMonths = 6;
  late int _paymentDay;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _contractEnd = DateTime(
      _contractStart.year + 1,
      _contractStart.month,
      _contractStart.day,
    );

    _paymentDay = _contractStart.day;

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await _roomService.getUsersForOccupantSelection();
      final detail = await _roomService.getRoomDetail(widget.roomId);

      if (!mounted) {
        return;
      }

      setState(() {
        _users = users;

        if (detail != null) {
          _rentPrice = detail.room.price;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint('AddOccupantScreen load error: $e');

      setState(() {
        _errorMessage = 'Gagal memuat data penghuni.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tambah Penghuni', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _buildBody(),
      bottomNavigationBar: _selectedUser == null || _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveOccupant,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.person_add_outlined),
                    label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Penghuni'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          OccupantSelectionCard(
            users: _users,
            selectedUserId: _selectedUser?['id'] as String?,
            onSelected: _selectUser,
          ),
          if (_selectedUser != null) ...[
            const SizedBox(height: 16),
            OccupantContractCard(
              contractStart: _contractStart,
              contractEnd: _contractEnd,
              rentPrice: _rentPrice,
              paymentDay: _paymentDay,
              onSelectStartDate: _selectContractStart,
              onSelectEndDate: _selectContractEnd,
              onPaymentDayChanged: (value) {
                setState(() {
                  _paymentDay = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  void _selectUser(Map<String, dynamic> user) {
    setState(() {
      _selectedUser = user;
    });
  }

  Future<void> _selectContractStart() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _contractStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _contractStart = selectedDate;
      _paymentDay = selectedDate.day;

      if (!_contractEnd.isAfter(selectedDate)) {
        _contractEnd = DateTime(
          selectedDate.year + 1,
          selectedDate.month,
          selectedDate.day,
        );
      }
    });
  }

  Future<void> _selectContractEnd() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _contractEnd.isAfter(_contractStart)
          ? _contractEnd
          : _contractStart.add(const Duration(days: 1)),
      firstDate: _contractStart.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _contractEnd = selectedDate;
    });
  }

  Future<void> _saveOccupant() async {
    final selectedUser = _selectedUser;

    if (selectedUser == null) {
      return;
    }

    if (!_contractEnd.isAfter(_contractStart)) {
      _showError('Tanggal selesai kontrak harus setelah tanggal mulai.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _roomService.addOccupancy(
        roomId: widget.roomId,
        userId: selectedUser['id'] as String,
        contractStart: _contractStart,
        contractEnd: _contractEnd,
        rentPrice: _rentPrice,
        paymentIntervalMonths: _paymentIntervalMonths,
        paymentDay: _paymentDay,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penghuni berhasil ditambahkan.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint('Add occupant error: $e');

      _showError('Gagal menambahkan penghuni.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
