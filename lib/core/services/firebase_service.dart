// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Collection name constants
const String kColUsers = 'users';
const String kColClient = 'client';
const String kColManager = 'manager';
const String kColBarista = 'barista';
const String kColConsommables = 'consommables';
const String kColCommande = 'Commande';
const String kColFeedbacks = 'feedbacks';
const String kSubColQuantites = 'quantitesCommandees';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth ─────────────────────────────────────────────────────────────────

  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;

  static Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  static Future<void> signOut() => _auth.signOut();

  // ── Users collection ─────────────────────────────────────────────────────

  static Future<void> createUser({
    required String uid,
    required String nom,
    required String email,
    String role = 'client',
    String phone = '',
    String dob = '',
    String avatar = '',
  }) async {
    await _db.collection(kColUsers).doc(uid).set({
      'nom': nom,
      'email': email,
      'role': role,
      'phone': phone,
      'dob': dob,
      'avatar': avatar,
    });
    if (role == 'client') {
      await _db.collection(kColClient).doc(uid).set({
        'idCl': uid,
        'preferences': [],
      });
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection(kColUsers).doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> updateUserData(
      String uid, Map<String, dynamic> data) async {
    await _db.collection(kColUsers).doc(uid).update(data);
  }

  // ── Role check ───────────────────────────────────────────────────────────

  static Future<String?> getUserRole(String uid) async {
    final data = await getUserData(uid);
    return data?['role'] as String?;
  }

  // ── Consommables ─────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> watchConsommables() =>
      _db.collection(kColConsommables).snapshots();

  static Future<QuerySnapshot> getConsommables() =>
      _db.collection(kColConsommables).get();

  static Future<DocumentReference> addConsommable(
          Map<String, dynamic> data) =>
      _db.collection(kColConsommables).add(data);

  static Future<void> updateConsommable(
          String id, Map<String, dynamic> data) =>
      _db.collection(kColConsommables).doc(id).update(data);

  static Future<void> deleteConsommable(String id) =>
      _db.collection(kColConsommables).doc(id).delete();

  // ── Commandes ────────────────────────────────────────────────────────────

  static Future<DocumentReference> createCommande(
      Map<String, dynamic> data) =>
      _db.collection(kColCommande).add(data);

  static Stream<QuerySnapshot> watchCommandesForClient(String clientId) =>
      _db
          .collection(kColCommande)
          .where('clientId', isEqualTo: clientId)
          .orderBy('date', descending: true)
          .snapshots();

  static Stream<QuerySnapshot> watchAllCommandes() =>
      _db
          .collection(kColCommande)
          .orderBy('date', descending: true)
          .snapshots();

  static Future<void> updateCommandeStatus(String id, String statut) =>
      _db.collection(kColCommande).doc(id).update({'statut': statut});

  // ── Feedbacks ────────────────────────────────────────────────────────────

  static Future<void> addFeedback(Map<String, dynamic> data) =>
      _db.collection(kColFeedbacks).add(data).then((_) {});

  static Stream<QuerySnapshot> watchFeedbacks() =>
      _db.collection(kColFeedbacks).orderBy('date', descending: true).snapshots();
}
