import 'dart:async';
import 'package:flutter/material.dart';
import '../mainscreens/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Mainscreen()));
    });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0047AB),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.task_alt, size: 80, color: Colors.white),
        SizedBox(height: 12),
        Text('TrekList', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Organize and prioritize your tasks', style: TextStyle(color: Colors.white70)),
      ])),
    );
  }
}
