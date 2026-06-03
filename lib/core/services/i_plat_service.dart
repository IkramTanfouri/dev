// lib/core/services/i_plat_service.dart
import '../models/plat.dart';

abstract class IPlatService {
  // Stream
  Stream<List<Plat>> watchAll();

  // CRUD
  List<Plat> getAll();
  Plat? getById(String id);
  Plat add({
    required String name,
    required double price,
    required String category,
    required String image,
    String description,
    bool isBestSeller,
  });
  Plat update({
    required String id,
    required String name,
    required double price,
    required String category,
    required String image,
    String description,
    bool isBestSeller,
  });
  void delete(String id);

  // Stats
  int    get totalPlats;
  int    get totalFakeOrders;
  double get totalFakeSales;
  String get mostOrderedPlat;
  Map<int, int> getOrdersPerHour();
  int getMostActiveHour();

  // Manager profile
  String get managerName;
  String get managerEmail;
  String get managerAvatarAsset;
  void updateManagerProfile({
    required String name,
    required String email,
    required String avatarAsset,
  });
}
