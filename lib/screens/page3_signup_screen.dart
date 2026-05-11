// lib/screens/page3_signup_screen.dart
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _signup() async {
    if (_nomCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez remplir tous les champs obligatoires');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await FirebaseService.signUp(
          _emailCtrl.text.trim(), _passCtrl.text.trim());
      await FirebaseService.createUser(
        uid: cred.user!.uid,
        nom: _nomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = 'Erreur : ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Créer un compte',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: kBrown)),
              const SizedBox(height: 24),
              _label('Nom complet *'),
              _input(_nomCtrl, 'Votre nom'),
              const SizedBox(height: 14),
              _label('Email *'),
              _input(_emailCtrl, 'votre@email.com',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _label('Téléphone'),
              _input(_phoneCtrl, '+213 xx xx xx xx',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _label('Mot de passe *'),
              _input(_passCtrl, 'Min. 6 caractères',
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
                      style: const TextStyle(color: Colors.red, fontSize: 14)),
                ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: kWhite, strokeWidth: 2)
                      : const Text('S\'inscrire',
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
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
