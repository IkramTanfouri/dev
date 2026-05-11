// lib/screens/manager/manager_profile_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import '../page2_login_screen.dart';

const List<String> _emojis = [
  '🤖', '☕', '🍵', '👨‍🍳', '👩‍🍳', '🌟', '🔥', '🦁'
];

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  bool _editing = false;
  bool _saving = false;
  bool _loading = true;
  String _nom = '';
  String _email = '';
  String _emoji = '🤖';
  late TextEditingController _nomCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;
    final data = await FirebaseService.getUserData(uid);
    if (!mounted) return;
    setState(() {
      _nom = data?['nom'] ?? '';
      _email = data?['email'] ?? '';
      _emoji = data?['avatar'] ?? '🤖';
      _nomCtrl.text = _nom;
      _emailCtrl.text = _email;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;
    setState(() => _saving = true);
    await FirebaseService.updateUserData(uid, {
      'nom': _nomCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'avatar': _emoji,
    });
    if (!mounted) return;
    setState(() {
      _nom = _nomCtrl.text.trim();
      _email = _emailCtrl.text.trim();
      _saving = false;
      _editing = false;
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: kBrown, strokeWidth: 2));
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profil Manager',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                if (!_editing)
                  TextButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit, color: kBrown, size: 18),
                    label: const Text('Modifier',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(_emoji, style: const TextStyle(fontSize: 64)),
            if (_editing) ...
              [
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _emojis
                      .map((e) => GestureDetector(
                            onTap: () => setState(() => _emoji = e),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _emoji == e
                                    ? kBrown.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(e,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                          ))
                      .toList(),
                ),
              ],
            const SizedBox(height: 20),
            if (!_editing) ...
              [
                _row(Icons.person_outline, 'Nom', _nom),
                _row(Icons.email_outlined, 'Email', _email),
              ]
            else ...
              [
                _field('Nom', _nomCtrl),
                const SizedBox(height: 12),
                _field('Email', _emailCtrl,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _editing = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kBrown,
                          side: const BorderSide(color: kBrown),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrown,
                          foregroundColor: kWhite,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: kWhite, strokeWidth: 2))
                            : const Text('Enregistrer',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseService.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Déconnexion',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        color: Colors.red,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: kInputBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: kBrown, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 11,
                      color: kBrown.withOpacity(0.6))),
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kBrown)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kBrown)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontFamily: 'LeagueSpartan', color: kBrown),
          decoration: InputDecoration(
            filled: true,
            fillColor: kInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
