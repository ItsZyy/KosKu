import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zhkmqbjupyuriaiywcry.supabase.co',
    anonKey: 'sb_publishable_0QKkVJtdB6769CEl5Wo6zA_WXb0nUDC',
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
