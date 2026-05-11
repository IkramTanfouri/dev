// lib/core/services/firebase_plat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plat.dart';
import 'i_plat_service.dart';
import 'firebase_service.dart';

class FirebasePlatService implements IPlatService {
  final _col =
      FirebaseFirestore.instance.collection(kColConsommables);

  @override
  Stream<List<Plat>> watchAll() {
    return _col.snapshots().map(
          (snap) => snap.docs.map(Plat.fromFirestore).toList(),
        );
  }

  @override
  Future<List<Plat>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map(Plat.fromFirestore).toList();
  }

  @override
  Future<void> add(Plat plat) => _col.add(plat.toMap());

  @override
  Future<void> update(Plat plat) =>
      _col.doc(plat.id).update(plat.toMap());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Future<Map<String, dynamic>> getAnalytics() async {
    final commandes = await FirebaseFirestore.instance
        .collection(kColCommande)
        .get();
    final feedbacks = await FirebaseFirestore.instance
        .collection(kColFeedbacks)
        .get();

    int totalCommandes = commandes.docs.length;
    int pending = commandes.docs
        .where((d) => (d.data()['statut'] ?? '') == 'en attente')
        .length;
    int completed = commandes.docs
        .where((d) => (d.data()['statut'] ?? '') == 'livree')
        .length;

    double avgNote = 0;
    if (feedbacks.docs.isNotEmpty) {
      final sum = feedbacks.docs
          .map((d) => (d.data()['note'] as num?)?.toDouble() ?? 0.0)
          .reduce((a, b) => a + b);
      avgNote = sum / feedbacks.docs.length;
    }

    // Orders per hour for today
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final Map<int, int> ordersPerHour = {};
    for (final doc in commandes.docs) {
      final ts = doc.data()['date'];
      if (ts == null) continue;
      final dt = (ts as dynamic).toDate() as DateTime;
      if (dt.isAfter(todayStart)) {
        ordersPerHour[dt.hour] = (ordersPerHour[dt.hour] ?? 0) + 1;
      }
    }

    return {
      'totalCommandes': totalCommandes,
      'pending': pending,
      'completed': completed,
      'avgNote': avgNote,
      'ordersPerHour': ordersPerHour,
    };
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) =>
      FirebaseService.getUserData(uid);

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) =>
      FirebaseService.updateUserData(uid, data);
}
