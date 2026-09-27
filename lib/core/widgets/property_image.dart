import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Renders a listing photo wherever it lives.
///
/// `Property.imageUrl` accepts either a local asset path (the mock fixtures
/// ship the design kit's photos) or a remote URL — this widget picks the right
/// renderer and gives both the same placeholder/error treatment, so cards
/// never flash an empty box and widget tests never touch the network.
class PropertyImage extends StatelessWidget {
  const PropertyImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorIconSize = 40,
  });

  /// Asset path (`assets/...`) or remote URL.
  final String imageUrl;

  final BoxFit fit;

  /// Size of the fallback glyph shown when the image cannot be loaded.
  final double errorIconSize;

  bool get _isAsset => imageUrl.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (_isAsset) {
      return Image.asset(
        imageUrl,
        fit: fit,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _fallback,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      placeholder: (_, __) => const ColoredBox(color: AppColors.gray100),
      errorWidget: (_, __, ___) => _fallback,
    );
  }

  Widget get _fallback => ColoredBox(
        color: AppColors.gray100,
        child: Icon(
          Icons.home_work_outlined,
          size: errorIconSize,
          color: AppColors.textMuted,
        ),
      );
}
