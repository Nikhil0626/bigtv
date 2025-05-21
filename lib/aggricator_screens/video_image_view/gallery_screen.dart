import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import '../../../aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import '../../../globel_keys/app_router.dart';
import '../../../services/image_to_pdf_helper.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/commant_screen.dart';

import '../botton_actions.dart';
import '../event_repo.dart';


class FullPageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  final String className;
  final postDetails;
  final bool isHome;

  const FullPageCarousel(
      {super.key,
      required this.imageUrls,
      this.className = "",
      required this.postDetails,
      this.isHome = false});

  @override
  _FullPageCarouselState createState() => _FullPageCarouselState();
}

class _FullPageCarouselState extends State<FullPageCarousel> {
  int _currentIndex = 0;
ScreenshotController sc = ScreenshotController();
  final CarouselSliderController _controller = CarouselSliderController();
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    // Animate first image swipe after a short delay
    // Future.delayed(const Duration(seconds: 1), () {
    //   _controller.animateToPage(1,
    //       duration: const Duration(milliseconds: 800),
    //       curve: Curves.easeInOut);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final displayFeatures = MediaQuery.of(context).displayFeatures;
    bool isFoldable = displayFeatures.isNotEmpty;

    print(widget.imageUrls.length);
    return Scaffold(
      appBar: widget.className == ""
          ? null
          : AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context, RoutesManager.getAllMenuItemScreen);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              backgroundColor: AppColors.appButtonColor,
              title: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  widget.className,
                  style: fontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: Screenshot(
                  controller: sc,
                  child: CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: true,
                      autoPlay: false,
                      // autoPlayInterval: const Duration(seconds: 3),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      scrollPhysics: const BouncingScrollPhysics(),
                      enlargeCenterPage: true,
                    ),
                    items: widget.imageUrls.map((image) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,

                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(image['Url'],),
                            fit: isFoldable?BoxFit.fill:BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            isAntiAlias: true,

                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if(!widget.isHome)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.sp, vertical: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                      return BottomActions(
                        iconColor: AppColors.iconColors,
                        postType: widget.postDetails['subType'].toString() ?? "",
                        icon: settingsProvider.isLikeList.contains(widget.postDetails['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                        label: 'లైక్',
                        isLike: settingsProvider.isLikeList.contains(widget.postDetails['id'].toString()),
                        onTap: () {
                          log("Like");
                          settingsProvider.isLikePost(widget.postDetails);
                        },
                      );
                    }),
                    BottomActions(
                      postType: widget.postDetails['subType'] ?? "",
                      icon: "assets/svg/new_comment.svg",
                      label: 'కామెంట్',
                      iconColor: AppColors.iconColors,
                      onTap: () async{
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        String? userId = sp.getString("userId");
                        String? deviceId = sp.getString("deviceId");
                        context.read<AuthenticationProvider>().sendEvent("CommentPage");
                        EventRepo().sendEvent({
                          "key": "comments",
                          "data": {
                            "device_id": "$deviceId",
                            "userId":userId ?? "",
                            "postId": widget.postDetails['id'].toString(),
                          }
                        });
                        showComments(context, widget.postDetails['id']);
                        EventRepo().sendEvent({
                          "key": "comments",
                          "data": {"deviceId": deviceId, "openTime": DateTime.now().toString()}
                        });
                      },
                    ),
                    Spacer(),
                    BottomActions(
                      postType: widget.postDetails['subType'] ?? "",
                      icon: "assets/svg/share.svg",
                      label: 'షేర్',
                      iconColor: AppColors.iconColors,
                      onTap: () async {
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        String? userId = sp.getString("userId");
                        String? deviceId = sp.getString("deviceId");
                        EventRepo().sendEvent({
                          "key": "share_via_articles",
                          "data": {
                            "device_id": "$deviceId",
                            "userId": userId?? "",
                            "postId": widget.postDetails['id'].toString(),
                            "isWhatAppShare": false,
                            "source_from":"news"
                          }
                        });

                        sendShareDetails(userId, widget.postDetails['id'], widget.postDetails['content'].toString());

                        if (widget.postDetails['type'] == "Standard" || widget.postDetails['type'] == "Video") {
                          try {
                            final image = await sc.capture(
                              pixelRatio: 2,
                            );
                            if (image != null) {
                              final directory = await getTemporaryDirectory();
                              final imagePath = '${directory.path}/${widget.postDetails['id']}.png';
                              final imageFile = File(imagePath);
                              await imageFile.writeAsBytes(image);

                              Share.shareXFiles([XFile(imageFile.path)], text: Platform.isIOS ? widget.postDetails['linkURLAndroid'].toString() : widget.postDetails['linkURLIos'].toString());
                            } else {
                              CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                            }
                          } catch (e) {
                            CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                          }
                        } else if (widget.postDetails['type'] == "Gallery") {
                          createAndSharePdf(context, widget.postDetails);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: widget.isHome ?Platform.isIOS? 45:20 : Platform.isIOS? 95:70+MediaQuery.of(context).padding.bottom+5,
            child:

            AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: widget.imageUrls.length,
              effect: ExpandingDotsEffect(
                dotHeight: 7,
                dotWidth: 7,
                activeDotColor: Colors.cyan.withOpacity(.3),
                dotColor: Colors.grey.shade400,
              ),
              onDotClicked: (index) {
                _controller.jumpToPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
