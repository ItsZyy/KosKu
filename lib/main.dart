import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Menjaga SplashScreen tidak push AuthGate saat user sedang masuk lewat
// link reset password (deep link) supaya tidak terjadi race navigation.
bool passwordRecoveryInProgress = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zhkmqbjupyuriaiywcry.supabase.co',
    publishableKey: 'sb_publishable_0QKkVJtdB6769CEl5Wo6zA_WXb0nUDC',
  );

  // Menangkap event recovery dari deep link reset password Supabase.
  // Saat link dari email dibuka, aplikasi terbuka lalu Supabase menukar
  // token dan mengirim event passwordRecovery. Dari sini user diarahkan
  // ke halaman membuat password baru.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      passwordRecoveryInProgress = true;
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRouter.resetPassword,
        (route) => false,
      );
    }
  });

  runApp(const KosKuApp());
}

class KosKuApp extends StatelessWidget {
  const KosKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'KosKu',
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: AppRouter.routes,
    );
  }
}