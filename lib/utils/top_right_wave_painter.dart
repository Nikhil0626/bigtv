import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopRightWavePainter extends CustomPainter {
  final bool isDark;
  final double gap;
  final double baseRadius;
  final double maxRadius;
  final double strokeWidth;

  const TopRightWavePainter({
    this.isDark = false,
    this.gap = 22.0,
    this.baseRadius = 30.0,
    this.maxRadius = 380.0,
    this.strokeWidth = 1.15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.95, -size.height * 0.05);

    // Rich background radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
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
    final int count = ((maxRadius - baseRadius) / safeGap).floor() + 1;

    for (int i = 0; i < count; i++) {
      final double r = baseRadius + (i * safeGap);
      final double progress = count > 1 ? i / (count - 1) : 0.0;
      final double baseOpacity = 0.44 * (1.0 - progress * 0.90);
      final double opacity = (isDark ? baseOpacity * 0.75 : baseOpacity).clamp(0.02, 0.44);

      final linePaint = Paint()
        ..color = const Color(0xFFED1C24).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, r, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TopRightWavePainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.gap != gap ||
      oldDelegate.baseRadius != baseRadius ||
      oldDelegate.maxRadius != maxRadius ||
      oldDelegate.strokeWidth != strokeWidth;
}

Widget buildSettingsPageHeader(BuildContext context, String title) {
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    ),
  );
}
