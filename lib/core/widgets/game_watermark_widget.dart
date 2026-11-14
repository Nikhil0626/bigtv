import 'package:flutter/material.dart';

/// Renders a watermark/background overlay on top of a completed game board
/// ONLY when the API returns an image URL (`logoUrl`).
/// If no API image is returned (or if loading fails), renders nothing (no static fallback).
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

    // If static / no API image returned, remove completely
    if (cleanUrl == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          opacity: opacity,
          child: Image.network(
            cleanUrl,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
