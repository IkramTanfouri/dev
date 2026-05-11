// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/models/plat.dart';
import '../core/services/firebase_plat_service.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _service = FirebasePlatService();
  String _selectedCategory = 'Tous';

  static const List<Map<String, String>> _categories = [
    {'label': 'Tous', 'icon': '☕'},
    {'label': 'Boisson chaude', 'icon': '🍵'},
    {'label': 'Boisson froide', 'icon': '🧋'},
    {'label': 'Patisserie', 'icon': '🥐'},
    {'label': 'Snack', 'icon': '🥪'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: const Text(
              'Notre Menu',
              style: TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: kBrown,
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat['label'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat['label']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? kBrown : kInputBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      '${cat['icon']}  ${cat['label']}',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? kWhite : kBrown,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Product grid
          Expanded(
            child: StreamBuilder<List<Plat>>(
              stream: _service.watchAll(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: kBrown, strokeWidth: 2));
                }
                if (snap.hasError) {
                  return Center(
                      child: Text('Erreur : ${snap.error}',
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan', color: kBrown)));
                }
                final all = snap.data ?? [];
                final filtered = _selectedCategory == 'Tous'
                    ? all
                    : all
                        .where((p) => p.categorie == _selectedCategory)
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun produit dans cette catégorie',
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 15,
                          color: kGrey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _PlatCard(
                    plat: filtered[i],
                    onAddToCart: () {
                      CartState.add(filtered[i]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${filtered[i].nom} ajouté au panier',
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan'),
                          ),
                          backgroundColor: kBrown,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatCard extends StatelessWidget {
  final Plat plat;
  final VoidCallback onAddToCart;
  const _PlatCard({required this.plat, required this.onAddToCart});

  Widget _image() {
    final src = plat.image;
    if (src.startsWith('http')) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        key: ValueKey(src),
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.coffee, color: kBrown, size: 40)),
      );
    }
    return Image.asset(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.coffee, color: kBrown, size: 40)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBrown.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: _image(),
                ),
                if (plat.isBestSeller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Best Seller',
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kWhite,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plat.nom,
                  style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kBrown,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  plat.categorie,
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 11,
                    color: kBrown.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${plat.prix.toStringAsFixed(0)} DA',
                      style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kBrown,
                      ),
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: kBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: kWhite, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
