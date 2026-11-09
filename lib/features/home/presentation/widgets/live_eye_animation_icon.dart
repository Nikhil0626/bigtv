import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A sleek, lightweight animated eye icon that blinks periodically
/// and pulses a subtle radar wave for real-time live viewership.
class LiveEyeAnimationIcon extends StatefulWidget {
  final double size;
  final Color color;
  final Color pupilColor;
  final bool showRipple;

  const LiveEyeAnimationIcon({
    super.key,
    this.size = 18.0,
    this.color = Colors.white,
    this.pupilColor = const Color(0xFFED1C24),
    this.showRipple = true,
  });

  @override
  State<LiveEyeAnimationIcon> createState() => _LiveEyeAnimationIconState();
}

class _LiveEyeAnimationIconState extends State<LiveEyeAnimationIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _blinkAnimation;
  late final Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Blink occurs between 80% and 95% of each 3-second cycle
    _blinkAnimation = TweenSequence<double>([
      // Fully open (0% - 80%)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 80,
      ),
      // Closing eyelid (80% - 87%)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.08)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 7,
      ),
      // Opening eyelid (87% - 94%)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 7,
      ),
      // Rest open (94% - 100%)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 6,
      ),
    ]).animate(_controller);

    // Radar ripple expands during the first 65% of cycle
    _rippleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 35,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.size * 1.45;
    final double height = widget.size;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(width, height),
            painter: _LiveEyePainter(
              blinkValue: _blinkAnimation.value,
              rippleValue: _rippleAnimation.value,
              color: widget.color,
              pupilColor: widget.pupilColor,
              showRipple: widget.showRipple,
            ),
          );
        },
      ),
    );
  }
}

class _LiveEyePainter extends CustomPainter {
  final double blinkValue;
  final double rippleValue;
  final Color color;
  final Color pupilColor;
  final bool showRipple;

  _LiveEyePainter({
    required this.blinkValue,
    required this.rippleValue,
    required this.color,
    required this.pupilColor,
    required this.showRipple,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    // 1. Radar wave expanding behind the eye
    if (showRipple && rippleValue > 0.0 && rippleValue < 1.0) {
      final double rippleRadius = (h * 0.55) + (rippleValue * (h * 0.45));
      final double rippleAlpha = (1.0 - rippleValue) * 0.45;
      final Paint ripplePaint = Paint()
        ..color = pupilColor.withValues(alpha: rippleAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }

    // 2. Eye shape path based on blink value
    final Path eyePath = Path();
    final double verticalSpread = (h * 0.48) * math.max(0.08, blinkValue);

    eyePath.moveTo(0, h / 2);
    // Upper eyelid curve
    eyePath.quadraticBezierTo(w / 2, h / 2 - verticalSpread, w, h / 2);
    // Lower eyelid curve
    eyePath.quadraticBezierTo(w / 2, h / 2 + verticalSpread, 0, h / 2);
    eyePath.close();

    // 3. Iris & Pupil (clipped inside eye shape)
    if (blinkValue > 0.18) {
      canvas.save();
      canvas.clipPath(eyePath);

      final double irisRadius = (h * 0.36) * (0.88 + 0.12 * blinkValue);

      // Outer Iris (white glow ring)
      final Paint irisPaint = Paint()
        ..color = color.withValues(alpha: 0.95)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, irisRadius, irisPaint);

      // Inner Pupil (red dot for LIVE accent)
      final Paint pupilPaint = Paint()
        ..color = pupilColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, irisRadius * 0.62, pupilPaint);

      // White reflection catchlight in pupil (gives alive shine)
      final Paint catchlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final Offset catchlightOffset = Offset(
        center.dx - (irisRadius * 0.28),
        center.dy - (irisRadius * 0.28),
      );
      canvas.drawCircle(catchlightOffset, irisRadius * 0.22, catchlightPaint);

      canvas.restore();
    }

    // 4. Outer Eyelid Stroke
    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, h * 0.085)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (blinkValue <= 0.12) {
      // Draw closed eye line
      final Path closedPath = Path();
      closedPath.moveTo(1, h / 2);
      closedPath.quadraticBezierTo(w / 2, h / 2 + 0.5, w - 1, h / 2);
      canvas.drawPath(closedPath, strokePaint);
    } else {
      canvas.drawPath(eyePath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiveEyePainter oldDelegate) {
    return oldDelegate.blinkValue != blinkValue ||
        oldDelegate.rippleValue != rippleValue ||
        oldDelegate.color != color ||
        oldDelegate.pupilColor != pupilColor;
  }
}

