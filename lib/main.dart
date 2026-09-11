import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zhkmqbjupyuriaiywcry.supabase.co',
    publishableKey: 'sb_publishable_0QKkVJtdB6769CEl5Wo6zA_WXb0nUDC',
  );

  runApp(const KosKuApp());
}

class KosKuApp extends StatelessWidget {
  const KosKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KosKu',
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: AppRouter.routes,
    );
  }
}
