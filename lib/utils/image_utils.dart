import 'dart:io';

import 'package:flutter/material.dart';

bool _isNetwork(String path) {
  final p = path.toLowerCase();
  return p.startsWith('http://') || p.startsWith('https://');
}

/// Returns an image widget that displays a network image when `path` is a URL,
/// or a local file image otherwise. `errorBuilder` is used for graceful fallback.
Widget imageFromPath(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
  Widget? errorPlaceholder,
}) {
  final placeholder = errorPlaceholder ??
      Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      );

  if (_isNetwork(path)) {
    return Image.network(
      path,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (ctx, err, stack) => placeholder,
    );
  }

  return Image.file(
    File(path),
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (ctx, err, stack) => placeholder,
  );
}
