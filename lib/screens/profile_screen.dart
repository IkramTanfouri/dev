// lib/screens/profile_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import '../core/services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _saving = false;
  bool _loading = true;

  String _nom = '';
  String _email = '';
  String _phone = '';
  String _dob = '';
  String _avatarUrl = '';

  // For display while uploading
  File? _pickedFile;
  Uint8List? _pickedBytes;

  late TextEditingController _nomCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;
    final data = await FirebaseService.getUserData(uid);
    if (!mounted) return;
    setState(() {
      _nom = data?['nom'] ?? '';
      _email = data?['email'] ?? '';
      _phone = data?['phone'] ?? '';
      _dob = data?['dob'] ?? '';
      _avatarUrl = data?['avatar'] ?? '';
      _nomCtrl.text = _nom;
      _emailCtrl.text = _email;
      _phoneCtrl.text = _phone;
      _dobCtrl.text = _dob;
      _loading = false;
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() => _pickedBytes = bytes);
    } else {
      setState(() => _pickedFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      String? newAvatarUrl;

      // Upload avatar if a new image was selected
      if (kIsWeb && _pickedBytes != null) {
        newAvatarUrl = await CloudinaryService.uploadBytes(
          _pickedBytes!,
          folder: 'my_barista/avatars',
          fileName: '$uid.jpg',
        );
      } else if (!kIsWeb && _pickedFile != null) {
        newAvatarUrl = await CloudinaryService.uploadFile(
          _pickedFile!,
          folder: 'my_barista/avatars',
        );
      }

      final updates = <String, dynamic>{
        'nom': _nomCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'dob': _dobCtrl.text.trim(),
      };

      // Only update avatar field when a new URL was successfully obtained
      if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
        updates['avatar'] = newAvatarUrl;
      }

      await FirebaseService.updateUserData(uid, updates);

      if (!mounted) return;
      setState(() {
        _nom = updates['nom'] as String;
        _email = updates['email'] as String;
        _phone = updates['phone'] as String;
        _dob = updates['dob'] as String;
        if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
          _avatarUrl = newAvatarUrl;
        }
        _pickedFile = null;
        _pickedBytes = null;
        _editing = false;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour',
              style: TextStyle(fontFamily: 'LeagueSpartan')),
          backgroundColor: kBrown,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e',
              style: const TextStyle(fontFamily: 'LeagueSpartan')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: kBrown, strokeWidth: 2));
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mon Profil',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                if (!_editing)
                  TextButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit, color: kBrown, size: 18),
                    label: const Text('Modifier',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            color: kBrown,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _avatarWidget(),
            const SizedBox(height: 24),
            if (!_editing) ...
              [
                _infoRow(Icons.person_outline, 'Nom', _nom),
                _infoRow(Icons.email_outlined, 'Email', _email),
                _infoRow(Icons.phone_outlined, 'Téléphone',
                    _phone.isEmpty ? '—' : _phone),
                _infoRow(Icons.cake_outlined, 'Date de naissance',
                    _dob.isEmpty ? '—' : _dob),
              ]
            else ...
              [
                _field('Nom', _nomCtrl),
                const SizedBox(height: 12),
                _field('Email', _emailCtrl,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field('Téléphone', _phoneCtrl,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _field('Date de naissance (jj/mm/aaaa)', _dobCtrl),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() {
                                  _editing = false;
                                  _pickedFile = null;
                                  _pickedBytes = null;
                                  _nomCtrl.text = _nom;
                                  _emailCtrl.text = _email;
                                  _phoneCtrl.text = _phone;
                                  _dobCtrl.text = _dob;
                                }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kBrown,
                          side: const BorderSide(color: kBrown),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrown,
                          foregroundColor: kWhite,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: kWhite, strokeWidth: 2))
                            : const Text('Enregistrer',
                                style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _avatarWidget() {
    Widget image;

    if (_pickedBytes != null) {
      image = CircleAvatar(
          radius: 52, backgroundImage: MemoryImage(_pickedBytes!));
    } else if (_pickedFile != null) {
      image = CircleAvatar(
          radius: 52, backgroundImage: FileImage(_pickedFile!));
    } else if (_avatarUrl.isNotEmpty) {
      image = CircleAvatar(
        radius: 52,
        backgroundImage:
            NetworkImage(_avatarUrl),
        key: ValueKey(_avatarUrl),
      );
    } else {
      image = CircleAvatar(
        radius: 52,
        backgroundColor: kInputBg,
        child: Text(
          _nom.isNotEmpty ? _nom[0].toUpperCase() : '?',
          style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: kBrown),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        image,
        if (_editing)
          GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: kBrown, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt,
                  color: kWhite, size: 18),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: kInputBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: kBrown, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 11,
                      color: kBrown.withOpacity(0.6))),
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kBrown)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kBrown)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown),
          decoration: InputDecoration(
            filled: true,
            fillColor: kInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
