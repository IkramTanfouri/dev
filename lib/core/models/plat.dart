// lib/core/models/plat.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Plat {
  final String id;
  final String nom;
  final String categorie;
  final double prix;
  final String image;
  final bool isBestSeller;

  Plat({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.prix,
    required this.image,
    this.isBestSeller = false,
  });

  factory Plat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Plat(
      id: doc.id,
      nom: data['nom'] ?? '',
      categorie: data['categorie'] ?? '',
      prix: (data['prix'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      isBestSeller: data['isBestSeller'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'categorie': categorie,
        'prix': prix,
        'image': image,
        'isBestSeller': isBestSeller,
      };

  Plat copyWith({
    String? id,
    String? nom,
    String? categorie,
    double? prix,
    String? image,
    bool? isBestSeller,
  }) {
    return Plat(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      categorie: categorie ?? this.categorie,
      prix: prix ?? this.prix,
      image: image ?? this.image,
      isBestSeller: isBestSeller ?? this.isBestSeller,
    );
  }

  static const List<String> availableImages = [
    'assets/images/espresso.png',
    'assets/images/cappuccino.png',
    'assets/images/latte.png',
    'assets/images/americano.png',
    'assets/images/mocha.png',
    'assets/images/croissant.png',
    'assets/images/muffin.png',
    'assets/images/sandwich.png',
  ];

  static String defaultImageFor(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'boisson chaude':
        return 'assets/images/espresso.png';
      case 'boisson froide':
        return 'assets/images/latte.png';
      case 'patisserie':
        return 'assets/images/croissant.png';
      case 'snack':
        return 'assets/images/sandwich.png';
      default:
        return 'assets/images/espresso.png';
    }
  }
}
