import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-performance widget that provides a smooth, elegant 3D floating animation:
/// - Pure continuous floating & levitation physics
/// - Maintains 100% original icon colors and brightness (no lighter/darker sheen or tint)
/// - Organic staggered phase offset across sibling icons
/// - Smooth tactile touch response
class Lottie3DIcon extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final int index;
  final Color? shadowColor;
  final bool enableFloating;
  final Widget? fallback;
  final VoidCallback? onTap;

  const Lottie3DIcon({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.index = 0,
    this.shadowColor,
    this.enableFloating = true,
    this.fallback,
    this.onTap,
  });

  @override
  State<Lottie3DIcon> createState() => _Lottie3DIconState();
}

class _Lottie3DIconState extends State<Lottie3DIcon>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();

    // 1. Smooth Floating Loop (2.8s cycle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Stagger phase based on index so sibling icons float naturally
    final double initialPhase = ((widget.index * 0.18) % 1.0);
    _floatController.value = initialPhase;
    if (widget.enableFloating) {
      _floatController.repeat(reverse: true);
    }

    // 2. Tactile Spring Press Controller
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    _pressController.forward();
  }

  void _onPointerUp(PointerUpEvent _) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _onPointerCancel(PointerCancelEvent _) {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.onTap != null ? _onPointerDown : null,
      onPointerUp: widget.onTap != null ? _onPointerUp : null,
      onPointerCancel: widget.onTap != null ? _onPointerCancel : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatController,
          _pressController,
        ]),
        builder: (context, child) {
          // --- Pure Floating Physics (Constant Brightness & Color) ---
          final floatVal = _floatController.value;
          // Smooth sine curve for natural levitation
          final double floatOffset = widget.enableFloating
              ? -math.sin(floatVal * math.pi) * 3.5
              : 0.0;
          final double tiltAngle = widget.enableFloating
              ? math.sin(floatVal * math.pi * 2) * 0.02
              : 0.0;

          // --- Spring Touch Scaling ---
          final double pressScale = 1.0 - (_pressController.value * 0.12);

          final Widget iconWidget = Image.asset(
            widget.imagePath,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                widget.fallback ?? const SizedBox.shrink(),
          );

          final Widget animatedContent = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0.0, floatOffset, 0.0)
              ..rotateZ(tiltAngle)
              ..scale(pressScale),
            child: iconWidget,
          );

          if (widget.shadowColor != null) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Subtle static floor shadow (clean and steady)
                  Positioned(
                    bottom: 0.0,
                    child: Container(
                      width: widget.width * 0.55,
                      height: 4.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(widget.width * 0.3, 2.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.shadowColor!.withValues(alpha: 0.30),
                            blurRadius: 8.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  animatedContent,
                ],
              ),
            );
          }

          return animatedContent;
        },
      ),
    );
  }
}
