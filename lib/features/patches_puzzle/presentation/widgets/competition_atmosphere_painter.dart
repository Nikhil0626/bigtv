import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated competition atmosphere painter that renders drifting
/// championship sparks, energy embers, and glowing stadium aura.
class CompetitionAtmospherePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  CompetitionAtmospherePainter({
    required this.animation,
    this.isDark = true,
  }) : super(repaint: animation);

  static final List<_ParticleData> _particles = [
    _ParticleData(xRatio: 0.12, yRatio: 0.18, radius: 2.8, color: const Color(0xFFFFD700)),
    _ParticleData(xRatio: 0.88, yRatio: 0.28, radius: 2.2, color: const Color(0xFFFF9100)),
    _ParticleData(xRatio: 0.25, yRatio: 0.45, radius: 3.2, color: const Color(0xFFFF3D00)),
    _ParticleData(xRatio: 0.82, yRatio: 0.62, radius: 2.5, color: const Color(0xFFFFD700)),
    _ParticleData(xRatio: 0.15, yRatio: 0.72, radius: 3.0, color: const Color(0xFF00E5FF)),
    _ParticleData(xRatio: 0.75, yRatio: 0.85, radius: 2.4, color: const Color(0xFFFFD700)),
    _ParticleData(xRatio: 0.40, yRatio: 0.22, radius: 2.0, color: const Color(0xFFFF6D00)),
    _ParticleData(xRatio: 0.65, yRatio: 0.50, radius: 2.6, color: const Color(0xFFFFD700)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    // 1. Subtle Competition Arena Glow at Top-Center and Bottom
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFFE50914).withValues(alpha: 0.08),
                const Color(0xFFFF9800).withValues(alpha: 0.04),
                Colors.transparent,
              ]
            : [
                const Color(0xFFFFE0B2).withValues(alpha: 0.35),
                const Color(0xFFFFCDD2).withValues(alpha: 0.15),
                Colors.transparent,
              ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.2),
        radius: size.width * 0.65,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), centerGlow);

    // 2. Animated floating tournament sparks & glowing stars
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      // Vertical gentle upward drift
      final driftY = (p.yRatio - (t * 0.15) - (i * 0.08)) % 1.0;
      final y = driftY * size.height;
      // Slight horizontal sine oscillation
      final swing = math.sin((t * 2 * math.pi) + (i * 1.2)) * 14.0;
      final x = (p.xRatio * size.width) + swing;

      // Pulse opacity
      final pulse = (0.5 + 0.5 * math.sin((t * 2 * math.pi * 1.5) + (i * 0.9))).clamp(0.2, 1.0);
      final alpha = isDark ? (0.65 * pulse) : (0.45 * pulse);

      // Glowing aura
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawCircle(Offset(x, y), p.radius * 2.2, glowPaint);

      // Core spark
      final corePaint = Paint()
        ..color = (isDark ? Colors.white : p.color).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), p.radius, corePaint);

      // Star cross sparkle for larger particles
      if (p.radius >= 2.8) {
        final crossPaint = Paint()
          ..color = p.color.withValues(alpha: alpha * 0.8)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;
        final arm = p.radius * 2.0;
        canvas.drawLine(Offset(x - arm, y), Offset(x + arm, y), crossPaint);
        canvas.drawLine(Offset(x, y - arm), Offset(x, y + arm), crossPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CompetitionAtmospherePainter oldDelegate) => true;
}

class _ParticleData {
  final double xRatio;
  final double yRatio;
  final double radius;
  final Color color;

  const _ParticleData({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.color,
  });
}
