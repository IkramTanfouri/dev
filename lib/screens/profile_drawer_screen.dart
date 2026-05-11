// lib/screens/profile_drawer_screen.dart
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'page2_login_screen.dart';

class ProfileDrawerScreen extends StatelessWidget {
  final String userName;
  final String avatarUrl;

  const ProfileDrawerScreen(
      {super.key, required this.userName, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseService.currentUser?.email ?? '';
    return Drawer(
      backgroundColor: kBg,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(avatarUrl),
                    key: ValueKey(avatarUrl),
                  )
                : CircleAvatar(
                    radius: 44,
                    backgroundColor: kInputBg,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: kBrown),
                    ),
                  ),
            const SizedBox(height: 12),
            Text(userName,
                style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kBrown)),
            const SizedBox(height: 4),
            Text(email,
                style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 13,
                    color: kBrown.withOpacity(0.6))),
            const SizedBox(height: 28),
            const Divider(indent: 24, endIndent: 24),
            _tile(context, Icons.home_outlined, 'Accueil', () => Navigator.pop(context)),
            _tile(context, Icons.history_outlined, 'Mes commandes', () {}),
            _tile(context, Icons.star_outline, 'Mes avis', () {}),
            _tile(context, Icons.settings_outlined, 'Paramètres', () {}),
            const Spacer(),
            const Divider(indent: 24, endIndent: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.red,
                      fontWeight: FontWeight.w600)),
              onTap: () async {
                await FirebaseService.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kBrown),
      title: Text(label,
          style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              fontSize: 15,
              color: kBrown)),
      onTap: onTap,
    );
  }
}
