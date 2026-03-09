import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/cloudinary_service.dart';

/// A small widget to pick a file and upload it to Cloudinary.
class CloudinaryUploadButton extends StatefulWidget {
  final CloudinaryService service;
  final void Function(String url)? onUploaded;
  final String label;

  const CloudinaryUploadButton({
    Key? key,
    required this.service,
    this.onUploaded,
    this.label = 'Upload file',
  }) : super(key: key);

  @override
  State<CloudinaryUploadButton> createState() => _CloudinaryUploadButtonState();
}

class _CloudinaryUploadButtonState extends State<CloudinaryUploadButton> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) return;

      final file = File(path);
      final url = await widget.service.uploadFile(file);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: $url')),
      );
      widget.onUploaded?.call(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _uploading ? null : _pickAndUpload,
      icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload),
      label: Text(_uploading ? 'Uploading...' : widget.label),
    );
  }
}
