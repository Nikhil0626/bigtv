import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/translated_text.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class BulletinView extends StatefulWidget {
  final Map<String, dynamic> article;

  const BulletinView({super.key, required this.article});

  @override
  State<BulletinView> createState() => _BulletinViewState();
}

class _BulletinViewState extends State<BulletinView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _startAutoFlipTimer();
  }

  List<String> _getPoints() {
    final List<String> points = [];

    // Check bulletPoints list
    if (widget.article['bulletPoints'] is List &&
        (widget.article['bulletPoints'] as List).isNotEmpty) {
      for (var item in widget.article['bulletPoints']) {
        final str = item.toString().trim();
        if (str.isNotEmpty) {
          points.add(str);
        }
      }
    }

    // If no bullet points, check content split by lines
    if (points.isEmpty &&
        widget.article['content'] != null &&
        widget.article['content'].toString().trim().isNotEmpty) {
      final lines = widget.article['content'].toString().split('\n');
      for (var line in lines) {
        final str = line.trim();
        if (str.isNotEmpty) {
          points.add(str);
        }
      }
    }

    // Fallback to title
    if (points.isEmpty &&
        widget.article['title'] != null &&
        widget.article['title'].toString().trim().isNotEmpty) {
      points.add(widget.article['title'].toString().trim());
    }

    return points;
  }

  void _startAutoFlipTimer() {
    _timer?.cancel();
    final points = _getPoints();
    if (points.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        _flipCard();
      });
    }
  }

  Future<void> _flipCard({bool forward = true}) async {
    if (_controller.isAnimating) return;

    final points = _getPoints();
    if (points.length <= 1) return;

    await _controller.forward(from: 0);

    if (!mounted) return;

    setState(() {
      if (forward) {
        _currentIndex = (_currentIndex + 1) % points.length;
      } else {
        _currentIndex = (_currentIndex - 1 + points.length) % points.length;
      }
    });

    _controller.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPointCard(
    BuildContext context,
    String pointText,
    int index,
    int totalPoints,
    String title,
  ) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: TranslatedText(
            pointText,
            translate: context.watch<HomeProvider>().isEnglishMode,
            textAlign: TextAlign.center,
            style: homeScreenFontStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ).copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = _getPoints();
    final title = widget.article['title']?.toString() ?? '';

    String imageUrl = widget.article['image_url']?.toString() ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = "https://admin.pravasamedia.com$imageUrl";
    }

    return GestureDetector(
      onTap: () {
        if (points.length > 1) {
          _startAutoFlipTimer();
          _flipCard();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            // 1. Background Image (defaults to evening_bulletins_bg.jpg)
            Positioned.fill(
              child: (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/evening_bulletins_bg.jpg',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/evening_bulletins_bg.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/evening_bulletins_bg.jpg',
                      fit: BoxFit.cover,
                    ),
            ),

            // 2. Dark Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 3. Top Title Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 70.h,
              left: 20.w,
              right: 20.w,
              child: title.isNotEmpty
                  ? Center(
                      child: TranslatedText(
                        title,
                        translate: context.watch<HomeProvider>().isEnglishMode,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: homeScreenFontStyle(
                          color: const Color(0xFFFFD700),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // 4. Centered Flipping Card Content
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final isFront = _controller.value < 0.5;
                  final angle = _controller.value * math.pi;
                  final activeIndex = isFront
                      ? _currentIndex
                      : (_currentIndex + 1) % (points.isEmpty ? 1 : points.length);

                  final currentText = points.isNotEmpty
                      ? points[activeIndex]
                      : title;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: isFront
                        ? _buildPointCard(
                            context,
                            currentText,
                            activeIndex,
                            points.length,
                            title,
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildPointCard(
                              context,
                              currentText,
                              activeIndex,
                              points.length,
                              title,
                            ),
                          ),
                  );
                },
              ),
            ),

            // 5. Bottom Left Indicators
            if (points.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 60.h,
                left: 24.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: points.asMap().entries.map((entry) {
                    final isActive = _currentIndex == entry.key;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 14.w : 5.w,
                      height: 4.h,
                      margin: EdgeInsets.only(right: 4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.r),
                        color: isActive
                            ? const Color(0xFFED1C24)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
