import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/image_post_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/utils/translated_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/in_app_web_view.dart';
import '../video_image_screen/video_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_toasts.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_byts_view.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/main.dart';

class IndividualPostView1 extends StatefulWidget {
  final String postId;
  final bool isComeFrom;
  final Map<String, dynamic>? initialArticle;

  const IndividualPostView1({
    super.key,
    required this.postId,
    this.isComeFrom = false,
    this.initialArticle,
  });

  @override
  State<IndividualPostView1> createState() => _IndividualPostView1State();
}

class _IndividualPostView1State extends State<IndividualPostView1> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  Color _getPostBackgroundColor(dynamic article, BuildContext context) {
    if (article == null || article is! Map) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white;
    }
    final type = article['type']?.toString().toLowerCase() ?? '';
    final postType = article['post_type']?.toString().toLowerCase() ?? '';
    final subType = article['subType']?.toString().toLowerCase() ?? '';

    final isBigTvSpecial = type == 'bigtvspecial' ||
        postType == 'bigtvspecial' ||
        subType == 'bigtvspecial';

    if (isBigTvSpecial || article['colorCode'] != null) {
      final parsed = _parseHexColor(article['colorCode']);
      if (parsed != null) {
        return parsed;
      }
    }

    if (_isBigBlackStandard(article)) {
      return Colors.black;
    }

    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }

  Color? _parseHexColor(dynamic hexString) {
    if (hexString == null) return null;
    String str = hexString.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'string') return null;
    str = str.replaceAll('#', '');
    if (str.length == 6) {
      str = 'FF$str';
    }
    final intVal = int.tryParse(str, radix: 16);
    if (intVal != null) {
      return Color(intVal);
    }
    return null;
  }

  bool _isDarkBg(dynamic article, BuildContext context) {
    return _getPostBackgroundColor(article, context).computeLuminance() < 0.5;
  }

  bool _isBigTvSpecial(dynamic article) {
    if (article == null || article is! Map) return false;
    final type = article['type']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    final postType = article['post_type']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    final subType = article['subType']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';

    return type == 'bigtvspecial' ||
        postType == 'bigtvspecial' ||
        subType == 'bigtvspecial';
  }

  bool _isBigBlackStandard(dynamic article) {
    if (article == null || article is! Map) return false;
    final type = article['type']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    final postType = article['post_type']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    final subType = article['subType']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';

    return type == 'bigblackstandard' ||
        postType == 'bigblackstandard' ||
        subType == 'bigblackstandard';
  }

  bool _is50PercentPost(dynamic article) {
    if (article == null || article is! Map) return false;
    return _isBigTvSpecial(article) || _isBigBlackStandard(article);
  }

  bool _isBulletinPost(dynamic article) {
    if (article == null || article is! Map) return false;
    final type = article['type']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    final postType = article['post_type']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    final subType = article['subType']?.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';

    return type == 'bulletin' ||
        postType == 'bulletin' ||
        subType == 'bulletin' ||
        type == 'bulletpost' ||
        postType == 'bulletpost' ||
        subType == 'bulletpost';
  }

  void _stopVideoPlayback() {
    try {
      final homeProvider = context.read<HomeProvider>();
      if (homeProvider.isPlaying) {
        homeProvider.isPlayingYoutube(false);
      }
    } catch (_) {}
    try {
      final videoProvider = context.read<VideoProvider>();
      if (videoProvider.isPlaying) {
        videoProvider.pauseVideo();
      }
    } catch (_) {}
  }

  bool _isNavigatingBack = false;
  bool _hasCleanedUp = false;
  bool _hasHandledFailure = false;
  bool _hasStartedFetch = false;
  Timer? _watchdogTimer;

  void _onPostApiFailed() {
    _watchdogTimer?.cancel();
    if (_isNavigatingBack || !mounted) return;
    _hasHandledFailure = true;

    try {
      CustomToast.showErrorToast(
        msg: "Failed to load post",
        timeDuration: 2,
      );
    } catch (e) {
      debugPrint("Error showing toast: $e");
    }

    _handleBackNavigation();
  }

  void _cleanupAndRestoreHome([HomeProvider? provider]) {
    _watchdogTimer?.cancel();
    if (_hasCleanedUp) return;
    _hasCleanedUp = true;

    _stopVideoPlayback();

    if (Platform.isAndroid) {
      try {
        const MethodChannel("com.chotanews/whatsapp").invokeMethod("clearInitialIntent");
      } catch (_) {}
    }

    try {
      HomeProvider? hp = provider;
      if (hp == null && mounted) {
        try {
          hp = context.read<HomeProvider>();
        } catch (_) {}
      }
      hp ??= mainNavigatorKey.currentContext?.read<HomeProvider>();

      if (hp != null) {
        hp.handleReturnFromNotificationPost(forceRefresh: true);
      }
    } catch (e) {
      log("Error during _cleanupAndRestoreHome: $e");
    }
  }

  void _handleBackNavigation() {
    _watchdogTimer?.cancel();
    if (_isNavigatingBack) return;
    _isNavigatingBack = true;

    HomeProvider? hp;
    try {
      hp = context.read<HomeProvider>();
    } catch (_) {}

    _cleanupAndRestoreHome(hp);

    final nav = Navigator.of(context);
    final mainNav = mainNavigatorKey.currentState;

    try {
      if (nav.canPop()) {
        nav.pop();
      } else if (mainNav != null && mainNav.canPop()) {
        mainNav.pop();
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error popping from IndividualPostView1: $e");
      _isNavigatingBack = false;
      try {
        mainNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeView()),
          (route) => false,
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    _cleanupAndRestoreHome();
    super.dispose();
  }

  @override
  void initState() {
    log("is come from lin----k ${widget.postId}");
    super.initState();
    getWebData();

    // 4-second watchdog timer: If article never loads, fail gracefully back to Home
    _watchdogTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_hasHandledFailure && !_isNavigatingBack) {
        final home = context.read<HomeProvider>();
        final requestedId = widget.postId.trim();
        final currentLoadedId = (home.getSinglePostList['id'] ??
                home.getSinglePostList['postId'] ??
                home.getSinglePostList['post_id'] ??
                home.getSinglePostList['_id'])
            ?.toString()
            .trim();
        if (home.getSinglePostList.isEmpty || currentLoadedId != requestedId) {
          debugPrint("Watchdog timed out waiting for post $requestedId - falling back to Home");
          _onPostApiFailed();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _hasStartedFetch = true;
      final home = context.read<HomeProvider>();
      final requestedId = widget.postId.trim();
      final currentLoadedId = (home.getSinglePostList['id'] ??
              home.getSinglePostList['postId'] ??
              home.getSinglePostList['post_id'] ??
              home.getSinglePostList['_id'])
          ?.toString()
          .trim();
      if (home.getSinglePostList.isEmpty || currentLoadedId != requestedId) {
        final success = await home.getIndividualPost(widget.postId, isAds: true);
        if (!success && mounted && !_hasHandledFailure) {
          _onPostApiFailed();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      final currentPostId = widget.postId.trim();
      final singleId = (homeProvider.getSinglePostList['id'] ??
              homeProvider.getSinglePostList['postId'] ??
              homeProvider.getSinglePostList['post_id'] ??
              homeProvider.getSinglePostList['_id'])
          ?.toString()
          .trim();
      final matchesRequestedPost = homeProvider.getSinglePostList.isNotEmpty &&
          (singleId == currentPostId || singleId == null || currentPostId.isEmpty);
      final articleFromProvider = matchesRequestedPost
          ? Map<String, dynamic>.from(homeProvider.getSinglePostList)
          : <String, dynamic>{};
      final article = articleFromProvider.isNotEmpty
          ? articleFromProvider
          : (widget.initialArticle ?? <String, dynamic>{});

      if (article.isNotEmpty) {
        _watchdogTimer?.cancel();
      }

      if (!_hasHandledFailure &&
          !_isNavigatingBack &&
          (homeProvider.isPostError ||
              (_hasStartedFetch &&
                  !homeProvider.isPostLoading &&
                  article.isEmpty))) {
        _hasHandledFailure = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onPostApiFailed();
          }
        });
      }

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColorTokens.primaryRed,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            _cleanupAndRestoreHome();
          },
          child: Scaffold(
            backgroundColor: _getPostBackgroundColor(article, context),
            body: Column(
              children: [
                Container(
                  color: AppColorTokens.primaryRed,
                  height: MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      article.isEmpty
                          ? const AppLoadingScreen()
                          : SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: Screenshot(
                                controller: adsScreenshotController,
                                child: article['type'].toString() == "WebUrl"
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InAppWebViewScreen(
                                          webUrl: context.read<HomeProvider>().webUrl.toString(),
                                          title: '',
                                        ),
                                      )
                                    : (article['type'] == "Image" && article['subType'] == "ImageAd")
                                        ? InkWell(
                                            onTap: () async {
                                              SharedPreferences sp = await SharedPreferences.getInstance();
                                              bool isLogin = sp.getString("loginType") != "login" ? true : false;
                                              if (isLogin) {
                                                CustomToast.showErrorToast(msg: "Your a guest user, Please Login to Join Contest");
                                              } else {
                                                if (article['postUrl'] != "" && article['postUrl'] != null) {
                                                  _stopVideoPlayback();
                                                  Navigator.pop(context);
                                                  context.read<HomeProvider>().sendAdsDataSend(
                                                      article['id'], article['title'], article['image_url'], false, article['postUrl']);
                                                }
                                              }
                                            },
                                            child: (article['image_url'] is List)
                                                ? (article['image_url'].length == 1
                                                    ? Image.network(
                                                        article['image_url'][0] ?? "",
                                                        width: MediaQuery.of(context).size.width,
                                                        height: MediaQuery.of(context).size.height,
                                                        fit: BoxFit.fill,
                                                        errorBuilder: (context, error, stackTrace) => Image.asset(
                                                          "assets/images/bigtv_default_post.png",
                                                          width: MediaQuery.of(context).size.width,
                                                          height: MediaQuery.of(context).size.height,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : ImagePostSlider(
                                                        imageUrl: article['image_url'],
                                                      ))
                                                : Image.network(
                                                    article['image_url'] ?? "",
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height,
                                                    fit: BoxFit.fill,
                                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                                      "assets/images/bigtv_default_post.png",
                                                      width: MediaQuery.of(context).size.width,
                                                      height: MediaQuery.of(context).size.height,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          )
                                        : MainScreenBytView(
                                            article: Map<String, dynamic>.from(article),
                                            isMainScreen: true,
                                          ),
                              ),
                            ),
                      // Top-level, high-priority back button overlay accessible across all post states
                      Positioned(
                        top: 8,
                        left: 10,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _handleBackNavigation,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: _handleBackNavigation,
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showBottomSheet(BuildContext context, dynamic article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          "assets/images/BigTvPostLogo.png",
                          height: 30.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            "News Details",
                            style: homeScreenFontStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['image_url'] != null && article['image_url'].toString().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: CachedNetworkImage(
                              imageUrl: (article['image_url'].toString().startsWith('http'))
                                  ? article['image_url']
                                  : "https://migwp.chotanews.com/${article['image_url']}",
                              width: double.infinity,
                              height: 250.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.borderColor.withValues(alpha: .2),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/bigtv_default_post.png",
                                width: double.infinity,
                                height: 250.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),
                        TranslatedText(
                          article['title'] ?? "",
                          translate: context.watch<HomeProvider>().isEnglishMode,
                          style: homeScreenFontStyle(
                            color: AppColorTokens.primaryRed,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: (article['links'] != null && (article['links'] as List).isNotEmpty)
                              ? RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: _parseText(
                                      context, 
                                      (article['content']?.toString() ?? "").replaceAll(RegExp(r" {2,}"), " "), 
                                      article['links'], 
                                      {'subType': 'Standard'}
                                    ),
                                  ),
                                )
                              : TranslatedText(
                                  (article['content']?.toString() ?? "").replaceAll(RegExp(r" {2,}"), " "),
                                  textAlign: TextAlign.start,
                                  translate: context.watch<HomeProvider>().isEnglishMode,
                                  style: homeScreenFontStyle(
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                  ),
                                ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<TextSpan> _parseText(BuildContext context, String text, links, article) {
    RegExp linkRegExp = RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];
    final isDark = _isDarkBg(article, context);

    text.splitMapJoin(linkRegExp, onMatch: (match) {
      String link = match.group(0)!;

      if (link.contains('<link1>') && links != null && links.isNotEmpty) {
        link = links[0]['value'].toString();
      } else if (link.contains('<link2>') && links != null && links.length > 1) {
        link = links[1]['value'].toString();
      } else if (link.contains('<link3>') && links != null && links.length > 2) {
        link = links[2]['value'].toString();
      } else {
        link = link;
      }
      spans.add(TextSpan(
          text: match
              .group(0)
              .toString()
              .replaceFirst('<link1>', '')
              .replaceFirst('</link1>', '')
              .replaceFirst('<link2>', '')
              .replaceFirst('</link2>', '')
              .replaceFirst('<link3>', '')
              .replaceFirst('</link3>', ''),
          style: homeScreenFontStyle(
            color: _isBigBlackStandard(article) ? Colors.white : (isDark ? Colors.blue.shade200 : Colors.blue),
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              log("Launching URL: $link");
              launchURL(Uri.parse(link.toString()));
            }));

      return "";
    }, onNonMatch: (nonMatch) {
      spans.add(TextSpan(
          text: nonMatch,
          style: homeScreenFontStyle(
            color: _isBigBlackStandard(article) ? AppColors.cardBackgroundColor : (isDark ? Colors.white : AppColors.textColor.withValues(alpha: 0.8)),
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
          )));
      return "";
    });

    return spans;
  }

  void getWebData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("webPostId", "");
  }

  Future<void> launchURL(Uri uri) async {
    final String urlStr = uri.toString().toLowerCase();
    final bool isEventsLink = urlStr.contains('events') ||
        urlStr.contains('folknight') ||
        urlStr.contains('folk') ||
        uri.queryParameters.containsKey('eventId');

    if (isEventsLink && mounted) {
      final homeProvider = context.read<HomeProvider>();
      if (!homeProvider.folkNight) {
        log("Events link tapped in post but folkNight config is false. Not opening link: $uri");
        return;
      }
    }

    if (urlStr.contains('bigtv24x7.com') ||
        urlStr.contains('bigtvlive.com') ||
        urlStr.contains('livebigtv') ||
        urlStr.contains('videotag') ||
        urlStr.contains('folknight') ||
        urlStr.contains('epaper') ||
        urlStr.contains('events') ||
        urlStr.contains('postid=') ||
        urlStr.contains('/posts/')) {
      if (mounted) {
        context.read<HomeProvider>().routeDeepLink(uri);
        return;
      }
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.path}';
    }
  }
}