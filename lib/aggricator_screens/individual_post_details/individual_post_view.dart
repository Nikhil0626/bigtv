import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/bulletin_view.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/image_post_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/utils/translated_text.dart';
import 'package:flutter_svg/svg.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/in_app_web_view.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import '../video_image_screen/gallery_screen.dart';
import '../video_image_screen/video_preview.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../events_data/event_repo.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_byts_view.dart';

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

  bool _is70PercentPost(dynamic article) {
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

  @override
  void initState() {
    log("is come from lin----k ${widget.postId}");
    getWebData();
    context.read<HomeProvider>().getIndividualPost(widget.postId, isAds: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      final articleFromProvider = homeProvider.getSinglePostList.isEmpty ? <String, dynamic>{} : Map<String, dynamic>.from(homeProvider.getSinglePostList);
      final article = articleFromProvider.isNotEmpty ? articleFromProvider : (widget.initialArticle ?? <String, dynamic>{});

      return PopScope(
        canPop: true,
        child: Scaffold(
          backgroundColor: _getPostBackgroundColor(article, context),
          body: SafeArea(
            top: true,
            bottom: false,
            child: homeProvider.isPostLoading && article.isEmpty
                ? const AppLoadingScreen()
                : article.isEmpty
                    ? const AppNoData()
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
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
                                  Navigator.pop(context);
                                  context.read<HomeProvider>().sendAdsDataSend(
                                      article['id'], article['title'], article['image_url'], false, article['postUrl']);
                                }
                              }
                            },
                            child: Stack(
                              children: [
                                (article['image_url'] is List)
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
                                Positioned(
                                  top: 40,
                                  left: 30,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      height: 40,
                                      width: 40,
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              MainScreenBytView(
                                article: Map<String, dynamic>.from(article),
                                isMainScreen: true,
                              ),
                              Positioned(
                                top: 12,
                                left: 14,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
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
                        (article['links'] != null && (article['links'] as List).isNotEmpty)
                            ? RichText(
                                text: TextSpan(
                                  children: _parseText(
                                    context, 
                                    article['content'] ?? "", 
                                    article['links'], 
                                    {'subType': 'Standard'}
                                  ),
                                ),
                              )
                            : TranslatedText(
                                article['content'] ?? "",
                                translate: context.watch<HomeProvider>().isEnglishMode,
                                style: homeScreenFontStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.path}';
    }
  }
}