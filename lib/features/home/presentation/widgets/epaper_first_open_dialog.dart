import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_detail_screen.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_screen.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';

const String kFirstOpenEpaperPopupShownKey = 'first_open_epaper_popup_shown';

/// Checks if the e-paper popup should be shown on app first open.
/// Only displays for Telugu users and only once per device/install.
Future<bool> shouldShowEpaperFirstOpenDialog() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final bool alreadyShown = prefs.getBool(kFirstOpenEpaperPopupShownKey) ?? false;
    if (alreadyShown) return false;

    final String langCode = prefs.getString("selectedLanguageCode") ??
        prefs.getString("selectedLanguage") ??
        "te";
    // Never show for Malayalam (e-papers are not available for Malayalam)
    if (langCode == 'ml') {
      return false;
    }
    return true;
  } catch (_) {
    return false;
  }
}

/// Helper function to display the dialog.
Future<void> showEpaperFirstOpenDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (BuildContext dialogContext) {
      return const EpaperFirstOpenDialog();
    },
  );
}

class EpaperFirstOpenDialog extends StatefulWidget {
  const EpaperFirstOpenDialog({super.key});

  @override
  State<EpaperFirstOpenDialog> createState() => _EpaperFirstOpenDialogState();
}

class _EpaperFirstOpenDialogState extends State<EpaperFirstOpenDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  String _selectedLanguage = 'te';
  bool _isOpeningEpaper = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _floatingAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.repeat(reverse: true);

    AnalyticsService.instance.track(
      AnalyticsEventName.epaperOpen,
      properties: {
        'source': 'first_open_popup',
        'action': 'impression',
      },
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _openTodayEpaper() async {
    if (_isOpeningEpaper) return;
    setState(() {
      _isOpeningEpaper = true;
    });

    final epaperProvider = context.read<EpaperProvider>();

    // Close the dialog first
    Navigator.of(context).pop();

    try {
      if (epaperProvider.allEpapers.isEmpty) {
        await epaperProvider.fetchEpapers();
      }

      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      // Find the most appropriate e-paper for the selected language & date
      Map<String, dynamic>? targetEpaper;

      if (epaperProvider.allEpapers.isNotEmpty) {
        // 1. Try matching language and today's date
        try {
          targetEpaper = epaperProvider.allEpapers.firstWhere(
            (e) {
              final lang = (e['language'] ?? 'te').toString().toLowerCase();
              final pDate = (e['publishDate'] ?? '').toString();
              return lang == _selectedLanguage && pDate.startsWith(todayStr);
            },
          ) as Map<String, dynamic>?;
        } catch (_) {}

        // 2. Try matching today's date regardless of language
        if (targetEpaper == null) {
          try {
            targetEpaper = epaperProvider.allEpapers.firstWhere(
              (e) => (e['publishDate'] ?? '').toString().startsWith(todayStr),
            ) as Map<String, dynamic>?;
          } catch (_) {}
        }

        // 3. Try matching language regardless of date
        if (targetEpaper == null) {
          try {
            targetEpaper = epaperProvider.allEpapers.firstWhere(
              (e) => (e['language'] ?? 'te').toString().toLowerCase() == _selectedLanguage,
            ) as Map<String, dynamic>?;
          } catch (_) {}
        }

        // 4. Fallback to first available e-paper
        targetEpaper ??= epaperProvider.allEpapers.first as Map<String, dynamic>?;
      }

      if (targetEpaper != null) {
        mainNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => EpaperDetailScreen(epaper: targetEpaper!),
          ),
        );
      } else {
        // Fallback to epaper listing screen if no items found
        mainNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const EpaperScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error opening today e-paper: $e");
      mainNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const EpaperScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background blur layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),

          // Main Scrollable Dialog Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top close button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // 3D Newspaper Mockup Graphic with floating animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: _openTodayEpaper,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient radial glow behind the newspaper
                            Container(
                              width: 280.w,
                              height: 280.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFEF1515).withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.75],
                                ),
                              ),
                            ),

                            // 3D Newspaper image
                            Image.asset(
                              'assets/images/epaper_popup_newspaper.png',
                              width: 330.w,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Sun Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: Size(26.w, 14.h),
                        painter: const _MorningSunPainter(),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // "Good Morning!" Text
                  Text(
                    "Good Morning!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // "BIGTV E-PAPER" Branding
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "BIG",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: "TV",
                          style: TextStyle(
                            color: const Color(0xFFE50914),
                            fontSize: 27.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: " E-PAPER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Subtitle
                  Text(
                    "Read today's top stories in Telugu & English",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFD1D5DB),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Language Toggle Switcher [ తెలుగు | English ]
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161D),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Telugu Pill
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedLanguage = 'te';
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color: _selectedLanguage == 'te'
                                  ? const Color(0xFFE50914)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "తెలుగు",
                              style: TextStyle(
                                color: _selectedLanguage == 'te'
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                                fontSize: 13.sp,
                                fontWeight: _selectedLanguage == 'te'
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // English Pill
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedLanguage = 'en';
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color: _selectedLanguage == 'en'
                                  ? const Color(0xFFE50914)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "English",
                              style: TextStyle(
                                color: _selectedLanguage == 'en'
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                                fontSize: 13.sp,
                                fontWeight: _selectedLanguage == 'en'
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // Giant Glowing "READ E-PAPER >" CTA Button
                  GestureDetector(
                    onTap: _openTodayEpaper,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 340.w),
                      height: 52.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFEF1515),
                            Color(0xFFB30B0B),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF1515).withValues(alpha: 0.55),
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Newspaper Icon Badge
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Icons.newspaper_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),

                            // Button Text
                            Text(
                              "READ E-PAPER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),

                            // White Circle with Red Chevron Arrow
                            Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: const Color(0xFFEF1515),
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the morning sun rays
class _MorningSunPainter extends CustomPainter {
  const _MorningSunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height * 0.75;

    final sunPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;

    // Half sun body
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      true,
      sunPaint,
    );

    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 5 rays extending outward
    final rayAngles = [-150.0, -120.0, -90.0, -60.0, -30.0];
    for (final deg in rayAngles) {
      final rad = deg * (math.pi / 180.0);
      final start = Offset(
        center.dx + (radius + 2.5) * math.cos(rad),
        center.dy + (radius + 2.5) * math.sin(rad),
      );
      final end = Offset(
        center.dx + (radius + 7.5) * math.cos(rad),
        center.dy + (radius + 7.5) * math.sin(rad),
      );
      canvas.drawLine(start, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
