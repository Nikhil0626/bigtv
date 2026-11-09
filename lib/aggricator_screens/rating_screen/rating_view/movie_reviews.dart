import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../rating_model.dart';
import '../rating_provider/rating_provider.dart';
import 'list_reviews.dart';

class MovieRatings extends StatefulWidget {
  const MovieRatings({super.key, this.article});

  final dynamic article;

  @override
  State<MovieRatings> createState() => _MovieRatingsState();
}

class _MovieRatingsState extends State<MovieRatings> {
  final TextEditingController _commentController = TextEditingController();

  bool _isEditing = false;
  bool _isSubmitting = false;
  String _userName = "";
  String _userComment = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ratingProvider = context.read<RatingProvider>();
      ratingProvider.commentController.text = "";

      final articleId = widget.article?['id'];
      if (articleId != null) {
        ratingProvider.getReviews(articleId.toString(), 'newest');
      }

      final userHasReviewed = widget.article?['userHasReviewed'] == true ||
          widget.article?['user_has_reviewed'] == true;
      final existingRating = widget.article?['userRating'] ??
          widget.article?['user_rating'] ??
          0;

      if (userHasReviewed || ratingProvider.isArticleRated(articleId ?? 0)) {
        if (existingRating > 0) {
          ratingProvider.ratingUpdate(existingRating, articleId ?? 0, isNew: true);
        }
      }

      if (widget.article?['userComment'] != null &&
          widget.article['userComment'].toString().trim().isNotEmpty) {
        setState(() {
          _userComment = widget.article['userComment'].toString().trim();
        });
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final storedName = sp.getString("userName");
      if (storedName != null && storedName.trim().isNotEmpty) {
        setState(() {
          _userName = storedName.trim();
        });
      }
    } catch (e) {
      log("Error loading user data: $e");
    }
  }

  Future<void> _showLoginDialog() async {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: const Color(0xFF18181E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review_rounded,
                    color: const Color(0xFFE50914),
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  "లాగిన్ అవ్వండి",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "సినిమా రివ్యూ సమర్పించడానికి మరియు మీ రేటింగ్ ఇవ్వడానికి దయచేసి లాగిన్ అవ్వండి.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
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
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          "రద్దు",
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
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
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogCtx);
                          if (!mounted) return;
                          context.read<AuthenticationProvider>().newAppLoginStatus =
                              NewAppLoginStatus.login;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginBackgroundView(),
                            ),
                          );

                          if (!mounted) return;
                          final updatedSp = await SharedPreferences.getInstance();
                          final bool isNowLoggedIn =
                              updatedSp.getString("loginType") == "login";
                          if (isNowLoggedIn) {
                            await _loadUserData();
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        child: Text(
                          "లాగిన్",
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getImageUrl(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().trim().isEmpty) {
      return "";
    }
    String url = imageUrl.toString();
    if (url.startsWith('http')) {
      return url;
    }
    if (url.startsWith('/')) {
      return "https://migwp.chotanews.com$url";
    }
    return "https://migwp.chotanews.com/$url";
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article ?? {};
    final String movieTitle = (article['movie_name'] ??
            article['movieName'] ??
            article['title'] ??
            "")
        .toString();
    final String genreTelugu =
        (article['genre'] ?? article['genreTelugu'] ?? "").toString();
    final String certification =
        (article['certification'] ?? article['censor_rating'] ?? "").toString();
    final String metaInfo = (article['meta_info'] ??
            [
              article['genre_en'],
              article['genre_sub'],
              article['release_year'],
              article['duration']
            ]
                .where((e) => e != null && e.toString().trim().isNotEmpty)
                .join('  |  '))
        .toString();
    final String synopsis = (article['description'] ??
            article['content'] ??
            "")
        .toString();
    final String imageUrl = _getImageUrl(article['image_url'] ?? article['imageUrl']);

    final String chotaMeter = (article['chotaMeter'] ??
            article['chotarating'] ??
            article['critic_rating'] ??
            article['criticRating'] ??
            "")
        .toString()
        .trim();

    final bool hasBadges = genreTelugu.isNotEmpty ||
        certification.isNotEmpty ||
        (chotaMeter.isNotEmpty && chotaMeter != 'null');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F0F12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Hero Poster Section with title overlay
          _buildHeroPoster(imageUrl, movieTitle),

          // Movie Details, Ratings & User Review Card
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Badges Row (Genre + Certification + ChotaMeter Critic Badge)
                    if (hasBadges)
                      Row(
                        children: [
                          if (genreTelugu.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE50914),
                                borderRadius: BorderRadius.circular(16.r),
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
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E24),
                                border: Border.all(color: const Color(0xFF4B5563), width: 1),
                                borderRadius: BorderRadius.circular(16.r),
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
                          if (chotaMeter.isNotEmpty && chotaMeter != 'null') ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE50914), Color(0xFFB91C1C)],
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                                  SizedBox(width: 3.w),
                                  Text(
                                    "BIG TV $chotaMeter",
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
            ),
          ),
        ],
      ),
    );
  }

  // Hero Poster with smooth dark fade and bold title
  Widget _buildHeroPoster(String imageUrl, String movieTitle) {
    final posterHeight = MediaQuery.of(context).size.height * 0.33;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Image
        GestureDetector(
          onTap: () {
            if (imageUrl.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreview(
                    imageUrl: imageUrl,
                    title: movieTitle,
                  ),
                ),
              );
            }
          },
          child: SizedBox(
            height: posterHeight,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF1E1E24),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE50914),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF1A1A20),
                child: Center(
                  child: Icon(Icons.movie_rounded, size: 60.sp, color: Colors.white24),
                ),
              ),
            ),
          ),
        ),

        // Gradient Shade Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  const Color(0xFF0F0F12).withValues(alpha: 0.7),
                  const Color(0xFF0F0F12),
                ],
                stops: const [0.0, 0.35, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // Stylized Bold Yellow Movie Title ("IRUMUDI")
        Positioned(
          bottom: 2.h,
          child: Text(
            movieTitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              fontSize: 42.sp,
              color: const Color(0xFFFFD200),
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
        ),
      ],
    );
  }

  // Ratings Row
  Widget _buildOtherRatingsRow(Map<String, dynamic> article) {
    final List<Map<String, String>> platforms = [];

    final providerDetails = context.watch<RatingProvider>().movieReviewDetails;
    final rawRatings = article['externalRatings'] ??
        article['movie_platform_ratings'] ??
        providerDetails?.platformRatings;
    if (rawRatings != null &&
        rawRatings is List &&
        rawRatings.isNotEmpty) {
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
              color: isFirst ? const Color(0xFFE50914) : const Color(0xFF18181E),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isFirst
                    ? const Color(0xFFE50914)
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
        final isVotedOrReviewed = widget.article?['userHasReviewed'] == true ||
            widget.article?['user_has_reviewed'] == true ||
            ratingProvider.isArticleRated(articleId ?? 0);
        final currentRating = ratingProvider.getPostRating(articleId ?? 0);
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF16161B),
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
                  Row(
                    children: [
                      Icon(
                        isVotedOrReviewed
                            ? Icons.check_circle_rounded
                            : Icons.stars_rounded,
                        color: isVotedOrReviewed
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE50914),
                        size: 20.sp,
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        isVotedOrReviewed
                            ? "మీ రేటింగ్ సమర్పించబడింది!"
                            : "మీ రేటింగ్ ఇవ్వండి",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      if (!_isEditing) {
                        final sp = await SharedPreferences.getInstance();
                        final bool isGuest = sp.getString("loginType") != "login";
                        if (isGuest) {
                          _showLoginDialog();
                          return;
                        }
                      }
                      setState(() {
                        _isEditing = !_isEditing;
                        if (_isEditing) {
                          _commentController.text = _userComment;
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: const Color(0xFFEF4444),
                            size: 18.sp,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            _isEditing
                                ? "రద్దు చేయండి"
                                : (isVotedOrReviewed ? "సవరించండి" : "సమీక్ష రాయండి"),
                            style: TextStyle(
                              color: const Color(0xFFEF4444),
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

              SizedBox(height: 8.h),

              // Star Rating & Score Row
              Row(
                children: [
                  ...List.generate(5, (index) {
                    final isFilled = index < effectiveRating;
                    return GestureDetector(
                      onTap: () async {
                        final sp = await SharedPreferences.getInstance();
                        final bool isGuest = sp.getString("loginType") != "login";
                        if (isGuest) {
                          _showLoginDialog();
                          return;
                        }

                        ratingProvider.ratingUpdate(index + 1, articleId ?? 0);
                        if (!_isEditing) {
                          setState(() {
                            _isEditing = true;
                            if (_userComment.isNotEmpty) {
                              _commentController.text = _userComment;
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Icon(
                          Icons.star_rounded,
                          color: isFilled
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF4B5563),
                          size: 28.sp,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 8.w),
                  Text(
                    "${effectiveRating.toStringAsFixed(1)}/5",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (reviewCount != null && reviewCount.toString() != "0") ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        if (articleId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListReviews(postId: articleId.toString()),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "($reviewCount సమీక్షలు >)",
                        style: TextStyle(
                          color: const Color(0xFFEF4444),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 8.h),

              // Nested Review Box: Either User Review Display or Edit Form
              if (_isEditing) ...[
                TextFormField(
                  controller: _commentController,
                  maxLines: 2,
                  style: TextStyle(color: Colors.white, fontSize: 12.5.sp),
                  decoration: InputDecoration(
                    hintText: "మీ సమీక్షను ఇక్కడ రాయండి (తప్పనిసరి)...",
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 12.sp),
                    filled: true,
                    fillColor: const Color(0xFF1E1E24),
                    contentPadding: EdgeInsets.all(10.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF33333E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFE50914)),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () async {
                    if (_isSubmitting) return;

                    final sp = await SharedPreferences.getInstance();
                    final bool isGuest = sp.getString("loginType") != "login";

                    if (isGuest) {
                      _showLoginDialog();
                      return;
                    }

                    final commentText = _commentController.text.trim();
                    if (commentText.isEmpty) {
                      CustomToast.showErrorToast(
                        msg: "దయచేసి మీ సమీక్షను/కామెంట్‌ను నమోదు చేయండి",
                      );
                      return;
                    }

                    final selectedRating = ratingProvider.getPostRating(articleId ?? 0);
                    if (selectedRating <= 0 && effectiveRating <= 0) {
                      CustomToast.showErrorToast(
                        msg: "దయచేసి రేటింగ్ ఎంచుకోండి",
                      );
                      return;
                    }

                    setState(() {
                      _isSubmitting = true;
                    });

                    ratingProvider.commentController.text = commentText;
                    final bool success = await ratingProvider.postSubmitRating(
                      articleId ?? 0,
                      widget.article?['userHasReviewed'],
                      widget.article?['title'],
                    );

                    if (success) {
                      final nowStr = DateTime.now().toUtc().toIso8601String();
                      ratingProvider.addLocalReview(
                        (articleId ?? 0).toString(),
                        {
                          'user': {'name': _userName.isNotEmpty ? _userName : 'మీరు'},
                          'comment': commentText,
                          'rating': selectedRating > 0 ? selectedRating : effectiveRating,
                          'created_at': nowStr,
                        },
                      );

                      if (articleId != null) {
                        await ratingProvider.getReviews(articleId.toString(), 'newest');
                      }

                      if (mounted) {
                        setState(() {
                          _userComment = commentText;
                          _isEditing = false;
                          _isSubmitting = false;
                        });
                      }
                    } else {
                      if (mounted) {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "సమర్పించండి",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                _buildHorizontalComments(ratingProvider, effectiveRating, articleId),
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

    // 1. Current user's comment (if they have submitted)
    if (_userComment.isNotEmpty) {
      displayReviews.add({
        'name': _userName.isNotEmpty ? _userName : "మీరు",
        'time': "ఇప్పుడే",
        'rating': effectiveRating > 0 ? effectiveRating.toString() : "5",
        'comment': _userComment,
        'isUser': true,
      });
    }

    // 2. Reviews from API cache
    final apiReviews = ratingProvider.getReviewsForPost((articleId ?? 0).toString());
    for (var review in apiReviews) {
      if (review is Map) {
        final c = (review['comment'] ?? review['review'] ?? '').toString().trim();
        if (c.isEmpty) continue;
        if (_userComment.isNotEmpty && c == _userComment) continue;

        final rUser = review['user'];
        String rName = "యూజర్";
        if (rUser is Map && rUser['name'] != null && rUser['name'].toString().trim().isNotEmpty) {
          rName = rUser['name'].toString().trim();
        } else if (review['user_name'] != null && review['user_name'].toString().trim().isNotEmpty) {
          rName = review['user_name'].toString().trim();
        } else if (review['userName'] != null && review['userName'].toString().trim().isNotEmpty) {
          rName = review['userName'].toString().trim();
        } else if (review['name'] != null && review['name'].toString().trim().isNotEmpty) {
          rName = review['name'].toString().trim();
        }

        final rRating = (review['rating'] ?? review['star_rating'] ?? '5').toString();
        final rTime = formatTimeDifference((review['created_at'] ?? review['createdAt'] ?? '').toString());

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
        height: 52.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFF2C2C36), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, color: const Color(0xFF9CA3AF), size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              "ఇంకా సమీక్షలు లేవు. మొదటి సమీక్షను రాయండి!",
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 76.h,
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
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isUser
                    ? const Color(0xFFE50914).withValues(alpha: 0.6)
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
                          ? const Color(0xFFE50914)
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
                            isUser ? "$name (మీరు)" : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUser ? const Color(0xFFF87171) : Colors.white,
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
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFBBF24),
                            size: 12.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            rating,
                            style: TextStyle(
                              color: const Color(0xFFFBBF24),
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFFE5E7EB),
                    fontSize: 11.5.sp,
                    height: 1.25,
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
