import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/theme/themed_popup_palette.dart';
import 'package:chotanews/core/widgets/content_share_buttons.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';
import 'package:chotanews/services/movie_review_share_helper.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chotanews/widgets/clean_youtube_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../rating_model.dart';
import '../rating_provider/rating_provider.dart';
import 'list_reviews.dart';

class _HeroMediaSlide {
  final bool isTrailer;
  final String imageUrl;
  final String videoUrl;
  final String? youtubeId;

  const _HeroMediaSlide.trailer({
    required this.videoUrl,
    required String thumbnailUrl,
    this.youtubeId,
  })  : isTrailer = true,
        imageUrl = thumbnailUrl;

  const _HeroMediaSlide.image({
    required this.imageUrl,
  })  : isTrailer = false,
        videoUrl = '',
        youtubeId = null;
}

class MovieRatings extends StatefulWidget {
  const MovieRatings({
    super.key,
    this.article,
    this.youtubePlayerBuilder,
  });

  final dynamic article;
  final Widget Function(YoutubePlayerController controller, bool isLandscape)?
      youtubePlayerBuilder;

  @override
  State<MovieRatings> createState() => _MovieRatingsState();
}

class _MovieRatingsState extends State<MovieRatings> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late final PageController _heroPageController = PageController();
  final GlobalKey _ytPlayerGlobalKey = GlobalKey();
  int _currentSlideIndex = 0;
  YoutubePlayerController? _trailerYtController;
  VideoPlayerController? _trailerVideoController;
  bool _isPlayingTrailer = false;
  bool _isTrailerBuffering = false;
  bool _wasInFullScreen = false;
  bool _showTrailerControls = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateReviewState();
    });
  }

  @override
  void didUpdateWidget(covariant MovieRatings oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.article is Map ? oldWidget.article['id'] : null;
    final newId = widget.article is Map ? widget.article['id'] : null;
    if (newId != oldId) {
      _stopTrailer(updateState: false);
      _currentSlideIndex = 0;
      if (_heroPageController.hasClients) {
        _heroPageController.jumpToPage(0);
      }
      if (newId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _hydrateReviewState();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool routeCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final bool tickerEnabled = TickerMode.valuesOf(context).enabled;
    if ((!routeCurrent || !tickerEnabled) && _isPlayingTrailer) {
      _stopTrailer(updateState: false);
    }
  }

  @override
  void dispose() {
    _stopTrailer(updateState: false);
    _heroPageController.dispose();
    super.dispose();
  }

  void _hydrateReviewState() {
    if (!mounted) return;
    final ratingProvider = context.read<RatingProvider>();
    ratingProvider.loadUserName();
    ratingProvider.commentController.text = '';

    final articleId = widget.article?['id'];
    if (articleId != null) {
      ratingProvider.getReviews(articleId.toString(), 'newest');
    }

    final userHasReviewed = widget.article?['userHasReviewed'] == true ||
        widget.article?['user_has_reviewed'] == true;
    final existingRating =
        widget.article?['userRating'] ?? widget.article?['user_rating'] ?? 0;

    if (userHasReviewed || ratingProvider.isArticleRated(articleId ?? 0)) {
      if (existingRating is num && existingRating > 0) {
        ratingProvider.ratingUpdate(
          existingRating.toInt(),
          articleId ?? 0,
          isNew: true,
        );
      }
    }

    final initialComment = widget.article?['userComment']?.toString().trim() ?? '';
    if (initialComment.isNotEmpty) {
      ratingProvider.setUserComment(articleId ?? 0, initialComment);
    }
  }

  Future<void> _showLoginDialog(dynamic articleId) async {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final palette = ThemedPopupPalette.of(dialogCtx);
        return Dialog(
          backgroundColor: palette.backgroundColor,
          shape: palette.dialogShape(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: palette.accentColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review_rounded,
                    color: palette.accentColor,
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'లాగిన్ అవ్వండి',
                  style: TextStyle(
                    color: palette.titleColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'సినిమా రివ్యూ సమర్పించడానికి మరియు మీ రేటింగ్ ఇవ్వడానికి దయచేసి లాగిన్ అవ్వండి.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.bodyColor,
                    fontSize: 13.5.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: palette.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          'రద్దు',
                          style: TextStyle(
                            color: palette.bodyColor,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogCtx);
                          if (!mounted) return;
                          context
                              .read<AuthenticationProvider>()
                              .newAppLoginStatus = NewAppLoginStatus.login;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginBackgroundView(),
                            ),
                          );

                          if (!mounted) return;
                          final updatedSp =
                              await SharedPreferences.getInstance();
                          final bool isNowLoggedIn =
                              updatedSp.getString('loginType') == 'login';
                          if (isNowLoggedIn && mounted) {
                            final ratingProvider = context.read<RatingProvider>();
                            await ratingProvider.loadUserName();
                            ratingProvider.setEditingForPost(
                              articleId ?? 0,
                              true,
                            );
                          }
                        },
                        child: Text(
                          'లాగిన్',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getImageUrl(dynamic imageUrl) {
    return MovieReviewShareHelper.resolveImageUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> article = widget.article is Map
        ? Map<String, dynamic>.from(widget.article as Map)
        : <String, dynamic>{};
    final String movieTitle = (article['movie_name'] ??
            article['movieName'] ??
            article['title'] ??
            '')
        .toString();
    final String genreTelugu =
        (article['genre'] ?? article['genreTelugu'] ?? '').toString();
    final String certification =
        (article['certification'] ?? article['censor_rating'] ?? '').toString();
    final String metaInfo = (article['meta_info'] ??
            [
              article['genre_en'],
              article['genre_sub'],
              article['release_year'],
              article['duration'],
            ]
                .where((e) => e != null && e.toString().trim().isNotEmpty)
                .join('  |  '))
        .toString();
    final String synopsis =
        (article['description'] ?? article['content'] ?? '').toString();
    final List<_HeroMediaSlide> mediaSlides = _buildMediaSlides(article);

    final String chotaMeter = (article['chotaMeter'] ??
            article['chotarating'] ??
            article['critic_rating'] ??
            article['criticRating'] ??
            '')
        .toString()
        .trim();

    final bool hasBadges = genreTelugu.isNotEmpty ||
        certification.isNotEmpty ||
        (chotaMeter.isNotEmpty && chotaMeter != 'null');
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (_isPlayingTrailer &&
        isLandscape &&
        (_trailerYtController != null || _trailerVideoController != null)) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _toggleTrailerFullScreen(true);
          }
        },
        child: Container(
          key: const Key('movie_review_trailer_landscape_fullscreen'),
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: FittedBox(
                    key: const Key('movie_review_trailer_landscape_cover'),
                    fit: BoxFit.cover,
                    child: _trailerYtController != null
                        ? _buildYoutubePlayerWidget(isLandscape: true)
                        : _buildDirectVideoPlayer(isLandscape: true),
                  ),
                ),
              ),
              ..._buildTrailerOverlayControls(isLandscape: true),
            ],
          ),
        ),
      );
    }

    return _buildMainContent(
      context,
      article: article,
      movieTitle: movieTitle,
      genreTelugu: genreTelugu,
      certification: certification,
      metaInfo: metaInfo,
      synopsis: synopsis,
      mediaSlides: mediaSlides,
      chotaMeter: chotaMeter,
      hasBadges: hasBadges,
    );
  }

  Widget _buildMainContent(
    BuildContext context, {
    required Map<String, dynamic> article,
    required String movieTitle,
    required String genreTelugu,
    required String certification,
    required String metaInfo,
    required String synopsis,
    required List<_HeroMediaSlide> mediaSlides,
    required String chotaMeter,
    required bool hasBadges,
  }) {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColorTokens.cinematicBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Carousel (50% height: trailer + review images)
            Expanded(
              key: const Key('movie_review_hero_section'),
              flex: 1,
              child: _buildHeroCarousel(
                mediaSlides,
                movieTitle,
              ),
            ),

            // Movie Details, Ratings & User Review Card (50% height)
            Expanded(
              key: const Key('movie_review_details_section'),
              flex: 1,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                      // Badges + Share Action Row
                      Row(
                        children: [
                          Expanded(
                            child: hasBadges
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        if (genreTelugu.isNotEmpty) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 14.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColorTokens.cinemaRed,
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Text(
                                              genreTelugu,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.5.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                        ],
                                        if (certification.isNotEmpty) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColorTokens.cinematicSurface,
                                              border: Border.all(
                                                color: const Color(0xFF4B5563),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Text(
                                              certification,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.5.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (chotaMeter.isNotEmpty &&
                                            chotaMeter != 'null') ...[
                                          SizedBox(width: 8.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColorTokens.cinemaRed,
                                                  Color(0xFFB91C1C),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: Colors.amber,
                                                  size: 14.sp,
                                                ),
                                                SizedBox(width: 3.w),
                                                Text(
                                                  'BIG TV $chotaMeter',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.5.sp,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(width: 8.w),
                          ContentShareButtons(
                            whatsAppButtonKey: const Key(
                              'movie_review_whatsapp_share_button',
                            ),
                            onShareWhatsApp: () {
                              MovieReviewShareHelper.shareMovieReview(
                                context: context,
                                article: article,
                                ratingDetails: context
                                    .read<RatingProvider>()
                                    .movieReviewDetails,
                                screenshotController: _screenshotController,
                                isWhatsAppOnly: true,
                              );
                            },
                          ),
                        ],
                      ),

                      // Metadata
                      if (metaInfo.isNotEmpty)
                        Text(
                          metaInfo,
                          style: TextStyle(
                            color: const Color(0xFFD1D5DB),
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),

                      // Synopsis
                      if (synopsis.isNotEmpty)
                        Text(
                          synopsis,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFE5E7EB),
                            fontSize: 13.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                      // Ratings Row
                      _buildOtherRatingsRow(article),

                      // Below Section: User Rating & Review Card
                      _buildUserRatingCard(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  String? _extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    final ytId = YoutubePlayer.convertUrlToId(url);
    if (ytId != null && ytId.isNotEmpty) return ytId;
    final regExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|shorts\/))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  List<_HeroMediaSlide> _buildMediaSlides(Map<String, dynamic> article) {
    final String rawVideoUrl = (article['video_url'] ??
            article['videoUrl'] ??
            article['trailer_url'] ??
            article['trailerUrl'] ??
            '')
        .toString()
        .trim();
    final String videoUrl =
        rawVideoUrl.toLowerCase() == 'null' ? '' : rawVideoUrl;

    final List<String> imageUrls = [];
    final Set<String> seen = {};

    void addImage(dynamic raw) {
      final resolved = _getImageUrl(raw);
      if (resolved.isNotEmpty && seen.add(resolved)) {
        imageUrls.add(resolved);
      }
    }

    addImage(article['image_url'] ?? article['imageUrl']);

    final dynamic rawGallery = article['gallery'] ?? article['images'];
    if (rawGallery is List) {
      for (final item in rawGallery) {
        if (item is Map) {
          addImage(
            item['Url'] ??
                item['url'] ??
                item['image_url'] ??
                item['imageUrl'] ??
                item['image'],
          );
        } else {
          addImage(item);
        }
      }
    }

    final List<_HeroMediaSlide> slides = [];
    if (videoUrl.isNotEmpty) {
      final String? ytId = _extractYoutubeId(videoUrl);
      final String trailerThumb = imageUrls.isNotEmpty
          ? imageUrls.first
          : (ytId != null && ytId.isNotEmpty
              ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
              : '');
      slides.add(
        _HeroMediaSlide.trailer(
          videoUrl: videoUrl,
          thumbnailUrl: trailerThumb,
          youtubeId: ytId,
        ),
      );
    }

    for (final url in imageUrls) {
      slides.add(_HeroMediaSlide.image(imageUrl: url));
    }
    return slides;
  }

  Future<void> _startTrailer(_HeroMediaSlide slide) async {
    _stopTrailer(updateState: false);
    final ytId = slide.youtubeId ?? _extractYoutubeId(slide.videoUrl);
    if (ytId != null && ytId.isNotEmpty) {
      final controller = YoutubePlayerController(
        initialVideoId: ytId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          hideControls: true,
        ),
      );
      setState(() {
        _trailerYtController = controller;
        _isPlayingTrailer = true;
        _isTrailerBuffering = false;
        _showTrailerControls = false;
      });
      return;
    }

    final uri = Uri.tryParse(slide.videoUrl);
    if (uri == null) return;
    setState(() {
      _isPlayingTrailer = true;
      _isTrailerBuffering = true;
      _showTrailerControls = false;
    });
    final controller = VideoPlayerController.networkUrl(uri);
    _trailerVideoController = controller;
    try {
      await controller.initialize();
      if (!mounted || _trailerVideoController != controller) {
        await controller.dispose();
        return;
      }
      await controller.play();
      setState(() {
        _isTrailerBuffering = false;
      });
    } catch (_) {
      _stopTrailer();
    }
  }

  void _stopTrailer({bool updateState = true}) {
    final yt = _trailerYtController;
    final bool shouldRestorePortrait =
        _wasInFullScreen || (yt?.value.isFullScreen ?? false);
    _trailerYtController = null;
    if (yt != null) {
      try {
        yt.pause();
        yt.dispose();
      } catch (_) {}
    }

    final vc = _trailerVideoController;
    _trailerVideoController = null;
    if (vc != null) {
      try {
        vc.pause();
        vc.dispose();
      } catch (_) {}
    }

    _wasInFullScreen = false;
    _isPlayingTrailer = false;
    _isTrailerBuffering = false;
    _showTrailerControls = false;
    if (shouldRestorePortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
    if (updateState && mounted) {
      setState(() {});
    }
  }

  Widget _buildHeroImagePlaceholder() {
    return Container(
      color: const Color(0xFF1A1A20),
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          size: 60.sp,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildNetworkSlideImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildHeroImagePlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: AppColorTokens.cinematicSurface,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColorTokens.cinemaRed,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildHeroImagePlaceholder(),
    );
  }

  void _toggleTrailerFullScreen(bool isCurrentlyLandscape) {
    if (isCurrentlyLandscape) {
      _wasInFullScreen = false;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } else {
      _wasInFullScreen = true;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _toggleTrailerControlsVisibility() {
    setState(() {
      _showTrailerControls = !_showTrailerControls;
    });
  }

  Widget _buildTrailerCircleButton({
    required Key buttonKey,
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 22,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    bool showBorder = false,
  }) {
    return InkWell(
      key: buttonKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                )
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildTrailerCloseButton() {
    return _buildTrailerCircleButton(
      buttonKey: const Key('movie_review_trailer_close_button'),
      icon: Icons.close_rounded,
      onTap: _stopTrailer,
    );
  }

  Widget _buildTrailerFullScreenButton(bool isLandscape) {
    return _buildTrailerCircleButton(
      buttonKey: const Key('movie_review_trailer_fullscreen_button'),
      icon: isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
      iconSize: 24,
      onTap: () => _toggleTrailerFullScreen(isLandscape),
    );
  }

  void _toggleTrailerPlayPause() {
    final yt = _trailerYtController;
    if (yt != null) {
      if (yt.value.isPlaying) {
        yt.pause();
      } else {
        yt.play();
      }
      return;
    }
    final vc = _trailerVideoController;
    if (vc != null) {
      if (vc.value.isPlaying) {
        vc.pause();
      } else {
        vc.play();
      }
    }
  }

  Widget _buildTrailerPlayPauseButton({required bool isLandscape}) {
    final double iconSize = isLandscape ? 52 : 44;
    final EdgeInsetsGeometry padding = EdgeInsets.all(isLandscape ? 14 : 12);

    final yt = _trailerYtController;
    if (yt != null) {
      return ValueListenableBuilder<YoutubePlayerValue>(
        valueListenable: yt,
        builder: (context, ytValue, _) {
          return _buildTrailerCircleButton(
            buttonKey: const Key('movie_review_trailer_play_pause_button'),
            icon: ytValue.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            iconSize: iconSize,
            padding: padding,
            showBorder: true,
            onTap: _toggleTrailerPlayPause,
          );
        },
      );
    }

    final vc = _trailerVideoController;
    if (vc != null) {
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: vc,
        builder: (context, videoValue, _) {
          return _buildTrailerCircleButton(
            buttonKey: const Key('movie_review_trailer_play_pause_button'),
            icon: videoValue.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            iconSize: iconSize,
            padding: padding,
            showBorder: true,
            onTap: _toggleTrailerPlayPause,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildYoutubePlayerWidget({required bool isLandscape}) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double? ytWidth =
        isLandscape ? screenSize.height * (16 / 9) : null;
    final double? ytHeight = isLandscape ? screenSize.height : null;

    final customBuilder = widget.youtubePlayerBuilder;
    if (customBuilder != null) {
      return SizedBox(
        key: _ytPlayerGlobalKey,
        width: ytWidth ?? double.infinity,
        height: ytHeight,
        child: customBuilder(_trailerYtController!, isLandscape),
      );
    }

    return SizedBox(
      key: _ytPlayerGlobalKey,
      width: ytWidth ?? double.infinity,
      height: ytHeight,
      child: CleanYoutubePlayer(
        controller: _trailerYtController!,
        width: ytWidth,
        onEnded: (_) => _stopTrailer(),
      ),
    );
  }

  Widget _buildScrubSeekBar({
    Key? barKey,
    required int totalMs,
    required int currentMs,
    required ValueChanged<Duration> onSeek,
  }) {
    final double progress =
        totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;
    return LayoutBuilder(
      key: barKey,
      builder: (context, constraints) {
        void seekAt(double dx) {
          if (constraints.maxWidth > 0 && totalMs > 0) {
            final f = (dx / constraints.maxWidth).clamp(0.0, 1.0);
            onSeek(Duration(milliseconds: (f * totalMs).toInt()));
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) => seekAt(details.localPosition.dx),
          onTapDown: (details) => seekAt(details.localPosition.dx),
          child: Container(
            height: 24,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColorTokens.cinemaRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailerSeekBar() {
    final ytController = _trailerYtController;
    if (ytController != null) {
      return ValueListenableBuilder<YoutubePlayerValue>(
        valueListenable: ytController,
        builder: (context, ytValue, _) {
          return _buildScrubSeekBar(
            barKey: const Key('movie_review_youtube_seek_bar'),
            totalMs: ytValue.metaData.duration.inMilliseconds,
            currentMs: ytValue.position.inMilliseconds,
            onSeek: ytController.seekTo,
          );
        },
      );
    }

    final vc = _trailerVideoController;
    if (vc != null) {
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: vc,
        builder: (context, videoValue, _) {
          return _buildScrubSeekBar(
            barKey: const Key('movie_review_youtube_seek_bar'),
            totalMs: videoValue.duration.inMilliseconds,
            currentMs: videoValue.position.inMilliseconds,
            onSeek: vc.seekTo,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  List<Widget> _buildTrailerOverlayControls({required bool isLandscape}) {
    final double topInset = isLandscape ? 16 : 10;
    final double sideInset = isLandscape ? 16 : 12;

    return [
      Positioned.fill(
        child: GestureDetector(
          key: const Key('movie_review_trailer_tap_surface'),
          behavior: HitTestBehavior.opaque,
          onTap: _toggleTrailerControlsVisibility,
          child: const SizedBox.expand(),
        ),
      ),
      if (_showTrailerControls) ...[
        const Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: Colors.black26),
          ),
        ),
        Positioned(
          top: topInset,
          left: sideInset,
          child: _buildTrailerCloseButton(),
        ),
        Positioned(
          top: topInset,
          right: sideInset,
          child: _buildTrailerFullScreenButton(isLandscape),
        ),
        Center(
          child: _buildTrailerPlayPauseButton(isLandscape: isLandscape),
        ),
        if (_trailerYtController != null ||
            (_trailerVideoController != null &&
                _trailerVideoController!.value.isInitialized))
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                sideInset,
                8,
                sideInset,
                isLandscape ? 10 : 6,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: _buildTrailerSeekBar(),
            ),
          ),
      ],
    ];
  }

  Widget _buildDirectVideoPlayer({bool isLandscape = false}) {
    if (_trailerVideoController == null ||
        !_trailerVideoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorTokens.cinemaRed),
      );
    }
    final size = _trailerVideoController!.value.size;
    final double vWidth = size.width > 0 ? size.width : 1280;
    final double vHeight = size.height > 0 ? size.height : 720;

    return isLandscape
        ? SizedBox(
            width: vWidth,
            height: vHeight,
            child: VideoPlayer(_trailerVideoController!),
          )
        : Center(
            child: AspectRatio(
              aspectRatio: _trailerVideoController!.value.aspectRatio,
              child: VideoPlayer(_trailerVideoController!),
            ),
          );
  }

  Widget _buildTrailerSlide(_HeroMediaSlide slide) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (_isPlayingTrailer) {
      return Container(
        key: const Key('movie_review_trailer_slide'),
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_trailerYtController != null)
              Center(
                child: _buildYoutubePlayerWidget(isLandscape: isLandscape),
              )
            else if (_trailerVideoController != null &&
                _trailerVideoController!.value.isInitialized)
              _buildDirectVideoPlayer()
            else
              Stack(
                fit: StackFit.expand,
                children: [
                  _buildNetworkSlideImage(slide.imageUrl),
                  if (_isTrailerBuffering)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColorTokens.cinemaRed,
                      ),
                    ),
                ],
              ),
            ..._buildTrailerOverlayControls(isLandscape: isLandscape),
          ],
        ),
      );
    }

    return GestureDetector(
      key: const Key('movie_review_trailer_slide'),
      onTap: () => _startTrailer(slide),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildNetworkSlideImage(slide.imageUrl),
          Align(
            alignment: isLandscape ? const Alignment(0, -0.35) : Alignment.center,
            child: Container(
              key: const Key('movie_review_trailer_play_button'),
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 12 : 14.w,
                vertical: isLandscape ? 6 : 8.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isLandscape ? 24 : 30.r,
                    height: isLandscape ? 24 : 30.r,
                    decoration: const BoxDecoration(
                      color: AppColorTokens.cinemaRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: isLandscape ? 16 : 20.sp,
                    ),
                  ),
                  SizedBox(width: isLandscape ? 6 : 8.w),
                  Text(
                    'TRAILER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLandscape ? 11 : 12.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
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

  // Hero Carousel (Trailer + All Review Images) with smooth dark fade and bold title
  Widget _buildHeroCarousel(
    List<_HeroMediaSlide> slides,
    String movieTitle,
  ) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final int safeIndex =
        slides.isEmpty ? 0 : _currentSlideIndex.clamp(0, slides.length - 1);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (slides.isEmpty)
            Positioned.fill(child: _buildHeroImagePlaceholder())
          else
            Positioned.fill(
              child: PageView.builder(
                key: const Key('movie_review_hero_carousel'),
                controller: _heroPageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlideIndex = index;
                  });
                  if (index != 0 && _isPlayingTrailer) {
                    _stopTrailer();
                  }
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  if (slide.isTrailer) {
                    return _buildTrailerSlide(slide);
                  }
                  return GestureDetector(
                    key: Key('movie_review_image_slide_$index'),
                    onTap: () {
                      if (slide.imageUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreview(
                              imageUrl: slide.imageUrl,
                              title: movieTitle,
                            ),
                          ),
                        );
                      }
                    },
                    child: _buildNetworkSlideImage(slide.imageUrl),
                  );
                },
              ),
            ),

          // Gradient Shade Overlay (ignored for taps so images & trailer remain interactive)
          if (!_isPlayingTrailer)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        AppColorTokens.cinematicBackground.withValues(alpha: 0.7),
                        AppColorTokens.cinematicBackground,
                      ],
                      stops: const [0.0, 0.35, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // Carousel Dots + Stylized Bold Yellow Movie Title
          if (!_isPlayingTrailer)
            Positioned(
              bottom: 4.h,
              left: 12.w,
              right: 12.w,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (slides.length > 1)
                      Container(
                        key: const Key('movie_review_carousel_dots'),
                        margin: EdgeInsets.only(bottom: 4.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(slides.length, (i) {
                            final isActive = i == safeIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              width: isActive ? 16.w : 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColorTokens.cinemaRed
                                    : Colors.white.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          }),
                        ),
                      ),
                    if (movieTitle.isNotEmpty)
                      Text(
                        movieTitle.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.bebasNeue(
                          fontSize: isLandscape ? 24 : 42.sp,
                          color: AppColorTokens.movieTitleGold,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
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

  // Ratings Row
  Widget _buildOtherRatingsRow(Map<String, dynamic> article) {
    final List<Map<String, String>> platforms = [];

    final providerDetails = context.watch<RatingProvider>().movieReviewDetails;
    final rawRatings = article['externalRatings'] ??
        article['movie_platform_ratings'] ??
        providerDetails?.platformRatings;
    if (rawRatings != null && rawRatings is List && rawRatings.isNotEmpty) {
      for (var r in rawRatings) {
        if (r is PlatformRating) {
          platforms.add({
            'name': r.platformName.isNotEmpty ? r.platformName : 'Others',
            'rating': r.platformRating.isNotEmpty ? r.platformRating : '',
          });
        } else if (r is Map) {
          platforms.add({
            'name': (r['platform_name'] ??
                    r['platformName'] ??
                    r['name'] ??
                    'Others')
                .toString(),
            'rating': (r['platform_rating'] ??
                    r['platformRating'] ??
                    r['rating'] ??
                    '')
                .toString(),
          });
        }
      }
    }

    if (platforms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: platforms.asMap().entries.map((entry) {
        final index = entry.key;
        final p = entry.value;
        final isFirst = index == 0;
        final isLast = index == platforms.length - 1;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: isFirst
                  ? AppColorTokens.cinemaRed
                  : AppColorTokens.cinematicSurface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isFirst
                    ? AppColorTokens.cinemaRed
                    : const Color(0xFF2C2C36),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p['name'] ?? '',
                  style: TextStyle(
                    color: isFirst ? Colors.white : const Color(0xFF9CA3AF),
                    fontSize: 11.sp,
                    fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  p['rating'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // User Rating Card ("below review style")
  Widget _buildUserRatingCard() {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, _) {
        final articleId = widget.article?['id'];
        final postKey = articleId ?? 0;
        final isEditing = ratingProvider.isEditingForPost(postKey);
        final isSubmitting = ratingProvider.isSubmittingForPost(postKey);
        final commentController =
            ratingProvider.getCommentControllerForPost(postKey);

        final isVotedOrReviewed = widget.article?['userHasReviewed'] == true ||
            widget.article?['user_has_reviewed'] == true ||
            ratingProvider.isArticleRated(
              articleId is num
                  ? articleId.toInt()
                  : int.tryParse(articleId?.toString() ?? '0') ?? 0,
            );
        final currentRating = ratingProvider.getPostRating(postKey);
        final effectiveRating = currentRating > 0
            ? currentRating
            : ((widget.article?['userRating'] ??
                    widget.article?['user_rating'] ??
                    0) as num)
                .toInt();
        final dynamic reviewCount = widget.article?['reviewCount'] ??
            widget.article?['total_reviews'] ??
            ratingProvider.movieReviewDetails?.totalReviews;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColorTokens.cinematicCard,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFF24242D),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Green Checkmark or Star + Title + Edit/Review button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isVotedOrReviewed
                              ? Icons.check_circle_rounded
                              : Icons.stars_rounded,
                          color: isVotedOrReviewed
                              ? const Color(0xFF22C55E)
                              : AppColorTokens.cinemaRed,
                          size: 20.sp,
                        ),
                        SizedBox(width: 7.w),
                        Flexible(
                          child: Text(
                            isVotedOrReviewed
                                ? 'మీ రేటింగ్ సమర్పించబడింది!'
                                : 'మీ రేటింగ్ ఇవ్వండి',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () async {
                      if (!isEditing) {
                        final sp = await SharedPreferences.getInstance();
                        final bool isGuest =
                            sp.getString('loginType') != 'login';
                        if (isGuest) {
                          if (!context.mounted) return;
                          _showLoginDialog(articleId);
                          return;
                        }
                      }
                      ratingProvider.toggleEditingForPost(postKey);
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: AppColorTokens.error,
                            size: 18.sp,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            isEditing
                                ? 'రద్దు చేయండి'
                                : (isVotedOrReviewed
                                    ? 'సవరించండి'
                                    : 'సమీక్ష రాయండి'),
                            style: TextStyle(
                              color: AppColorTokens.error,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Star Rating & Score Row
              Row(
                children: [
                  ...List.generate(5, (index) {
                    final isFilled = index < effectiveRating;
                    return GestureDetector(
                      onTap: () async {
                        final sp = await SharedPreferences.getInstance();
                        final bool isGuest =
                            sp.getString('loginType') != 'login';
                        if (isGuest) {
                          if (!context.mounted) return;
                          _showLoginDialog(articleId);
                          return;
                        }

                        ratingProvider.ratingUpdate(index + 1, postKey);
                        if (!ratingProvider.isEditingForPost(postKey)) {
                          ratingProvider.setEditingForPost(postKey, true);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Icon(
                          Icons.star_rounded,
                          color: isFilled
                              ? AppColorTokens.ratingGold
                              : const Color(0xFF4B5563),
                          size: 28.sp,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 8.w),
                  Text(
                    '${effectiveRating.toStringAsFixed(1)}/5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (reviewCount != null &&
                      reviewCount.toString() != '0') ...[
                    SizedBox(width: 8.w),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          if (articleId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListReviews(
                                  postId: articleId.toString(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          '($reviewCount సమీక్షలు >)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColorTokens.error,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 6.h),

              // Nested Review Box: Either User Review Display or Edit Form
              if (isEditing) ...[
                TextFormField(
                  controller: commentController,
                  maxLines: 2,
                  style: TextStyle(color: Colors.white, fontSize: 12.5.sp),
                  decoration: InputDecoration(
                    hintText: 'మీ సమీక్షను ఇక్కడ రాయండి (తప్పనిసరి)...',
                    hintStyle:
                        TextStyle(color: Colors.white38, fontSize: 12.sp),
                    filled: true,
                    fillColor: AppColorTokens.cinematicSurface,
                    contentPadding: EdgeInsets.all(10.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: AppColorTokens.cinematicBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide:
                          const BorderSide(color: AppColorTokens.cinemaRed),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () async {
                    if (isSubmitting) return;

                    final sp = await SharedPreferences.getInstance();
                    final bool isGuest = sp.getString('loginType') != 'login';

                    if (isGuest) {
                      if (!context.mounted) return;
                      _showLoginDialog(articleId);
                      return;
                    }

                    await ratingProvider.submitReviewForArticle(
                      articleId: articleId,
                      userHasReviewed: widget.article?['userHasReviewed'],
                      title: widget.article?['title'],
                      fallbackRating: effectiveRating,
                    );
                  },
                  child: Container(
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColorTokens.cinemaRed,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'సమర్పించండి',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                _buildHorizontalComments(
                  ratingProvider,
                  effectiveRating,
                  articleId,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Horizontal scroll of review comments
  Widget _buildHorizontalComments(
    RatingProvider ratingProvider,
    int effectiveRating,
    dynamic articleId,
  ) {
    final List<Map<String, dynamic>> displayReviews = [];
    final String userComment = ratingProvider.getUserComment(articleId ?? 0);
    final String userName = ratingProvider.userName;

    // 1. Current user's comment (if they have submitted)
    if (userComment.isNotEmpty) {
      displayReviews.add({
        'name': userName.isNotEmpty ? userName : 'మీరు',
        'time': 'ఇప్పుడే',
        'rating': effectiveRating > 0 ? effectiveRating.toString() : '5',
        'comment': userComment,
        'isUser': true,
      });
    }

    // 2. Reviews from API cache
    final apiReviews =
        ratingProvider.getReviewsForPost((articleId ?? 0).toString());
    for (var review in apiReviews) {
      if (review is Map) {
        final c =
            (review['comment'] ?? review['review'] ?? '').toString().trim();
        if (c.isEmpty) continue;
        if (userComment.isNotEmpty && c == userComment) continue;

        final rUser = review['user'];
        String rName = 'యూజర్';
        if (rUser is Map &&
            rUser['name'] != null &&
            rUser['name'].toString().trim().isNotEmpty) {
          rName = rUser['name'].toString().trim();
        } else if (review['user_name'] != null &&
            review['user_name'].toString().trim().isNotEmpty) {
          rName = review['user_name'].toString().trim();
        } else if (review['userName'] != null &&
            review['userName'].toString().trim().isNotEmpty) {
          rName = review['userName'].toString().trim();
        } else if (review['name'] != null &&
            review['name'].toString().trim().isNotEmpty) {
          rName = review['name'].toString().trim();
        }

        final rRating =
            (review['rating'] ?? review['star_rating'] ?? '5').toString();
        final rTime = formatTimeDifference(
          (review['created_at'] ?? review['createdAt'] ?? '').toString(),
        );

        displayReviews.add({
          'name': rName,
          'time': rTime,
          'rating': rRating,
          'comment': c,
          'isUser': false,
        });
      }
    }

    if (displayReviews.isEmpty) {
      return Container(
        constraints: BoxConstraints(minHeight: 52.h),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColorTokens.cinematicSurface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFF2C2C36), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: const Color(0xFF9CA3AF),
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                'ఇంకా సమీక్షలు లేవు. మొదటి సమీక్షను రాయండి!',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
      height: isLandscape ? 96.0 : 88.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayReviews.length,
        separatorBuilder: (context, idx) => SizedBox(width: 8.w),
        itemBuilder: (context, idx) {
          final item = displayReviews[idx];
          final String name = item['name'] ?? 'యూజర్';
          final String time = item['time'] ?? '';
          final String rating = item['rating'] ?? '5';
          final String comment = item['comment'] ?? '';
          final bool isUser = item['isUser'] == true;
          final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return Container(
            width: 250.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColorTokens.cinematicSurface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isUser
                    ? AppColorTokens.cinemaRed.withValues(alpha: 0.6)
                    : const Color(0xFF2C2C36),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 11.r,
                      backgroundColor: isUser
                          ? AppColorTokens.cinemaRed
                          : const Color(0xFF374151),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isUser ? '$name (మీరు)' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUser
                                  ? const Color(0xFFF87171)
                                  : Colors.white,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (time.isNotEmpty)
                            Text(
                              time,
                              style: TextStyle(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 9.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorTokens.ratingGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColorTokens.ratingGold,
                            size: 12.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            rating,
                            style: TextStyle(
                              color: AppColorTokens.ratingGold,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFE5E7EB),
                      fontSize: 11.5.sp,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
