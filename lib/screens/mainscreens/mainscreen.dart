import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'listscreen.dart';
import 'taskscreen.dart';
import 'searchscreen.dart';

class Mainscreen extends StatefulWidget { const Mainscreen({super.key}); @override State<Mainscreen> createState() => _MainscreenState(); }
class _MainscreenState extends State<Mainscreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [ HomeScreen(), taskscreen_all(), listscreen(), searchscreen() ];
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
  backgroundColor: const Color(0xFF0047AB), // solid blue like before
  indicatorColor: Colors.white.withOpacity(0.2), // subtle highlight
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home, color: Colors.white),
      selectedIcon: Icon(Icons.home, color: Colors.white),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.checklist, color: Colors.white),
      selectedIcon: Icon(Icons.checklist, color: Colors.white),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt, color: Colors.white),
      selectedIcon: Icon(Icons.list_alt, color: Colors.white),
      label: 'Lists',
    ),
    NavigationDestination(
      icon: Icon(Icons.search, color: Colors.white),
      selectedIcon: Icon(Icons.search, color: Colors.white),
      label: 'Search',
    ),
  ],
  selectedIndex: _currentIndex,
  onDestinationSelected: (i) => setState(() => _currentIndex = i),
),

    );
  }
}
