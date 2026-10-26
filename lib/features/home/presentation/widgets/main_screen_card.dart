import 'package:chotanews/aggricator_screens/loading_screen/home_shimmer.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/services/translation_service.dart';
import 'main_screen_pageview.dart';
import 'infocus_bar_widget.dart';

class MainScreenCard extends StatefulWidget {
  const MainScreenCard({
    super.key,
  });

  @override
  State<MainScreenCard> createState() => _MainScreenCardState();
}

class _MainScreenCardState extends State<MainScreenCard>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> removedCards = [];
  Offset slideOffset = Offset.zero;
  bool isAnimating = false;
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().getAllAiTags();
    if (context.read<HomeProvider>().postId.toString() == "0") {
      context.read<HomeProvider>().getAllPost();
    }
    // Pre-download translation models in background
    TranslationService().init();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, SettingsProvider>(
      builder: (_, homeProvider, settingsProvider, __) {
        final bool showInFocusBar = MediaQuery.of(context).orientation != Orientation.landscape &&
            homeProvider.showTopNavTags &&
            (homeProvider.getAllAiTagsList.isNotEmpty || homeProvider.isAiTagsLoading);

        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color topBarColor = isDark ? const Color(0xFF0F0F12) : Colors.white;

        return PopScope(
          canPop: !homeProvider.isAiTagDataLoaded,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (homeProvider.isAiTagDataLoaded) {
              homeProvider.setSelectedTagId(0);
              homeProvider.aiTagDataLoaded(false);
              homeProvider.getAllPost(postIds: "0");
            }
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: topBarColor,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: topBarColor,
              body: SafeArea(
                left: false,
                right: MediaQuery.of(context).orientation != Orientation.landscape,
                top: MediaQuery.of(context).orientation != Orientation.landscape,
                bottom: false,
                child: Container(
                  color: topBarColor,
                  child: Center(
                    child: homeProvider.isHomeLoading
                        ? HomeShimmer()
                        : Column(
                            children: [
                              if (showInFocusBar)
                                const InFocusBarWidget(),
                              Expanded(child: MainScreenPageView()),
                            ],
                          ),
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

class PremiumAnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  const PremiumAnimatedButton({super.key, required this.onTap});

  @override
  State<PremiumAnimatedButton> createState() => _PremiumAnimatedButtonState();
}

class _PremiumAnimatedButtonState extends State<PremiumAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFDF00),
              Color(0xFFD4AF37),
              Color(0xFFFFDF00),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: Colors.black87, size: 18),
                    SizedBox(width: 4.w),
                    Text(
                      "Premium",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FractionalTranslation(
                      translation:
                          Offset(-1.5 + (_controller.value * 3.0), 0.0),
                      child: Transform(
                        transform: Matrix4.skewX(-0.3),
                        child: Container(
                          width: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.6),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
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

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          height(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              height: 20,
              width: 200,
              color: Colors.grey[300],
            ),
          ),
          height(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shimmerIcon(),
                shimmerIcon(),
                shimmerIcon(),
              ],
            ),
          ),
          height(height: 20.h),
        ],
      ),
    );
  }

  Widget shimmerIcon() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
