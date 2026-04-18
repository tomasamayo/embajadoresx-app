import 'package:flutter/material.dart';

class ExRemoteImage extends StatelessWidget {
  const ExRemoteImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  String? get _normalizedUrl {
    final String raw = imageUrl.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }

    if (raw.startsWith('//')) {
      return 'https:$raw';
    }

    final Uri? uri = Uri.tryParse(raw);
    if (uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return raw;
    }

    if (raw.startsWith('/')) {
      return 'https://embajadoresx.com$raw';
    }

    if (raw.startsWith('assets/') || raw.startsWith('uploads/')) {
      return 'https://embajadoresx.com/$raw';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = fallback ??
        Container(
          color: Colors.white.withValues(alpha: 0.04),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white30,
              size: 28,
            ),
          ),
        );

    final String? resolvedUrl = _normalizedUrl;

    final Widget child = resolvedUrl != null
        ? Image.network(
            resolvedUrl,
            fit: fit,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            errorBuilder: (_, __, ___) => placeholder,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }
              return placeholder;
            },
          )
        : placeholder;

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }
}
