import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/translated_text.dart';

class BulletinView extends StatefulWidget {
  final Map<String, dynamic> article;

  const BulletinView({super.key, required this.article});

  @override
  State<BulletinView> createState() => _BulletinViewState();
}

class _BulletinViewState extends State<BulletinView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    final points = _getPoints();
    final totalMs = (points.length * 450).clamp(1000, 5000);
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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

  Widget _buildLiveBadge({required bool isTopItem, required bool isDark}) {
    final redColor = const Color(0xFFFF0033);
    final bgColor = isTopItem
        ? (isDark ? const Color(0xFF4A191D) : const Color(0xFFFFE5E8))
        : (isDark ? const Color(0xFF331D20) : const Color(0xFFFFF0F2));

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
              boxShadow: isTopItem
                  ? [
                      BoxShadow(
                        color: redColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'LIVE',
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
        ? (isDark ? const Color(0xFF241517) : const Color(0xFFFFF0F2))
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    final borderColor = isTop
        ? (isDark ? Colors.red.shade900.withValues(alpha: 0.6) : const Color(0xFFFFC2C8))
        : (isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0));

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: borderColor,
          width: isTop ? 1.4 : 1.0,
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
                  color: const Color(0xFFFF0033),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(isTop ? 14.w : 12.w, 12.h, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLiveBadge(isTopItem: isTop, isDark: isDark),
                  ],
                ),
                SizedBox(height: 8.h),
                TranslatedText(
                  text,
                  translate: context.watch<HomeProvider>().isEnglishMode,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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
      color: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: "Live bulletin" | "LATEST FIRST"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live bulletin',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'LATEST FIRST',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Sequential Left-Slide Entrance Animation for Cards
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: points.length,
                  itemBuilder: (context, index) {
                    final int count = points.length;
                    final double step = 1.0 / count;
                    final double start = (index * step).clamp(0.0, 1.0 - step);
                    final double end = ((index + 1) * step).clamp(start + 0.01, 1.0);

                    final Animation<double> opacityAnim = CurvedAnimation(
                      parent: _animController,
                      curve: Interval(start, end, curve: Curves.easeIn),
                    );

                    final Animation<Offset> slideAnim = Tween<Offset>(
                      begin: const Offset(-1.2, 0.0), // Offscreen Left
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animController,
                      curve: Interval(start, end, curve: Curves.easeOutCubic),
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
            ],
          ),
        ),
      ),
    );
  }
}
