import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_screen.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/poll_share_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PollsFeedScreen extends StatefulWidget {
  final int initialIndex;

  const PollsFeedScreen({super.key, this.initialIndex = 0});

  @override
  State<PollsFeedScreen> createState() => _PollsFeedScreenState();
}

class _PollsFeedScreenState extends State<PollsFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    context.read<PollProvider>().initFeedView(initialIndex: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().fetchDynamicPolls();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImageUrl(dynamic imageUrl) {
    return PollShareHelper.resolveImageUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final pollProvider = context.watch<PollProvider>();
    final isTelugu = homeProvider.langCode != 'ml';
    final polls = homeProvider.getAllPolls();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColorTokens.cinematicBackground,
        body: homeProvider.isPollsLoading && polls.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColorTokens.cinemaRed,
                ),
              )
            : polls.isEmpty
                ? _buildEmptyState(isTelugu)
                : pollProvider.isGridView
                    ? _buildGridView(polls, isTelugu, pollProvider)
                    : _buildSwipeView(polls, isTelugu, pollProvider),
      ),
    );
  }

  // Full-screen swipeable feed of Poll posts
  Widget _buildSwipeView(
    List<Map<String, dynamic>> polls,
    bool isTelugu,
    PollProvider pollProvider,
  ) {
    final safeIndex = polls.isEmpty
        ? 0
        : pollProvider.currentPollIndex.clamp(0, polls.length - 1);

    return Stack(
      children: [
        // Vertical PageView
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: polls.length,
          onPageChanged: pollProvider.setCurrentPollIndex,
          itemBuilder: (context, index) {
            return PollScreenDesign(
              artical: polls[index],
              index: index,
              showTopBar: false,
            );
          },
        ),

        // Floating Top Header Overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Row(
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // 3D Polls Icon
                    Image.asset(
                      'assets/images/polls_3d_icon.png',
                      width: 26.w,
                      height: 26.w,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.poll_rounded,
                        color: AppColorTokens.cinemaRed,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Red BIG TV Logo Emblem
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColorTokens.cinemaRed,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'BIG TV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    Text(
                      '|',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Title
                    Expanded(
                      child: Text(
                        isTelugu ? 'పోల్స్' : 'വോട്ടെടുപ്പ്',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Page Counter Pill (e.g. "1 / 4")
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${safeIndex + 1}/${polls.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Grid View Switcher Button
                    InkWell(
                      onTap: () => pollProvider.setGridView(true),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 17.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Grid View of all Polls
  Widget _buildGridView(
    List<Map<String, dynamic>> polls,
    bool isTelugu,
    PollProvider pollProvider,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Grid App Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                InkWell(
                  onTap: () => pollProvider.setGridView(false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColorTokens.cinematicSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColorTokens.cinematicBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'అన్ని పోల్స్' : 'എല്ലാ വോട്ടെടുപ്പുകളും',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "${polls.length} ${isTelugu ? 'పోల్స్ అందుబాటులో ఉన్నాయి' : 'ലഭ്യമായ വോട്ടെടുപ്പുകൾ'}",
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Switch back to Feed swiper
                InkWell(
                  onTap: () => pollProvider.setGridView(false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColorTokens.cinemaRed,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.view_carousel_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isTelugu ? 'స్వైప్ వీక్షణ' : 'സ്വൈപ്പ് കാഴ്‌ച',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF24242D), height: 1),

          // Grid Body
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(14.w),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.64,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 14.h,
              ),
              itemCount: polls.length,
              itemBuilder: (context, index) {
                final item = polls[index];
                final title = (item['title'] ?? 'Poll').toString();
                final imageUrl =
                    _getImageUrl(item['image_url'] ?? item['imageUrl']);
                final category =
                    (item['category'] ?? item['categoryName'] ?? 'రాజకీయాలు')
                        .toString();
                final votes =
                    (item['total_votes_display'] ?? '1.2 లక్షల మంది')
                        .toString();

                return GestureDetector(
                  onTap: () {
                    pollProvider.selectPollFromGrid(index);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(index);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161C),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFF262633),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with Category Tag
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: const Color(0xFF1F1F27),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColorTokens.cinemaRed,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: const Color(0xFF1F1F27),
                                  child: const Icon(
                                    Icons.poll_rounded,
                                    color: Colors.white24,
                                    size: 40,
                                  ),
                                ),
                              ),

                              // Gradient Shade
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        const Color(0xFF16161C)
                                            .withValues(alpha: 0.8),
                                      ],
                                      stops: const [0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Category Pill
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColorTokens.cinemaRed,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Title & Info
                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.how_to_vote_rounded,
                                    color: AppColorTokens.cinemaRed,
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      votes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTelugu) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.poll_rounded,
            size: 64.sp,
            color: Colors.white24,
          ),
          SizedBox(height: 16.h),
          Text(
            isTelugu
                ? 'ప్రస్తుతం పోల్స్ అందుబాటులో లేవు'
                : 'നിലവിൽ വോട്ടെടുപ്പുകൾ ലഭ്യമല്ല',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.maybePop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorTokens.cinemaRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: Text(isTelugu ? 'వెనక్కి వెళ్ళండి' : 'തിരികെ പോകുക'),
          ),
        ],
      ),
    );
  }
}
