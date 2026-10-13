import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopRightWavePainter extends CustomPainter {
  final bool isDark;
  final bool isRedHeader;
  final double gap;
  final double baseRadius;
  final double maxRadius;
  final double strokeWidth;
  final Animation<double>? waveAnimation;

  TopRightWavePainter({
    this.isDark = false,
    this.isRedHeader = false,
    this.gap = 22.0,
    this.baseRadius = 30.0,
    this.maxRadius = 380.0,
    this.strokeWidth = 1.15,
    this.waveAnimation,
  }) : super(repaint: waveAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.95, -size.height * 0.05);
    final double animValue = waveAnimation?.value ?? 0.0;

    // Rich background radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: isRedHeader
            ? [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.04),
                Colors.transparent,
              ]
            : isDark
                ? [
                    const Color(0xFF420D11).withValues(alpha: 0.85),
                    const Color(0xFF2B090C).withValues(alpha: 0.55),
                    const Color(0xFF190608).withValues(alpha: 0.25),
                    Colors.transparent,
                  ]
                : [
                    const Color(0xFFFFBDBD).withValues(alpha: 0.95),
                    const Color(0xFFFFDEDE).withValues(alpha: 0.75),
                    const Color(0xFFFFF0F0).withValues(alpha: 0.40),
                    Colors.white.withValues(alpha: 0.0),
                  ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, glowPaint);

    // Concentric wave ripple lines with balanced spacing (~22px gap)
    final double safeGap = gap > 0 ? gap : 22.0;
    final int count = ((maxRadius - baseRadius) / safeGap).floor() + 2;

    for (int i = 0; i < count; i++) {
      final double r = baseRadius + ((i + animValue) * safeGap);
      if (r > maxRadius) continue;

      final double progress = ((r - baseRadius) / (maxRadius - baseRadius)).clamp(0.0, 1.0);
      
      // Smooth fade-in at base and fade-out at outer edge for seamless infinite loop
      final double fadeIn = (progress / 0.08).clamp(0.0, 1.0);
      final double fadeOut = (1.0 - progress);
      final double baseOpacity = 0.48 * fadeIn * fadeOut;
      final double opacity = (isDark ? baseOpacity * 0.75 : baseOpacity).clamp(0.0, 0.48);

      if (opacity <= 0.005) continue;

      final linePaint = Paint()
        ..color = isRedHeader
            ? Colors.white.withValues(alpha: opacity * 0.7)
            : const Color(0xFFED1C24).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, r, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TopRightWavePainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.isRedHeader != isRedHeader ||
      oldDelegate.gap != gap ||
      oldDelegate.baseRadius != baseRadius ||
      oldDelegate.maxRadius != maxRadius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.waveAnimation != waveAnimation;
}

Widget buildSettingsPageHeader(BuildContext context, String title) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2026) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    ),
  );
}
