// lib/screens/menu_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/models/plat.dart';
import '../core/services/firebase_plat_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<_Category> _categories = const [
    _Category(label: 'Hot Drinks',  icon: 'assets/icons/hdrinks.png',  fallback: Icons.coffee,              key: 'hot_drinks'),
    _Category(label: 'Cold Drinks', icon: 'assets/icons/cdrinks.png',  fallback: Icons.local_cafe_outlined, key: 'cold_drinks'),
    _Category(label: 'Sweet',       icon: 'assets/icons/sweet.png',    fallback: Icons.cake_outlined,       key: 'sweet'),
    _Category(label: 'Savory',      icon: 'assets/icons/savory.png',   fallback: Icons.restaurant_outlined, key: 'savory'),
  ];

  int    _catIndex    = 0;
  String _searchQuery = '';
  final  _searchCtrl  = TextEditingController();
  final  _platService = FirebasePlatService();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Plat> _filterPlats(List<Plat> all) {
    var list = all;
    if (_catIndex != -1) {
      final key = _categories[_catIndex].key;
      list = list.where((p) => p.category == key).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) {
        final name = p.name.toLowerCase();
        final cat  = p.category.toLowerCase();
        return name.contains(_searchQuery) || cat.contains(_searchQuery);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(children: [

      // ── Header ──────────────────────────────────────────────────────────
      Container(
        color: kBrown,
        padding: EdgeInsets.only(top: topPad + 12, bottom: 12),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22)),
                  child: Row(children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search, color: kBrown.withOpacity(0.35), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontFamily: 'LeagueSpartan',
                            color: kBrown, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(fontFamily: 'LeagueSpartan',
                              color: kBrown.withOpacity(0.35), fontSize: 15),
                          border: InputBorder.none, isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                        child: Padding(padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.close, color: kBrown.withOpacity(0.4), size: 18)),
                      ),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 106,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_categories.length, (i) {
                final isActive = _catIndex == i;
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () => setState(() => _catIndex = _catIndex == i ? -1 : i),
                  child: isActive ? _ActiveTab(cat: cat) : _InactiveTab(cat: cat),
                );
              }),
            ),
          ),
        ]),
      ),

      // ── Product list ─────────────────────────────────────────────────────
      Expanded(
        child: ColoredBox(
          color: const Color(0xFFF5F5F5),
          child: StreamBuilder<List<Plat>>(
            stream: _platService.watchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: kBrown));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}',
                    style: const TextStyle(fontFamily: 'LeagueSpartan', color: Colors.red)));
              }
              final filtered = _filterPlats(snapshot.data ?? []);
              return _buildList(filtered);
            },
          ),
        ),
      ),
    ]);
  }

  Widget _buildList(List<Plat> plats) {
    if (plats.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: kBrown.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun résultat pour "$_searchQuery"'
                : 'Aucun produit dans cette catégorie',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'LeagueSpartan',
                color: kBrown.withOpacity(0.4), fontSize: 15)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: plats.length,
      itemBuilder: (_, i) => _PlatItem(plat: plats[i]),
    );
  }
}

// ── Product item ─────────────────────────────────────────────────────────────
class _PlatItem extends StatelessWidget {
  final Plat plat;
  const _PlatItem({required this.plat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: _buildImage(),
        ),
        const SizedBox(height: 12),
        Text(plat.name,
            style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown,
                fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: Text(plat.subtitle,
              style: TextStyle(fontFamily: 'LeagueSpartan',
                  color: kBrown.withOpacity(0.5), fontSize: 13))),
          const SizedBox(width: 8),
          Text(plat.formattedPrice,
              style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _buildImage() {
    if (plat.image.startsWith('http://') || plat.image.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: plat.image, width: double.infinity, height: 199,
        fit: BoxFit.contain,
        placeholder: (_, __) => const SizedBox(height: 199,
            child: Center(child: CircularProgressIndicator(color: kBrown, strokeWidth: 2))),
        errorWidget: (_, __, ___) => SizedBox(height: 199,
            child: Center(child: Icon(Icons.coffee, color: Color(0xFF6B3A2A), size: 80))),
      );
    }
    return Image.asset(plat.image, width: double.infinity, height: 199,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(height: 199,
            child: Center(child: Icon(Icons.coffee, color: Color(0xFF6B3A2A), size: 80))));
  }
}

// ── Active tab ────────────────────────────────────────────────────────────────
class _ActiveTab extends StatelessWidget {
  final _Category cat;
  const _ActiveTab({required this.cat});
  @override
  Widget build(BuildContext context) => Container(
    width: 90, height: 106,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(cat.icon, width: 36, height: 36, color: const Color(0xFF31190A),
          errorBuilder: (ctx, e, s) => Icon(cat.fallback, color: const Color(0xFF31190A), size: 32)),
      const SizedBox(height: 6),
      Text(cat.label, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'LeagueSpartan', color: Color(0xFF31190A),
              fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Inactive tab ──────────────────────────────────────────────────────────────
class _InactiveTab extends StatelessWidget {
  final _Category cat;
  const _InactiveTab({required this.cat});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 49, height: 62,
        decoration: BoxDecoration(color: const Color(0xFF988377),
            borderRadius: BorderRadius.circular(30)),
        child: Center(child: Image.asset(cat.icon, width: 28, height: 28,
            color: const Color(0xFF31190A),
            errorBuilder: (ctx, e, s) =>
                Icon(cat.fallback, color: const Color(0xFF31190A), size: 26))),
      ),
      const SizedBox(height: 6),
      Text(cat.label, style: TextStyle(fontFamily: 'LeagueSpartan',
          color: Colors.white.withOpacity(0.65), fontSize: 11)),
    ],
  );
}

class _Category {
  final String label, icon, key;
  final IconData fallback;
  const _Category({required this.label, required this.icon,
      required this.fallback, required this.key});
}
