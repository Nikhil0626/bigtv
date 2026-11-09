import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Micro-interaction widget showing an index finger hand tapping with an animated ripple wave.
/// Supports a fixed number of taps [maxTaps] (default 3) with a customizable delay [tapDelay] between taps,
/// after which it smoothly fades out and disappears.
class LinkTapAnimationWidget extends StatefulWidget {
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final int maxTaps; // 0 for infinite, default 3
  final Duration tapDelay; // Delay between taps, default 550ms
  final VoidCallback? onFinished;

  const LinkTapAnimationWidget({
    super.key,
    this.size = 30,
    this.color = const Color(0xFFE50914),
    this.onTap,
    this.maxTaps = 3,
    this.tapDelay = const Duration(milliseconds: 550),
    this.onFinished,
  });

  @override
  State<LinkTapAnimationWidget> createState() => _LinkTapAnimationWidgetState();
}

class _LinkTapAnimationWidgetState extends State<LinkTapAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _completedTaps = 0;
  bool _isFading = false;
  bool _isDisappeared = false;
  Timer? _delayTimer;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completedTaps++;
        if (widget.maxTaps > 0 && _completedTaps >= widget.maxTaps) {
          if (mounted) {
            setState(() {
              _isFading = true;
            });
          }
          _fadeTimer = Timer(const Duration(milliseconds: 350), () {
            if (mounted) {
              setState(() {
                _isDisappeared = true;
              });
              widget.onFinished?.call();
            }
          });
          _controller.stop();
        } else {
          // Pause / delay between taps before starting the next tap
          _delayTimer = Timer(widget.tapDelay, () {
            if (mounted && !_isDisappeared) {
              _controller.forward(from: 0.0);
            }
          });
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _fadeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisappeared) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: _isFading ? 0.0 : 1.0,
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            // Tapping motion: at rest (0.0) -> peak down press at 0.5 (1.0) -> back to rest at 1.0 (0.0)
            final double tapProgress = math.sin(progress * math.pi);
            final double handScale = 1.0 - (0.16 * tapProgress);
            final double handRotation = -0.12 + (0.12 * tapProgress);
            final double translateY = 5.0 * tapProgress;

            // Ripple effect expands outward when hand presses down (progress 0.35 to 0.9)
            final double rippleProgress = ((progress - 0.35) / 0.55).clamp(0.0, 1.0);
            final double rippleScale = 0.4 + (1.3 * rippleProgress);
            final double rippleOpacity = (1.0 - rippleProgress) * (progress >= 0.35 && progress <= 0.95 ? 0.75 : 0.0);

            return SizedBox(
              width: widget.size * 1.5,
              height: widget.size * 1.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Expanding tap ripple wave circle
                  if (rippleOpacity > 0.02)
                    Transform.scale(
                      scale: rippleScale,
                      child: Container(
                        width: widget.size * 0.9,
                        height: widget.size * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.color.withValues(alpha: rippleOpacity),
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),

                  // Animated tapping hand icon
                  Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.rotate(
                      angle: handRotation,
                      child: Transform.scale(
                        scale: handScale,
                        child: Icon(
                          Icons.touch_app_rounded,
                          size: widget.size,
                          color: widget.color,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.38),
                              blurRadius: 5,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Hyperlink widget for news text displaying clean blue text with a Stack overlay
/// hand tapping animation centered on the link text that plays 3 taps with delay whenever
/// the user comes to this post, then smoothly disappears.
class HyperlinkWithTapAnimation extends StatefulWidget {
  final String text;
  final String url;
  final TextStyle style;
  final VoidCallback onTap;
  final bool isDark;
  final bool isActive;

  const HyperlinkWithTapAnimation({
    super.key,
    required this.text,
    required this.url,
    required this.style,
    required this.onTap,
    this.isDark = false,
    this.isActive = true,
  });

  @override
  State<HyperlinkWithTapAnimation> createState() => _HyperlinkWithTapAnimationState();
}

class _HyperlinkWithTapAnimationState extends State<HyperlinkWithTapAnimation> {
  bool _handDisappeared = false;
  Key _animationKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _handDisappeared = !widget.isActive;
  }

  @override
  void didUpdateWidget(covariant HyperlinkWithTapAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When user comes to this post (isActive changes from false to true)
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _handDisappeared = false;
        _animationKey = UniqueKey(); // Re-instantiate LinkTapAnimationWidget to play afresh
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      // When user leaves this post
      setState(() {
        _handDisappeared = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkColor = widget.isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final cleanText = widget.text.replaceAll('[', '').replaceAll(']', '').trim();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Clean hyperlink: plain blue text without brackets or underline
        GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Text(
              cleanText,
              style: widget.style.copyWith(
                color: linkColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Hand tapping animation centered on the stack overlay of the link text
        if (!_handDisappeared && widget.isActive)
          Positioned(
            key: _animationKey,
            top: -18.h,
            left: 0,
            right: 0,
            child: Center(
              child: LinkTapAnimationWidget(
                size: 30.sp,
                color: const Color(0xFFE50914),
                maxTaps: 3,
                tapDelay: const Duration(milliseconds: 550),
                onTap: widget.onTap,
                onFinished: () {
                  if (mounted) {
                    setState(() {
                      _handDisappeared = true;
                    });
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}
