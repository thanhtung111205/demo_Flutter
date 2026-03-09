import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Simple Cloudinary uploader using unsigned upload preset.
class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({required this.cloudName, required this.uploadPreset});

  /// Upload a file to Cloudinary and return the secure URL on success.
  Future<String> uploadFile(File file) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;

    final multipartFile = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final url = body['secure_url'] as String?;
      if (url != null) return url;
      throw Exception('Cloudinary response missing secure_url');
    } else {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }
  }
}
