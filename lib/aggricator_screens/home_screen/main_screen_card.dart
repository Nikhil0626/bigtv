import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/standard_post_view.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/botton_actions.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../screens/home_screen/home_screens/google_ads_view.dart';
import '../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../screens/videos_main/video_views/gallery_screen.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import 'ai_tag_posts_pageview.dart';
import 'image_view.dart';
import 'main_screen_pageview.dart';

class MainScreenCard extends StatefulWidget {
  const MainScreenCard({super.key});

  @override
  State<MainScreenCard> createState() => _MainScreenCardState();
}

class _MainScreenCardState extends State<MainScreenCard> {
  final CardSwiperController controller = CardSwiperController();

  double dragOffset = 0.0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    context.read<HomeProvider>().getAllPostList = [];
    context.read<HomeProvider>().getAllAiTags();
    context.read<HomeProvider>().getAllPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<HomeProvider, SettingsProvider>(builder: (_, homeProvider, settingsProvider, __) {
        return SizedBox(
          width: MediaQuery.of(context).size.width.w,
          height: MediaQuery.of(context).size.height - 150.h,
          child: Center(
            child: homeProvider.isHomeLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: CardSwiper(
                      allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                      controller: controller,
                      // Assign the controller
                      cardsCount: 5,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        print("Swiped from $previousIndex to $currentIndex");
                        return true;
                      },
                      numberOfCardsDisplayed: 4,
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        return ShimmerCard();
                      },
                    ),
                  )
                : homeProvider.getAllPostList.isEmpty
                    ? AppNoData()
                    : Column(
                        children: [
                          Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              // color: Colors.greenAccent,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: homeProvider.getAllAiTagsList.length,
                                itemBuilder: (context, index) {

                                  return Container(
                                    color: Colors.white,
                                    child: InkWell(
                                      onTap: (){
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => AiTagPostsPageView(
                                          isAiTags: true,
                                           tagName: homeProvider.getAllAiTagsList[index]['aitagname'].toString(),
                                            tagId: homeProvider.getAllAiTagsList[index]['aitagid'].toString(),
                                        ),
                                        ));

                                      },
                                      child: Container(
                                        height: 30.h,
                                        margin: EdgeInsets.symmetric(horizontal: 6.w,vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBackgroundColor,
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                                          child: Text(
                                            homeProvider.getAllAiTagsList[index]['aitagname'].toString(),
                                            textAlign: TextAlign.center,
                                            style: homeScreenFontStyle(
                                              color: AppColors.textColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )),
                          Expanded(
                            child: GestureDetector(
                              // onVerticalDragUpdate: (details) {
                              //   setState(() {
                              //     dragOffset += details.delta.dy;
                              //   });
                              // },
                              // onVerticalDragEnd: (details) {
                              //   if (details.velocity.pixelsPerSecond.dy > 0) {
                              //     controller.undo();
                              //   } else if (details.velocity.pixelsPerSecond.dy < 0) {
                              //     controller.swipe(CardSwiperDirection.top);
                              //   }
                              //   setState(() {
                              //     dragOffset = 0.0; // Reset after action
                              //   });
                              // },
                              child: CardSwiper(
                                allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                                controller: controller,
                                cardsCount: homeProvider.getAllPostList.length,
                                numberOfCardsDisplayed: 4,
                                onSwipe: (previousIndex, currentIndex, direction) {
                                  if(homeProvider.getAllPostList.length-5 ==currentIndex){
                                    log("last post   ${homeProvider.getAllPostList[int.parse(currentIndex.toString())]["id"]}");
                                    context.read<HomeProvider>().getAllPost(postId: homeProvider.getAllPostList.last["id"].toString());
                                  }
                                  return true;
                                },
                                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainScreenPageView(
                                              startIndex: index,
                                            ),
                                          ));
                                      if (homeProvider.getAllPostList[index]['type'].toString() == "Video") {
                                        homeProvider.youtubeDispose();
                                      }
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBackgroundColor,
                                          borderRadius: BorderRadius.circular(20.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 6,
                                              spreadRadius: 2,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: homeProvider.isWebView==true
                                            ? Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: InAppWebViewScreen(
                                                  webUrl: homeProvider.webUrl.toString(),
                                                  title: '',
                                                ),
                                              )
                                            : homeProvider.getAllPostList[index]['type'].toString() == "GoogleAds"
                                                ? Padding(
                                                    padding: const EdgeInsets.only(bottom: 20.0),
                                                    child: GoogleAdsView(
                                                      isList: true,
                                                      article: homeProvider.getAllPostList[index],
                                                      flipProvider: homeProvider,
                                                      // screenshotController: adsScreenshotController,
                                                      isFoldable: false,
                                                    ),
                                                  )
                                                : homeProvider.getAllPostList[index]['type'].toString() == "Image"
                                                    ? ImageView(index: index,getAllPostList: homeProvider.getAllPostList,)
                                                    : homeProvider.getAllPostList[index]['type'].toString() == "Gallery"
                                                        ? Padding(
                                                            padding: const EdgeInsets.only(bottom: 5.0),
                                                            child: Stack(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(12),
                                                                  ),
                                                                  child: FullPageCarousel(
                                                                    isHome: false,
                                                                    imageUrls: homeProvider.getAllPostList[index]['gallery'] ?? [],
                                                                    postDetails: homeProvider.getAllPostList[index],
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: 18,
                                                                  right: 22,
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      context.read<SettingsProvider>().saveBookmarks(
                                                                            homeProvider.getAllPostList[index]['id'].toString(),context
                                                                          );
                                                                      print("");
                                                                    },
                                                                    child: Container(
                                                                      padding: EdgeInsets.all(7),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.black54,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: Icon(
                                                                        Icons.bookmark_outline,
                                                                        color: Colors.white,
                                                                        size: 20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          )
                                                        : StandardCard(
                                                            getAllPostList: homeProvider.getAllPostList[index],
                                          index: index,
                                                          )),
                                  );
                                },
                              ),
                            ),
                          ),
                          height(height: 20)
                        ],
                      ),
          ),
        );
      }),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Shimmer Image Placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          SizedBox(height: 10),

          // ✅ Shimmer Title Placeholder
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              height: 20,
              width: 200,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 10),

          // ✅ Shimmer Buttons Placeholder
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

  // ✅ Shimmer Icon Placeholder
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


