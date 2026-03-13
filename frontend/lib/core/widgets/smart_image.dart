import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// A smart image widget that handles both base64 data URIs and network URLs.
/// Usage: SmartImage(imageUrl, fit: BoxFit.cover)
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const SmartImage(this.imageUrl, {super.key, this.fit = BoxFit.cover, this.errorBuilder});

  static bool isDataUri(String url) => url.startsWith('data:');

  static Uint8List decodeDataUri(String dataUri) {
    // Format: data:image/png;base64,iVBOR...
    final base64Str = dataUri.split(',').last;
    return base64Decode(base64Str);
  }

  static ImageProvider providerFor(String url) {
    if (isDataUri(url)) {
      return MemoryImage(decodeDataUri(url));
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final defaultError = errorBuilder ?? (_, __, ___) => Container(
      color: const Color(0xFF1E1E1E),
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 32)),
    );

    if (isDataUri(imageUrl)) {
      try {
        return Image.memory(decodeDataUri(imageUrl), fit: fit, errorBuilder: defaultError);
      } catch (_) {
        return defaultError(context, 'decode error', null);
      }
    }
    return Image.network(imageUrl, fit: fit, errorBuilder: defaultError);
  }
}
