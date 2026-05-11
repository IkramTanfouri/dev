// lib/core/services/i_plat_service.dart
import '../models/plat.dart';

abstract class IPlatService {
  Stream<List<Plat>> watchAll();
  Future<List<Plat>> getAll();
  Future<void> add(Plat plat);
  Future<void> update(Plat plat);
  Future<void> delete(String id);
  Future<Map<String, dynamic>> getAnalytics();
  Future<Map<String, dynamic>?> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}
