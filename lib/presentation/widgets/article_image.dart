import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius = 12,
    super.key,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null
          ? _placeholder(context)
          : CachedNetworkImage(
              imageUrl: url,
              height: height,
              width: width,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(context, loading: true),
              errorWidget: (_, __, ___) => _placeholder(context),
            ),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        loading ? Icons.hourglass_empty : Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
