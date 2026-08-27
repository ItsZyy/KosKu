import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/user_dashboard_screen.dart';
import '../../features/announcements/presentation/screens/announcements_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String userDashboard = '/user-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String announcements = '/announcements';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    userDashboard: (context) => const UserDashboardScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    announcements: (context) => const AnnouncementsScreen(),
  };
}
