// lib/screens/manager/manager_plats_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/plat.dart';
import '../../core/services/service_locator.dart';
import 'manager_add_edit_plat_screen.dart';

class ManagerPlatsScreen extends StatelessWidget {
  const ManagerPlatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
            child: Row(
              children: [
                const Text('Gestion des Plats',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManagerAddEditPlatScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter',
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Plat>>(
              stream: platService.watchAll(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: kBrown, strokeWidth: 2));
                }
                final plats = snap.data ?? [];
                if (plats.isEmpty) {
                  return const Center(
                      child: Text('Aucun plat. Ajoutez-en un !',
                          style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              color: kGrey,
                              fontSize: 15)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plats.length,
                  itemBuilder: (_, i) => _PlatTile(
                    plat: plats[i],
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ManagerAddEditPlatScreen(plat: plats[i])),
                    ),
                    onDelete: () => _confirmDelete(context, plats[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Plat plat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer',
            style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown)),
        content: Text('Supprimer "${plat.nom}" ?',
            style: const TextStyle(fontFamily: 'LeagueSpartan')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(
                    fontFamily: 'LeagueSpartan', color: kBrown)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await platService.delete(plat.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: kWhite),
            child: const Text('Supprimer',
                style: TextStyle(fontFamily: 'LeagueSpartan')),
          ),
        ],
      ),
    );
  }
}

class _PlatTile extends StatelessWidget {
  final Plat plat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PlatTile(
      {required this.plat, required this.onEdit, required this.onDelete});

  Widget _image() {
    final src = plat.image;
    if (src.startsWith('http')) {
      return Image.network(src,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.coffee, color: kBrown));
    }
    return Image.asset(src,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.coffee, color: kBrown));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: kInputBg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10), child: _image()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plat.nom,
                    style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                Text('${plat.categorie} • ${plat.prix.toStringAsFixed(0)} DA',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 12,
                        color: kBrown.withOpacity(0.65))),
                if (plat.isBestSeller)
                  const Text('Best Seller',
                      style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 11,
                          color: kBrownLight,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.edit_outlined, color: kBrown),
              onPressed: onEdit),
          IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete),
        ],
      ),
    );
  }
}
