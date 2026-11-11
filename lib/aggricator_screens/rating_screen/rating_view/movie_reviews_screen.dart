import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/movie_review_share_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MovieReviewsScreen extends StatefulWidget {
  final int initialIndex;

  const MovieReviewsScreen({super.key, this.initialIndex = 0});

  @override
  State<MovieReviewsScreen> createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    context.read<RatingProvider>().initFeedView(initialIndex: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().fetchDynamicMovieReviews();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImageUrl(dynamic imageUrl) {
    return MovieReviewShareHelper.resolveImageUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final ratingProvider = context.watch<RatingProvider>();
    final isTelugu = homeProvider.langCode != 'ml';
    final reviews = homeProvider.getAllMovieReviews();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColorTokens.cinematicBackground,
        body: homeProvider.isMovieReviewsLoading && reviews.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColorTokens.cinemaRed,
                ),
              )
            : reviews.isEmpty
                ? _buildEmptyState(isTelugu)
                : ratingProvider.isGridView
                    ? _buildGridView(reviews, isTelugu, ratingProvider)
                    : _buildSwipeView(reviews, isTelugu, ratingProvider),
      ),
    );
  }

  // Full-screen swipeable feed of Movie Review posts
  Widget _buildSwipeView(
    List<Map<String, dynamic>> reviews,
    bool isTelugu,
    RatingProvider ratingProvider,
  ) {
    final safeIndex = reviews.isEmpty
        ? 0
        : ratingProvider.currentReviewIndex.clamp(0, reviews.length - 1);

    return Column(
      children: [
        _buildSwipeHeader(
          reviews: reviews,
          safeIndex: safeIndex,
          isTelugu: isTelugu,
          ratingProvider: ratingProvider,
        ),
        const Divider(color: Color(0xFF24242D), height: 1),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reviews.length,
            onPageChanged: ratingProvider.setCurrentReviewIndex,
            itemBuilder: (context, index) {
              return MovieRatings(article: reviews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeHeader({
    required List<Map<String, dynamic>> reviews,
    required int safeIndex,
    required bool isTelugu,
    required RatingProvider ratingProvider,
  }) {
    return Container(
      key: const Key('movie_reviews_swipe_header'),
      color: AppColorTokens.cinematicBackground,
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

              // 3D Movie Review Logo
              Image.asset(
                'assets/images/movie_reviews_3d_icon.png',
                width: 26.w,
                height: 26.w,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.movie_filter_rounded,
                  color: AppColorTokens.cinemaRed,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 8.w),

              // Red BIG TV Logo Emblem
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
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
                  isTelugu ? 'సినిమా సమీక్షలు' : 'സിനിമ റിവ്യൂകൾ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Page Counter Pill (e.g. "1 / 6")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${safeIndex + 1}/${reviews.length}',
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
                onTap: () => ratingProvider.setGridView(true),
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
    );
  }

  // Poster Grid View of all Movie Reviews
  Widget _buildGridView(
    List<Map<String, dynamic>> reviews,
    bool isTelugu,
    RatingProvider ratingProvider,
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
                  onTap: () => ratingProvider.setGridView(false),
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
                        isTelugu
                            ? 'అన్ని సినిమా సమీక్షలు'
                            : 'എല്ലാ സിനിമ റിവ്യൂകളും',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "${reviews.length} ${isTelugu ? 'సినిమాలు' : 'സിനിമകൾ'}",
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
                  onTap: () => ratingProvider.setGridView(false),
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
                childAspectRatio: 0.62,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 14.h,
              ),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final item = reviews[index];
                final title =
                    (item['movie_name'] ?? item['title'] ?? 'Movie').toString();
                final imageUrl =
                    _getImageUrl(item['image_url'] ?? item['imageUrl']);
                final genre =
                    (item['genre'] ?? item['genreTelugu'] ?? 'యాక్షన్')
                        .toString();
                final cert =
                    (item['certification'] ?? item['censor_rating'] ?? 'UA')
                        .toString();
                final year = (item['release_year'] ?? '2024').toString();

                String ratingDisplay = '4.0/5';
                if (item['chotaMeter'] != null &&
                    item['chotaMeter'].toString().trim().isNotEmpty) {
                  ratingDisplay = item['chotaMeter'].toString().trim();
                } else if (item['chotarating'] != null &&
                    item['chotarating'].toString().trim().isNotEmpty) {
                  ratingDisplay = item['chotarating'].toString().trim();
                } else if (item['externalRatings'] is List &&
                    (item['externalRatings'] as List).isNotEmpty) {
                  final first = (item['externalRatings'] as List).first;
                  ratingDisplay =
                      first['platform_rating']?.toString() ?? '4.0/5';
                } else if (item['imdbRating'] != null) {
                  ratingDisplay = item['imdbRating'].toString();
                }

                return GestureDetector(
                  onTap: () {
                    ratingProvider.selectReviewFromGrid(index);
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
                        // Poster Image with Badges
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
                                    Icons.movie_rounded,
                                    color: Colors.white24,
                                    size: 40,
                                  ),
                                ),
                              ),

                              // Gradient Shade at bottom of poster
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

                              // Rating Badge on top right
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColorTokens.cinemaRed,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.white,
                                        size: 13.sp,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        ratingDisplay,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Cert Pill on top left
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: Colors.white30,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    cert,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      genre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColorTokens.cinemaRed,
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' • $year',
                                    style: TextStyle(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 10.5.sp,
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
            Icons.movie_filter_rounded,
            size: 64.sp,
            color: Colors.white24,
          ),
          SizedBox(height: 16.h),
          Text(
            isTelugu
                ? 'ప్రస్తుతం సినిమా సమీక్షలు అందుబాటులో లేవు'
                : 'നിലവിൽ സിനിമ റിവ്യൂകൾ ലഭ്യമല്ല',
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
