import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_event_screen.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolkNightFloatingButton extends StatefulWidget {
  const FolkNightFloatingButton({super.key});

  @override
  State<FolkNightFloatingButton> createState() => _FolkNightFloatingButtonState();
}

class _FolkNightFloatingButtonState extends State<FolkNightFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap(BuildContext context) async {
    final homeProvider = context.read<HomeProvider>();
    if (homeProvider.langCode != 'te') {
      CustomToast.showErrorToast(
        msg: "Folk Night is not available for the selected language",
        timeDuration: 2,
      );
      return;
    }

    try {
      context.read<VideoProvider>().pauseVideo();
      homeProvider.isPlayingYoutube(false);
    } catch (_) {}

    SharedPreferences sp = await SharedPreferences.getInstance();
    bool isGuest = sp.getString("loginType") != "login";

    if (!context.mounted) return;

    if (isGuest) {
      showDialog(
        context: context,
        builder: (dialogCtx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            contentPadding: EdgeInsets.all(24.w),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColorTokens.primaryRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColorTokens.primaryRed,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Guest User",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "You are using the app as a guest user. Please login with your mobile number to view and book Folk Night tickets.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorTokens.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      try {
                        context.read<HomeProvider>().isPlayingYoutube(false);
                        context.read<VideoProvider>().pauseVideo();
                      } catch (_) {}
                      Navigator.pop(dialogCtx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginBackgroundView(),
                        ),
                      );
                    },
                    child: Text(
                      "Login with mobile number",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FolkNightEventScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    if (!homeProvider.folkNight || homeProvider.langCode == 'ml') {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: AppColorTokens.primaryRed.withValues(alpha: 0.45),
                  blurRadius: _pulseAnimation.value,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                  blurRadius: _pulseAnimation.value * 0.8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30.r),
              child: InkWell(
                onTap: () => _handleTap(context),
                borderRadius: BorderRadius.circular(30.r),
                child: Ink(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE50914),
                        Color(0xFFD32F2F),
                        Color(0xFFFF6F00),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.8),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.confirmation_number_rounded,
                          color: AppColorTokens.primaryRed,
                          size: 14.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Folk Night",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.3,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEB3B),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Book Tickets",
                            style: TextStyle(
                              color: const Color(0xFFFFE082),
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
