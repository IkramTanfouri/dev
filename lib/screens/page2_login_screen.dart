// lib/screens/page2_login_screen.dart
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'home_screen.dart';
import 'page3_signup_screen.dart';
import 'manager/manager_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      await FirebaseService.signIn(
          _emailCtrl.text.trim(), _passCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() => _error = 'Email ou mot de passe incorrect');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onLongPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManagerLoginScreen()),
                  ),
                  child: const Text(
                    'Hello!',
                    style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: kBrown,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 16,
                    color: kBrown.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _label('Email'),
              _input(_emailCtrl, 'votre@email.com',
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
                      style: const TextStyle(color: Colors.red, fontSize: 14)),
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
                      : const Text('Se connecter',
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas de compte ? ',
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.7)),
                      children: const [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: TextStyle(
                              color: kBrown, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
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
