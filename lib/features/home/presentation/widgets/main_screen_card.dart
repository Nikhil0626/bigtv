import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/loading_screen/home_shimmer.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_event_screen.dart';
import 'package:chotanews/services/translation_service.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'main_screen_pageview.dart';

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

  Map<int, GlobalKey> aiTagKeys = {};
  ScrollController aiTagScrollController = ScrollController();

  void aiTagsScrollToCenter(int index) {
    final keyContext = aiTagKeys[index]?.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      final size = box.size;
      final position = box.localToGlobal(Offset.zero);
      final screenWidth = WidgetsBinding
              .instance.platformDispatcher.views.first.physicalSize.width /
          WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio;

      final itemCenter = position.dx + size.width / 2;
      final targetOffset =
          aiTagScrollController.offset + itemCenter - screenWidth / 2;

      aiTagScrollController.animateTo(
        targetOffset.clamp(0.0, aiTagScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, SettingsProvider>(
      builder: (_, homeProvider, settingsProvider, __) {
        final bool hasTopBarContent = (homeProvider.langCode == 'ml') ||
            (homeProvider.folkNight && homeProvider.langCode != 'ml') ||
            (homeProvider.showTopNavTags && homeProvider.getAllAiTagsList.isNotEmpty);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColorTokens.primaryRed,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor:
                MediaQuery.of(context).orientation != Orientation.landscape
                    ? AppColorTokens.primaryRed
                    : Colors.black,
            appBar: (MediaQuery.of(context).orientation != Orientation.landscape && hasTopBarContent)
                ? AppBar(
                    toolbarHeight: 35.h,
                    backgroundColor: AppColorTokens.primaryRed,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark,
                    ),
                    title: Container(
                      color: AppColorTokens.primaryRed,
                      height: 35.h,
                      child: Row(
                        children: [
                          if (homeProvider.langCode == 'ml')
                            PremiumAnimatedButton(
                              onTap: () {
                                homeProvider.onItemTapped(2);
                                homeProvider.homePageController.jumpToPage(2);
                                homeProvider.pageChange(isValue: true);
                              },
                            ),
                          if (homeProvider.folkNight && homeProvider.langCode != 'ml') ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                if (homeProvider.langCode != 'te') {
                                  CustomToast.showErrorToast(
                                    msg: "Folk Night is not available for the selected language",
                                    timeDuration: 2,
                                  );
                                  return;
                                }

                                SharedPreferences sp = await SharedPreferences.getInstance();
                                bool isGuest = sp.getString("loginType") != "login";
                                
                                if (!context.mounted) return;
                                if (isGuest) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        contentPadding: const EdgeInsets.all(24),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Guest User",
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              "You are using the app as a guest user. Please login with your mobile number to continue.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 48,
                                              child: ElevatedButton(
                                                 style: ElevatedButton.styleFrom(
                                                   backgroundColor: AppColorTokens.primaryRed,
                                                   padding: const EdgeInsets.symmetric(horizontal: 8),
                                                   shape: RoundedRectangleBorder(
                                                     borderRadius: BorderRadius.circular(8),
                                                   ),
                                                 ),
                                                 onPressed: () {
                                                   try {
                                                     context.read<HomeProvider>().isPlayingYoutube(false);
                                                   } catch (_) {}
                                                   try {
                                                     context.read<VideoProvider>().pauseVideo();
                                                   } catch (_) {}
                                                   Navigator.pop(context); // close dialog
                                                   Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginBackgroundView()));
                                                 },
                                                 child: const FittedBox(
                                                   fit: BoxFit.scaleDown,
                                                   child: Text(
                                                     "Login with mobile number",
                                                     textAlign: TextAlign.center,
                                                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
                                    MaterialPageRoute(builder: (context) => const FolkNightEventScreen()),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 14.sp,
                                      color: AppColorTokens.primaryRed,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Folk Night",
                                      style: TextStyle(
                                        color: AppColorTokens.primaryRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          if (homeProvider.showTopNavTags && homeProvider.getAllAiTagsList.isNotEmpty)
                            Expanded(
                              child: ListView.separated(
                                controller: homeProvider.aiTagScrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: homeProvider.getAllAiTagsList.length,
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    child: VerticalDivider(
                                      color: Colors.grey.withAlpha(5),
                                      thickness: 1,
                                      width: 2.w,
                                    ),
                                  );
                                },
                                itemBuilder: (context, index) {
                                  if (!homeProvider.aiTagKeys
                                      .containsKey(index)) {
                                    homeProvider.aiTagKeys[index] = GlobalKey();
                                  }

                                  final tag =
                                      homeProvider.getAllAiTagsList[index];
                                  final tagId = tag['aitagid'] ?? tag['id'] ?? tag['slug'] ?? tag['aitagname'];
                                  final selectedId = homeProvider.selectedTagId;

                                  final bool isSelected = homeProvider.isAiTagDataLoaded &&
                                      selectedId != null &&
                                      selectedId != 0 &&
                                      selectedId != "0" &&
                                      (selectedId.toString() == tagId?.toString() ||
                                       (tag['aitagid'] != null && selectedId.toString() == tag['aitagid'].toString()) ||
                                       (tag['slug'] != null && selectedId.toString() == tag['slug'].toString()) ||
                                       (tag['aitagname'] != null && selectedId.toString() == tag['aitagname'].toString()));

                                  return InkWell(
                                    key: homeProvider.aiTagKeys[index],
                                    onTap: () async {
                                      if (isSelected && homeProvider.isAiTagDataLoaded) {
                                        homeProvider.setSelectedTagId(0);
                                        homeProvider.aiTagDataLoaded(false);
                                        homeProvider.getAllPost(postIds: "0");
                                        return;
                                      }

                                      final tagSlug = tag['slug'] ?? tag['name'] ?? tag['aitagname'] ?? tagId;
                                      final displayTitle = tag['aitagname'] ?? tag['name'] ?? tagSlug;
                                      final tagThumbnail = tag['thumbnailUrl'] ?? tag['thumbnail_url'] ?? tag['thumbnail'];
                                      final chosenId = tagId ?? tagSlug;

                                      homeProvider.setSelectedTagId(chosenId);
                                      if (homeProvider.liveTvVideosEnable) {
                                        homeProvider.fetchVideosByTagSlug(
                                          tagSlug.toString(),
                                          displayTitle: displayTitle.toString(),
                                          thumbnailUrl: tagThumbnail?.toString(),
                                        );
                                      } else {
                                        homeProvider.getAllPostsByAiId(tag['aitagid'] ?? chosenId);
                                      }
                                      homeProvider.aiTagDataLoaded(true);
                                      homeProvider.pageChange(isValue: true);
                                      context
                                          .read<VideoProvider>()
                                          .pauseVideo();
                                      homeProvider.aiTagsScrollToCenter(index);
                                      EventRepo().addEvent({
                                        "aiTagName":
                                            (tag['aitagname'] ?? "").toString(),
                                        "aiTagId": (tag['aitagid'] ?? chosenId ?? "").toString(),
                                        "createAt": DateTime.now().toString(),
                                      }, "ai_tag_click");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: const BorderSide(
                                            color: Colors.transparent,
                                            width: 3,
                                          ),
                                          bottom: BorderSide(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.transparent,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        tag['aitagname'].toString(),
                                        style: homeScreenFontStyle(
                                          color: AppColors.wColor,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
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
                )
                : null,
            body: SafeArea(
              left: MediaQuery.of(context).orientation != Orientation.landscape,
              right:
                  MediaQuery.of(context).orientation != Orientation.landscape,
              top: !hasTopBarContent,
              bottom: false,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: homeProvider.isHomeLoading
                      ? HomeShimmer()
                      : Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(child: MainScreenPageView()),
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
