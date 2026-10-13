import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:chotanews/utils/translated_text.dart';

class BulletinView extends StatefulWidget {
  final Map<String, dynamic> article;
  final PageController? pageController;

  const BulletinView({
    super.key,
    required this.article,
    this.pageController,
  });

  @override
  State<BulletinView> createState() => _BulletinViewState();
}

class _BulletinViewState extends State<BulletinView>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _waveController;
  bool _isTransitioning = false;
  double _overscrollAccumulator = 0;

  @override
  void initState() {
    super.initState();
    final points = _getPoints();
    final totalMs = (points.length * 1200).clamp(2500, 9000);
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
    _animController.forward();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _moveToNextPage() {
    if (_isTransitioning) return;
    final pageCtrl = widget.pageController ??
        (mounted ? context.read<HomeProvider>().pageController : null);
    if (pageCtrl == null || !pageCtrl.hasClients) return;

    final homeProvider = context.read<HomeProvider>();
    final cur = pageCtrl.page?.round() ?? homeProvider.currentPageIndex;
    if (cur + 1 < homeProvider.getAllPostList.length) {
      _isTransitioning = true;
      pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _isTransitioning = false;
              _overscrollAccumulator = 0;
            });
          }
        });
      });
    }
  }

  void _moveToPreviousPage() {
    if (_isTransitioning) return;
    final pageCtrl = widget.pageController ??
        (mounted ? context.read<HomeProvider>().pageController : null);
    if (pageCtrl == null || !pageCtrl.hasClients) return;

    final homeProvider = context.read<HomeProvider>();
    final cur = pageCtrl.page?.round() ?? homeProvider.currentPageIndex;
    if (cur > 0) {
      _isTransitioning = true;
      pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _isTransitioning = false;
              _overscrollAccumulator = 0;
            });
          }
        });
      });
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_isTransitioning) return false;

    if (notification is ScrollStartNotification) {
      _overscrollAccumulator = 0;
    } else if (notification is OverscrollNotification) {
      _overscrollAccumulator += notification.overscroll;
      if (_overscrollAccumulator > 20 &&
          notification.metrics.pixels >= notification.metrics.maxScrollExtent) {
        _moveToNextPage();
      } else if (_overscrollAccumulator < -20 &&
          notification.metrics.pixels <= notification.metrics.minScrollExtent) {
        _moveToPreviousPage();
      }
    } else if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null) {
        final delta = notification.dragDetails!.primaryDelta ?? 0;
        // User is at bottom and dragging up (negative delta)
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent && delta < -8) {
          _overscrollAccumulator += -delta;
          if (_overscrollAccumulator > 20) {
            _moveToNextPage();
          }
        }
        // User is at top and dragging down (positive delta)
        else if (notification.metrics.pixels <= notification.metrics.minScrollExtent && delta > 8) {
          _overscrollAccumulator -= delta;
          if (_overscrollAccumulator < -20) {
            _moveToPreviousPage();
          }
        }
      }
    } else if (notification is ScrollEndNotification) {
      _overscrollAccumulator = 0;
    }
    return false;
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

    // Check content split by newlines if bulletPoints is empty
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

  Widget _buildLiveBadge({required bool isTopItem, required bool isDark, required int index}) {
    final redColor = const Color(0xFFED1C24);
    final bgColor = isTopItem
        ? (isDark ? const Color(0xFF4A191D) : const Color(0xFFFFE5E8))
        : (isDark ? const Color(0xFF2A191C) : const Color(0xFFFFF0F2));

    final numStr = index < 9 ? "0${index + 1}" : "${index + 1}";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: redColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: redColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            isTopItem ? 'LIVE • LATEST' : 'UPDATE $numStr',
            style: TextStyle(
              color: redColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletinCard({
    required BuildContext context,
    required String text,
    required int index,
    required bool isDark,
  }) {
    final isTop = index == 0;

    final cardBg = isTop
        ? (isDark ? const Color(0xFF1E1416) : const Color(0xFFFFF7F8))
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    final borderColor = isTop
        ? (isDark ? const Color(0xFF5C1D24) : const Color(0xFFFFCDD2))
        : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEFEFF4));

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor,
          width: isTop ? 1.4 : 1.0,
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: const Color(0xFFED1C24).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Stack(
        children: [
          if (isTop)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFED1C24),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14.r),
                    bottomLeft: Radius.circular(14.r),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(isTop ? 16.w : 14.w, 14.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLiveBadge(isTopItem: isTop, isDark: isDark, index: index),
                  ],
                ),
                SizedBox(height: 8.h),
                TranslatedText(
                  text,
                  translate: context.watch<HomeProvider>().isEnglishMode,
                  style: TextStyle(
                    fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                    color: isDark ? Colors.white : const Color(0xFF181A20),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _getPoints();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
      child: Stack(
        children: [
          // 1. Base Gradient Canvas Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF180A0D),
                          const Color(0xFF0F0F12),
                          const Color(0xFF13090B),
                        ]
                      : [
                          const Color(0xFFFFF2F4),
                          const Color(0xFFFBFBFC),
                          const Color(0xFFFFF6F7),
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 2. Top-Right Wave Ripple Art (Self-moving wave animations)
          Positioned(
            top: 0,
            right: 0,
            width: MediaQuery.of(context).size.width,
            height: 480.h,
            child: CustomPaint(
              painter: TopRightWavePainter(
                isDark: isDark,
                maxRadius: 460.0,
                waveAnimation: _waveController,
              ),
            ),
          ),

          // 3. Bottom-Left Radiant Glow Orb
          Positioned(
            bottom: -60.h,
            left: -60.w,
            width: 280.w,
            height: 280.w,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [
                            const Color(0xFFED1C24).withValues(alpha: 0.16),
                            const Color(0xFFED1C24).withValues(alpha: 0.06),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFED1C24).withValues(alpha: 0.13),
                            const Color(0xFFFFDEDE).withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Floating Translucent Feedback / News Watermarks
          Positioned(
            bottom: 80.h,
            right: -30.w,
            child: IgnorePointer(
              child: Icon(
                Icons.star_rounded,
                size: 160.sp,
                color: const Color(0xFFED1C24).withValues(alpha: isDark ? 0.045 : 0.04),
              ),
            ),
          ),

          // Content Layer
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header Section (matching Image 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Live news\n",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF181A20),
                                  height: 1.15,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "bulletins.",
                                    style: TextStyle(
                                      color: Color(0xFFED1C24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Instant highlights & breaking stories.",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6C7278),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // 3D Live Bulletin Icon
                      Container(
                        width: 62.w,
                        height: 62.w,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF221114) : Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFED1C24).withValues(alpha: isDark ? 0.25 : 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? const Color(0xFF4A181D) : const Color(0xFFFFD9DC),
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              "assets/images/live_bulletin_3d_icon.png",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.campaign_rounded,
                                      size: 32,
                                      color: Color(0xFFED1C24),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFED1C24),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          "LIVE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Sequential Cards Section with Staggered Entrance Animation
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: points.length,
                        itemBuilder: (context, index) {
                          final int count = points.length;
                          final double staggerFactor = count > 1 ? 0.65 / (count - 1) : 0.0;
                          final double start = (index * staggerFactor).clamp(0.0, 0.7);
                          final double end = (start + 0.35).clamp(start + 0.01, 1.0);

                          final Animation<double> opacityAnim = CurvedAnimation(
                            parent: _animController,
                            curve: Interval(start, end, curve: Curves.easeOut),
                          );

                          final Animation<Offset> slideAnim = Tween<Offset>(
                            begin: const Offset(0.0, 0.25),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animController,
                            curve: Interval(start, end, curve: Curves.easeOutQuart),
                          ));

                          return AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              if (_animController.value < start) {
                                return const SizedBox.shrink();
                              }
                              return FadeTransition(
                                opacity: opacityAnim,
                                child: SlideTransition(
                                position: slideAnim,
                                child: _buildBulletinCard(
                                  context: context,
                                  text: points[index],
                                  index: index,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}
