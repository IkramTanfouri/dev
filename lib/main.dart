// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/colors.dart';
import 'screens/page1_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyBaristaApp());
}

class MyBaristaApp extends StatelessWidget {
  const MyBaristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Barista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kBrown),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
