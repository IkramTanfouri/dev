// lib/core/services/fake_plat_service.dart
import 'dart:async';
import '../models/plat.dart';
import 'i_plat_service.dart';

class FakePlatService implements IPlatService {
  final List<Plat> _plats = [
    Plat(id: '1', nom: 'Espresso', categorie: 'Boisson chaude', prix: 250, image: 'assets/images/espresso.png', isBestSeller: true),
    Plat(id: '2', nom: 'Cappuccino', categorie: 'Boisson chaude', prix: 350, image: 'assets/images/cappuccino.png'),
    Plat(id: '3', nom: 'Latte Glacé', categorie: 'Boisson froide', prix: 400, image: 'assets/images/latte.png', isBestSeller: true),
    Plat(id: '4', nom: 'Croissant', categorie: 'Patisserie', prix: 180, image: 'assets/images/croissant.png'),
    Plat(id: '5', nom: 'Muffin Chocolat', categorie: 'Patisserie', prix: 220, image: 'assets/images/muffin.png'),
    Plat(id: '6', nom: 'Club Sandwich', categorie: 'Snack', prix: 650, image: 'assets/images/sandwich.png'),
  ];

  final _controller = StreamController<List<Plat>>.broadcast();

  @override
  Stream<List<Plat>> watchAll() {
    Future.microtask(() => _controller.add(List.from(_plats)));
    return _controller.stream;
  }

  @override
  Future<List<Plat>> getAll() async => List.from(_plats);

  @override
  Future<void> add(Plat plat) async {
    _plats.add(plat);
    _controller.add(List.from(_plats));
  }

  @override
  Future<void> update(Plat plat) async {
    final i = _plats.indexWhere((p) => p.id == plat.id);
    if (i != -1) {
      _plats[i] = plat;
      _controller.add(List.from(_plats));
    }
  }

  @override
  Future<void> delete(String id) async {
    _plats.removeWhere((p) => p.id == id);
    _controller.add(List.from(_plats));
  }

  @override
  Future<Map<String, dynamic>> getAnalytics() async => {
        'totalCommandes': 42,
        'pending': 5,
        'completed': 37,
        'avgNote': 4.3,
        'ordersPerHour': {9: 3, 10: 7, 11: 5, 12: 12, 13: 8, 14: 4, 15: 3},
      };

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async => null;

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {}
}
