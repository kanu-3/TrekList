import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trek_list/data/database/appbase.dart';
import 'screens/splashscreens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ensure DB is initialized before app runs
  await AppDatabase.instance.database;

  runApp(const ProviderScope(child: TrekListApp()));
}

class TrekListApp extends StatelessWidget {
  const TrekListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrekList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0047AB),
        scaffoldBackgroundColor: const Color(0xFFEFE9E3),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
