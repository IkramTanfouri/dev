// lib/screens/manager/manager_login_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firebase_service.dart';
import 'manager_main_screen.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await FirebaseService.signIn(
          _emailCtrl.text.trim(), _passCtrl.text.trim());
      final role = await FirebaseService.getUserRole(cred.user!.uid);
      if (role != 'manager') {
        await FirebaseService.signOut();
        setState(() => _error = 'Accès refusé : rôle manager requis');
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManagerMainScreen()),
      );
    } catch (e) {
      setState(() => _error = 'Identifiants incorrects');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kBrown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Espace Manager',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: kBrown)),
              const SizedBox(height: 8),
              Text('Accès réservé aux managers',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 15,
                      color: kBrown.withOpacity(0.65))),
              const SizedBox(height: 36),
              _label('Email'),
              _input(_emailCtrl, 'manager@barista.com',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _label('Mot de passe'),
              _input(_passCtrl, '••••••',
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: kBrown),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              if (_error != null) ...
                [
                  const SizedBox(height: 12),
                  Text(_error!,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 14)),
                ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: kWhite, strokeWidth: 2)
                      : const Text('Connexion',
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kBrown)),
      );

  Widget _input(
    TextEditingController ctrl,
    String hint, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kBrown.withOpacity(0.4)),
        filled: true,
        fillColor: kInputBg,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
