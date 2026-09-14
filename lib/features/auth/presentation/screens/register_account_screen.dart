import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../rooms/data/models/room_model.dart';
import '../../../rooms/data/services/room_service.dart';
import '../../data/services/auth_service.dart';
import '../widgets/register_account_form.dart';
import '../widgets/register_header.dart';
import '../widgets/register_personal_form.dart';
import '../widgets/register_room_form.dart';
import '../widgets/register_step_indicator.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final _authService = AuthService();
  final _roomService = RoomService();

  int _currentStep = 1;
  bool _isLoading = false;
  bool _isLoadingRooms = false;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _name = '';
  String _phone = '';
  String _address = '';
  String _emergencyName = '';
  String _emergencyPhone = '';
  String? _emergencyRelation;
  String? _selectedRoomId;

  List<RoomModel> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    if (_isLoadingRooms) return;

    setState(() {
      _isLoadingRooms = true;
    });

    try {
      final rooms = await _roomService.getAvailableRooms();

      if (!mounted) return;

      setState(() {
        _rooms = rooms;

        if (_selectedRoomId != null &&
            !rooms.any((room) => room.id == _selectedRoomId)) {
          _selectedRoomId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal memuat data kamar: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRooms = false;
        });
      }
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep >= 3) return;

    if (_currentStep == 2) {
      await _loadRooms();

      if (!mounted) return;
    }

    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep <= 1) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  Future<void> _handleRegister() async {
    if (_selectedRoomId == null) {
      _showMessage('Pilih kamar terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.register(
        email: _email.trim(),
        password: _password,
      );

      if (!mounted) return;

      final session = response.session;

      if (session == null) {
        _showMessage(
          'Akun berhasil dibuat. Silakan verifikasi email terlebih dahulu.',
        );
        return;
      }

      final supabase = _authService.supabase;

      await supabase.rpc(
        'register_user_with_room',
        params: {
          'p_name': _name.trim(),
          'p_phone': _phone.trim(),
          'p_address': _address.trim(),
          'p_emergency_contact_name': _emergencyName.trim(),
          'p_emergency_contact_phone': _emergencyPhone.trim(),
          'p_emergency_contact_relation': _emergencyRelation,
          'p_room_id': _selectedRoomId,
        },
      );

      if (!mounted) return;

      _showMessage('Pendaftaran berhasil. Selamat datang di KosKu!');

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.userDashboard,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Pendaftaran gagal: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCurrentForm() {
    switch (_currentStep) {
      case 1:
        return RegisterAccountForm(
          email: _email,
          password: _password,
          confirmPassword: _confirmPassword,
          onEmailChanged: (value) {
            _email = value;
          },
          onPasswordChanged: (value) {
            _password = value;
          },
          onConfirmPasswordChanged: (value) {
            _confirmPassword = value;
          },
          onNext: _nextStep,
          isLoading: _isLoading,
        );

      case 2:
        return RegisterPersonalForm(
          name: _name,
          phone: _phone,
          address: _address,
          emergencyName: _emergencyName,
          emergencyPhone: _emergencyPhone,
          emergencyRelation: _emergencyRelation,
          onNameChanged: (value) {
            _name = value;
          },
          onPhoneChanged: (value) {
            _phone = value;
          },
          onAddressChanged: (value) {
            _address = value;
          },
          onEmergencyNameChanged: (value) {
            _emergencyName = value;
          },
          onEmergencyPhoneChanged: (value) {
            _emergencyPhone = value;
          },
          onEmergencyRelationChanged: (value) {
            setState(() {
              _emergencyRelation = value;
            });
          },
          onNext: _nextStep,
          onBack: _previousStep,
          isLoading: _isLoading,
        );

      case 3:
        return RegisterRoomForm(
          rooms: _rooms,
          selectedRoomId: _selectedRoomId,
          onRoomSelected: (roomId) {
            setState(() {
              _selectedRoomId = roomId;
            });
          },
          onBack: _previousStep,
          onSubmit: _handleRegister,
          isLoading: _isLoading || _isLoadingRooms,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 380 ? 20 : 32,
            vertical: 8,
          ),
          child: Column(
            children: [
              RegisterHeader(currentStep: _currentStep),
              const SizedBox(height: 24),
              RegisterStepIndicator(currentStep: _currentStep),
              const SizedBox(height: 32),
              _buildCurrentForm(),
              const SizedBox(height: 24),
              if (_currentStep == 1)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Sudah punya akun? Login',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
