// lib/screens/manager/manager_add_edit_plat_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/models/plat.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/services/service_locator.dart';

class ManagerAddEditPlatScreen extends StatefulWidget {
  final Plat? plat;
  const ManagerAddEditPlatScreen({super.key, this.plat});

  @override
  State<ManagerAddEditPlatScreen> createState() =>
      _ManagerAddEditPlatScreenState();
}

class _ManagerAddEditPlatScreenState extends State<ManagerAddEditPlatScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  String _category    = 'hot_drinks';
  bool   _isBestSeller = false;
  bool   _saving       = false;

  String    _imageUrl   = '';
  File?     _pickedFile;
  Uint8List? _pickedBytes;

  static const List<Map<String, String>> _categories = [
    {'key': 'hot_drinks',  'label': 'Hot Drinks'},
    {'key': 'cold_drinks', 'label': 'Cold Drinks'},
    {'key': 'sweet',       'label': 'Sweet'},
    {'key': 'savory',      'label': 'Savory'},
  ];

  bool get _isEdit => widget.plat != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.plat?.name  ?? '');
    _priceCtrl = TextEditingController(
        text: widget.plat != null ? widget.plat!.price.toStringAsFixed(0) : '');
    _descCtrl  = TextEditingController(text: widget.plat?.description ?? '');
    _category     = widget.plat?.category    ?? 'hot_drinks';
    _isBestSeller = widget.plat?.isBestSeller ?? false;
    _imageUrl     = widget.plat?.image        ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() { _pickedBytes = bytes; _pickedFile = null; });
    } else {
      setState(() { _pickedFile = File(picked.path); _pickedBytes = null; });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Remplissez nom et prix',
              style: TextStyle(fontFamily: 'LeagueSpartan'))));
      return;
    }

    setState(() => _saving = true);
    try {
      String finalImage = _imageUrl;

      if (kIsWeb && _pickedBytes != null) {
        final url = await CloudinaryService.uploadBytes(
          _pickedBytes!, folder: 'my_barista/plats',
          fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        if (url != null) finalImage = url;
      } else if (!kIsWeb && _pickedFile != null) {
        final url = await CloudinaryService.uploadFile(
            _pickedFile!, folder: 'my_barista/plats');
        if (url != null) finalImage = url;
      }

      if (finalImage.isEmpty) finalImage = Plat.defaultImageFor(_category);

      if (_isEdit) {
        platService.update(
          id:           widget.plat!.id,
          name:         _nameCtrl.text.trim(),
          price:        double.tryParse(_priceCtrl.text.trim()) ?? 0,
          category:     _category,
          image:        finalImage,
          description:  _descCtrl.text.trim(),
          isBestSeller: _isBestSeller,
        );
      } else {
        platService.add(
          name:         _nameCtrl.text.trim(),
          price:        double.tryParse(_priceCtrl.text.trim()) ?? 0,
          category:     _category,
          image:        finalImage,
          description:  _descCtrl.text.trim(),
          isBestSeller: _isBestSeller,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
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
        title: Text(_isEdit ? 'Modifier le plat' : 'Nouveau plat',
            style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kBrown)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBrown.withOpacity(0.3), width: 1.5),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Appuyer pour changer l\'image',
                style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 12, color: kGrey))),
            const SizedBox(height: 24),
            _label('Nom'),
            _field(_nameCtrl, 'Ex: Cappuccino'),
            const SizedBox(height: 16),
            _label('Description'),
            _field(_descCtrl, 'Café, lait et noisette'),
            const SizedBox(height: 16),
            _label('Catégorie'),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(
                value: c['key'],
                child: Text(c['label']!,
                    style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown)),
              )).toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: InputDecoration(
                filled: true, fillColor: kInputBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown),
              dropdownColor: kBg,
            ),
            const SizedBox(height: 16),
            _label('Prix'),
            _field(_priceCtrl, '11.500', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Best Seller',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      fontSize: 15, fontWeight: FontWeight.w600, color: kBrown)),
              value: _isBestSeller,
              activeColor: kBrown,
              onChanged: (v) => setState(() => _isBestSeller = v),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrown, foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: kWhite, strokeWidth: 2)
                    : Text(_isEdit ? 'Enregistrer' : 'Ajouter',
                        style: const TextStyle(fontFamily: 'LeagueSpartan',
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedBytes != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(14),
          child: Image.memory(_pickedBytes!, fit: BoxFit.cover));
    }
    if (_pickedFile != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(14),
          child: Image.file(_pickedFile!, fit: BoxFit.cover));
    }
    if (_imageUrl.startsWith('http')) {
      return ClipRRect(borderRadius: BorderRadius.circular(14),
          child: Image.network(_imageUrl, fit: BoxFit.cover, key: ValueKey(_imageUrl)));
    }
    if (_imageUrl.isNotEmpty) {
      return ClipRRect(borderRadius: BorderRadius.circular(14),
          child: Image.asset(_imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.add_photo_alternate, color: kBrown, size: 40)));
    }
    return const Icon(Icons.add_photo_alternate, color: kBrown, size: 40);
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontFamily: 'LeagueSpartan',
            fontSize: 14, fontWeight: FontWeight.w600, color: kBrown)),
      );

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'LeagueSpartan', color: kBrown),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kBrown.withOpacity(0.4)),
        filled: true, fillColor: kInputBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
