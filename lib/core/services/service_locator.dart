// lib/core/services/service_locator.dart
import 'i_plat_service.dart';
import 'firebase_plat_service.dart';
// import 'fake_plat_service.dart'; // swap here to use fake data

final IPlatService platService = FirebasePlatService();
