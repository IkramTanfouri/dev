// lib/core/services/cloudinary_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String _cloudName = 'dme1fc8qw';
  static const String _uploadPreset = 'my_barista_preset';
  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // Upload from File (mobile)
  static Future<String?> uploadFile(
    File file, {
    String folder = 'my_barista/avatars',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      }
      debugPrint('Cloudinary upload error: $body');
      return null;
    } catch (e) {
      debugPrint('Cloudinary uploadFile exception: $e');
      return null;
    }
  }

  // Upload from Uint8List bytes (web)
  static Future<String?> uploadBytes(
    Uint8List bytes, {
    String folder = 'my_barista/avatars',
    String fileName = 'upload.jpg',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: fileName),
        );

      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      }
      debugPrint('Cloudinary upload error: $body');
      return null;
    } catch (e) {
      debugPrint('Cloudinary uploadBytes exception: $e');
      return null;
    }
  }
}
