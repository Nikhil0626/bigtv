import 'package:flutter/material.dart';

/// Renders a subtle, non-intrusive watermark overlay on top of a completed game board
/// using the level's `logoUrl` (or falls back to the BigTV logo asset).
class GameWatermarkWidget extends StatelessWidget {
  final String? logoUrl;
  final double? size;
  final double opacity;
  final BoxFit fit;

  const GameWatermarkWidget({
    super.key,
    this.logoUrl,
    this.size,
    this.opacity = 0.55,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = (logoUrl != null && logoUrl!.trim().isNotEmpty)
        ? logoUrl!.trim()
        : null;

    final fallbackAsset = Image.asset(
      'assets/images/BigTvPostLogo.png',
      width: size,
      height: size,
      fit: fit,
    );

    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          opacity: opacity,
          child: cleanUrl != null
              ? Image.network(
                  cleanUrl,
                  width: size,
                  height: size,
                  fit: fit,
                  errorBuilder: (_, __, ___) => fallbackAsset,
                )
              : fallbackAsset,
        ),
      ),
    );
  }
}
