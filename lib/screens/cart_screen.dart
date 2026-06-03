// lib/screens/cart_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/models/plat.dart';
import '../core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final Plat plat;
  int qty;
  CartItem({required this.plat, this.qty = 1});
}

// Simple in-memory cart state — in a real app use a state manager
class CartState {
  static final List<CartItem> items = [];

  static void add(Plat plat) {
    final existing = items.cast<CartItem?>().firstWhere(
        (i) => i?.plat.id == plat.id,
        orElse: () => null);
    if (existing != null) {
      existing.qty++;
    } else {
      items.add(CartItem(plat: plat));
    }
  }

  static double get total =>
      items.fold(0, (sum, i) => sum + i.plat.price * i.qty);
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _ordering = false;

  Future<void> _placeOrder() async {
    if (CartState.items.isEmpty) return;
    final uid = FirebaseService.currentUid;
    if (uid == null) return;
    setState(() => _ordering = true);
    try {
      final ref = await FirebaseService.createCommande({
        'clientId': uid,
        'date': Timestamp.now(),
        'statut': 'en attente',
      });
      final batch = FirebaseFirestore.instance.batch();
      for (final item in CartState.items) {
        final subRef = ref.collection(kSubColQuantites).doc();
        batch.set(subRef, {
          'produitId': item.plat.id,
          'nom': item.plat.name,
          'prix': item.plat.price,
          'quantite': item.qty,
        });
      }
      await batch.commit();
      CartState.items.clear();
      if (!mounted) return;
      setState(() => _ordering = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée !',
              style: TextStyle(fontFamily: 'LeagueSpartan')),
          backgroundColor: kBrown,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _ordering = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = CartState.items;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Text('Mon Panier',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                const Spacer(),
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => CartState.items.clear()),
                    child: const Text('Vider',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan', color: Colors.red)),
                  ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Votre panier est vide',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 16,
                        color: kGrey)),
              ),
            )
          else ...
            [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _CartTile(
                    item: items[i],
                    onChanged: () => setState(() {}),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: kBrown)),
                        Text('${CartState.total.toStringAsFixed(0)} DA',
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: kBrown)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _ordering ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrown,
                          foregroundColor: kWhite,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _ordering
                            ? const CircularProgressIndicator(
                                color: kWhite, strokeWidth: 2)
                            : const Text('Commander',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onChanged;
  const _CartTile({required this.item, required this.onChanged});

  Widget _image() {
    final src = item.plat.image;
    if (src.startsWith('http')) {
      return Image.network(src,
          width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.coffee, color: kBrown));
    }
    if (!kIsWeb && src.startsWith('/')) {
      return Image.file(File(src),
          width: 60, height: 60, fit: BoxFit.cover);
    }
    return Image.asset(src,
        width: 60,
        height: 60,
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
                Text(item.plat.name,
                    style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kBrown)),
                Text(item.plat.formattedPrice,
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 13,
                        color: kBrown.withOpacity(0.7))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: kBrown, size: 22),
                onPressed: () {
                  if (item.qty > 1) {
                    item.qty--;
                  } else {
                    CartState.items.remove(item);
                  }
                  onChanged();
                },
              ),
              Text('${item.qty}',
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kBrown)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: kBrown, size: 22),
                onPressed: () {
                  item.qty++;
                  onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
