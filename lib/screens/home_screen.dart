// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'profile_drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _userName = '';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;
    final data = await FirebaseService.getUserData(uid);
    if (!mounted) return;
    setState(() {
      _userName = data?['nom'] ?? '';
      _avatarUrl = data?['avatar'] ?? '';
    });
  }

  final List<Widget> _tabs = const [
    _HomeTab(),
    MenuScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      drawer: ProfileDrawerScreen(userName: _userName, avatarUrl: _avatarUrl),
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: kWhite,
        indicatorColor: kBrown.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.coffee_outlined), label: 'Menu'),
          NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Panier'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseService.getUserData(FirebaseService.currentUid ?? ''),
      builder: (ctx, snap) {
        final name = snap.data?['nom'] ?? '';
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (c) => IconButton(
                  icon: const Icon(Icons.menu, color: kBrown),
                  onPressed: () => Scaffold.of(c).openDrawer(),
                )),
                const SizedBox(height: 8),
                Text('Bonjour, $name 👋',
                    style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                const SizedBox(height: 4),
                Text('Que voulez-vous aujourd\'hui ?',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 15,
                        color: kBrown.withOpacity(0.65))),
                const SizedBox(height: 28),
                _PromoCard(),
                const SizedBox(height: 28),
                const Text('Nos catégories',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CatChip(label: 'Café', icon: '☕'),
                      _CatChip(label: 'Thé', icon: '🍵'),
                      _CatChip(label: 'Cold', icon: '🧋'),
                      _CatChip(label: 'Food', icon: '🥐'),
                      _CatChip(label: 'Snack', icon: '🥪'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [kBrown, kBrownLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('20% de réduction',
              style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kWhite)),
          const SizedBox(height: 4),
          Text('Sur votre première commande',
              style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 14,
                  color: kWhite.withOpacity(0.85))),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final String icon;
  const _CatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 12,
                  color: kBrown)),
        ],
      ),
    );
  }
}
