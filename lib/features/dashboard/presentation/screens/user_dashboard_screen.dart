import 'package:flutter/material.dart';

import '../../../profile/data/services/profile_service.dart';
import '../../../rooms/data/services/room_service.dart';
import '../../../payments/data/services/payment_service.dart';
import '../../../announcements/data/models/announcement_model.dart';
import '../../../announcements/data/services/announcement_service.dart';
import '../../../announcements/presentation/screens/announcements_screen.dart';

import '../widgets/user_dashboard_header.dart';
import '../widgets/user_dashboard_banner.dart';
import '../widgets/user_dashboard_payment_card.dart';
import '../widgets/user_dashboard_room_card.dart';
import '../widgets/user_dashboard_announcement.dart';

class UserDashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenProfile;

  const UserDashboardScreen({super.key, this.onOpenProfile});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _profileService = ProfileService();
  final _roomService = RoomService();
  final _paymentService = PaymentService();
  final _announcementService = AnnouncementService();

  String? userName;
  String? profilePhotoUrl;

  Map<String, dynamic>? room;
  Map<String, dynamic>? payment;
  List<AnnouncementModel> announcements = [];

  @override
  void initState() {
    super.initState();

    _loadUser();
    _loadRoom();
    _loadPayment();
    _loadAnnouncement();
  }

  Future<void> _loadUser() async {
    try {
      final profile = await _profileService.getProfile();

      if (profile != null && mounted) {
        setState(() {
          userName = profile.name;
        });

        if (profile.profilePhotoUrl != null &&
            profile.profilePhotoUrl!.isNotEmpty) {
          final signedUrl = await _profileService.getProfilePhotoUrl(
            profile.profilePhotoUrl,
          );

          if (mounted) {
            setState(() {
              profilePhotoUrl = signedUrl;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('UserDashboard load user error: $e');
    }
  }

  Future<void> _loadRoom() async {
    try {
      final profile = await _profileService.getProfile();

      if (profile == null) {
        return;
      }

      final data = await _roomService.getRoom();

      if (data != null && mounted) {
        setState(() {
          room = data;
        });
      }
    } catch (e) {
      debugPrint('UserDashboard load room error: $e');
    }
  }

  Future<void> _loadPayment() async {
    try {
      final data = await _paymentService.getPayment();

      if (data != null && mounted) {
        setState(() {
          payment = data;
        });
      }
    } catch (e) {
      debugPrint('UserDashboard load payment error: $e');
    }
  }

  Future<void> _loadAnnouncement() async {
    try {
      final data = await _announcementService.getAnnouncements();

      if (mounted) {
        setState(() {
          announcements = data.take(3).toList();
        });
      }
    } catch (e) {
      debugPrint('UserDashboard load announcement error: $e');
    }
  }

  void _onViewAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: CustomScrollView(
        clipBehavior: Clip.none,
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Column(
                  children: [
                    UserDashboardHeader(
                      userName: userName,
                      profilePhotoUrl: profilePhotoUrl,
                      onProfileTap: widget.onOpenProfile,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: UserDashboardPaymentCard(payment: payment),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 15)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UserDashboardBanner(),
                  const SizedBox(height: 24),
                  UserDashboardRoomCard(room: room),
                  const SizedBox(height: 24),
                  UserDashboardAnnouncement(
                    announcements: announcements,
                    onViewAll: _onViewAnnouncements,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
