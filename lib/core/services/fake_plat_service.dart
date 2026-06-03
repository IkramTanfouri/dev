// lib/core/services/fake_plat_service.dart
import 'dart:async';
import '../models/plat.dart';
import 'i_plat_service.dart';

class FakePlatService implements IPlatService {
  final List<Plat> _plats = [
    Plat(id: '1', name: 'Espresso',       price: 250, category: 'hot_drinks',  image: 'assets/images/macchiato.png',     isBestSeller: true),
    Plat(id: '2', name: 'Cappuccino',     price: 350, category: 'hot_drinks',  image: 'assets/images/macchiato.png'),
    Plat(id: '3', name: 'Iced Macchiato', price: 400, category: 'cold_drinks', image: 'assets/images/iced_macchiato.png', isBestSeller: true),
    Plat(id: '4', name: 'Croissant',      price: 180, category: 'sweet',       image: 'assets/images/cachuete.png'),
    Plat(id: '5', name: 'Muffin',         price: 220, category: 'sweet',       image: 'assets/images/cachuete.png'),
    Plat(id: '6', name: 'Club Sandwich',  price: 650, category: 'savory',      image: 'assets/images/salade_cesar.png'),
  ];

  final _controller = StreamController<List<Plat>>.broadcast();

  String _managerName        = 'Manager Barista';
  String _managerEmail       = 'manager@barista.com';
  String _managerAvatarAsset = '';

  @override
  Stream<List<Plat>> watchAll() {
    Future.microtask(() => _controller.add(List.from(_plats)));
    return _controller.stream;
  }

  @override
  List<Plat> getAll() => List.unmodifiable(_plats);

  @override
  Plat? getById(String id) {
    try { return _plats.firstWhere((p) => p.id == id); }
    catch (_) { return null; }
  }

  @override
  Plat add({
    required String name,
    required double price,
    required String category,
    required String image,
    String description  = '',
    bool   isBestSeller = false,
  }) {
    final plat = Plat(
      id: 'fake_${DateTime.now().millisecondsSinceEpoch}',
      name: name, price: price, category: category,
      image: image, description: description, isBestSeller: isBestSeller,
    );
    _plats.add(plat);
    _controller.add(List.from(_plats));
    return plat;
  }

  @override
  Plat update({
    required String id,
    required String name,
    required double price,
    required String category,
    required String image,
    String description  = '',
    bool   isBestSeller = false,
  }) {
    final updated = Plat(id: id, name: name, price: price,
        category: category, image: image,
        description: description, isBestSeller: isBestSeller);
    final i = _plats.indexWhere((p) => p.id == id);
    if (i != -1) {
      _plats[i] = updated;
      _controller.add(List.from(_plats));
    }
    return updated;
  }

  @override
  void delete(String id) {
    _plats.removeWhere((p) => p.id == id);
    _controller.add(List.from(_plats));
  }

  @override int    get totalPlats      => _plats.length;
  @override int    get totalFakeOrders => 20;
  @override double get totalFakeSales  => 204.5;
  @override String get mostOrderedPlat =>
      _plats.isNotEmpty ? _plats.first.name : '---';

  @override Map<int, int> getOrdersPerHour() =>
      {9: 3, 10: 7, 11: 5, 12: 12, 13: 8, 14: 4, 15: 3};
  @override int getMostActiveHour() => 12;

  @override String get managerName        => _managerName;
  @override String get managerEmail       => _managerEmail;
  @override String get managerAvatarAsset => _managerAvatarAsset;

  @override
  void updateManagerProfile({
    required String name,
    required String email,
    required String avatarAsset,
  }) {
    _managerName        = name;
    _managerEmail       = email;
    _managerAvatarAsset = avatarAsset;
  }
}
