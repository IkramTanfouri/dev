// lib/screens/manager/manager_main_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'manager_dashboard_screen.dart';
import 'manager_plats_screen.dart';
import 'manager_profile_screen.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  int _tab = 0;

  final List<Widget> _tabs = const [
    ManagerDashboardScreen(),
    ManagerPlatsScreen(),
    ManagerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: kWhite,
        indicatorColor: kBrown.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.coffee_outlined), label: 'Plats'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined), label: 'Profil'),
        ],
      ),
    );
  }
}
