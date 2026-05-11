// lib/screens/leave_review_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String commandeId;
  const LeaveReviewScreen({super.key, required this.commandeId});

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  int _note = 5;
  final _commentCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseService.addFeedback({
        'clientId': uid,
        'commandeId': widget.commandeId,
        'note': _note,
        'commentaire': _commentCtrl.text.trim(),
        'date': Timestamp.now(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci pour votre avis !',
              style: TextStyle(fontFamily: 'LeagueSpartan')),
          backgroundColor: kBrown,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Laisser un avis',
            style: TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kBrown)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Votre note',
                style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kBrown)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _note = i + 1),
                  child: Icon(
                    i < _note ? Icons.star : Icons.star_border,
                    color: kBrown,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Commentaire',
                style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kBrown)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown),
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience…',
                hintStyle: TextStyle(color: kBrown.withOpacity(0.4)),
                filled: true,
                fillColor: kInputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrown,
                  foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(
                        color: kWhite, strokeWidth: 2)
                    : const Text('Envoyer',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
