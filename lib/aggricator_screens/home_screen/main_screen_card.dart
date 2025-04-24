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

class _MainScreenCardState extends State<MainScreenCard>  with TickerProviderStateMixin {
  // List<Map<String, dynamic>> displayedCards = [];
  List<Map<String, dynamic>> removedCards = [];
  Offset slideOffset = Offset.zero;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HomeProvider>().getAllPostList = [];
      context.read<HomeProvider>().getAllAiTags();
      context.read<HomeProvider>().getAllPost();
      // final posts = context.read<HomeProvider>().getAllPostList;

    // });
  }

  void animateRemoveTopCard() async {
    if (context.read<HomeProvider>().getAllPostList.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, -1);
    });
    await Future.delayed(Duration(milliseconds: 600));
    setState(() {
      removedCards.add(context.read<HomeProvider>().getAllPostList.removeLast());
      slideOffset = Offset.zero;
      isAnimating = false;
    });
  }

  void animateUndoCard() async {
    if (removedCards.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, 1);
      context.read<HomeProvider>().getAllPostList.add(removedCards.removeLast());
    });

    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      slideOffset = Offset.zero;
    });

    await Future.delayed(Duration(milliseconds: 600));
    setState(() {
      isAnimating = false;
    });
  }
  final CardSwiperController controller = CardSwiperController();

  double dragOffset = 0.0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<HomeProvider, SettingsProvider>(builder: (_, homeProvider, settingsProvider, __) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                          homeProvider.getAllAiTagsList.isEmpty?SizedBox.shrink():   Container(
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
                            child: Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 16.0.h),
                              child: Stack(
                                children: [
                                Container(
                                  height: 560,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 24.h),

                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:AppColors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                ),
                                Container(
                                  height: 540,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 16.h),

                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:AppColors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                ),
                                Container(
                                  height: 520,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 8.h),

                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:AppColors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                ),
                                  Container(
                                    height: 500,
                                    width: MediaQuery.of(context).size.width,
                                    // padding: EdgeInsets.only(left: 25,right: 25,bottom: 12),

                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:AppColors.cardBackgroundColor,
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
                                    child: GestureDetector(
                                      onVerticalDragEnd: (details) {
                                        final velocity = details.velocity.pixelsPerSecond.dy;
                                        if (velocity < -500) {
                                          animateRemoveTopCard();
                                        } else if (velocity > 500) {
                                          animateUndoCard();
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: List.generate(
                                            homeProvider.getAllPostList.reversed.toList().length, (index) {
                                          final isTopCard = index == homeProvider.getAllPostList.reversed.toList().length - 1;
                                          final post = homeProvider.getAllPostList.reversed.toList()[index];
                                          final type = post['type'].toString();
                                          double height = 500;

                                          return AnimatedSlide(
                                            offset: isTopCard && slideOffset.dy != 0 ? const Offset(0, -1) : Offset.zero,
                                            duration: const Duration(milliseconds: 600),
                                            curve: Curves.easeInOut,
                                            child: AnimatedOpacity(
                                              opacity: isTopCard && slideOffset.dy != 0 ? 0.9 : 1.0,
                                              duration: Duration(milliseconds: 600),
                                              curve: Curves.easeInOut,
                                              child: InkWell(
                                                onTap: () {

                                                  log("fmerngkjkglkg  ${index}");
                                                  if (type != "GoogleAds") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MainScreenPageView(startIndex: index),
                                                      ),
                                                    );
                                                    if (type == "Video") {
                                                      context.read<HomeProvider>().youtubeDispose();
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.cardBackgroundColor,
                                                    borderRadius: BorderRadius.circular(20.r),
                                                  ),
                                                  child: type == "WebUrl"
                                                      ? Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                InAppWebViewScreen(
                                                                  webUrl: context
                                                                      .read<HomeProvider>()
                                                                      .webUrl
                                                                      .toString(),
                                                                  title: "IPL Update",
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.circular(10.r),
                                                        child: Image.asset(
                                                          "assets/svg/ipl.png",
                                                          width:
                                                          MediaQuery.of(context).size.width,
                                                          height: MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                      : type == "GoogleAds"
                                                      ? Padding(
                                                    padding:
                                                    const EdgeInsets.only(bottom: 20.0),
                                                    child: GoogleAdsView(
                                                      isList: true,
                                                      article: post,
                                                      flipProvider:
                                                      context.read<HomeProvider>(),
                                                      isFoldable: false,
                                                    ),
                                                  )
                                                      : type == "Image"
                                                      ? ImageView(
                                                    index: index,
                                                    getAllPostList: post,
                                                  )
                                                      : type == "Gallery"
                                                      ? Padding(
                                                    padding: const EdgeInsets.only(
                                                        bottom: 5.0),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12)),
                                                          child: FullPageCarousel(
                                                            isHome: false,
                                                            imageUrls:
                                                            post['gallery'] ??
                                                                [],
                                                            postDetails: post,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 18,
                                                          right: 22,
                                                          child: Consumer<
                                                              HomeProvider>(
                                                              builder: (_,
                                                                  homeProvider,
                                                                  __) {
                                                                final isBookmarked =
                                                                    homeProvider
                                                                        .isBookMark
                                                                        .contains(
                                                                        post['id']
                                                                            .toString()) ||
                                                                        post['isBookmarked'] ==
                                                                            1;
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    homeProvider
                                                                        .isBookMarkPost(
                                                                        post,
                                                                        context);
                                                                  },
                                                                  child: Container(
                                                                    padding:
                                                                    EdgeInsets.all(
                                                                        7),
                                                                    decoration:
                                                                    BoxDecoration(
                                                                      color: isBookmarked
                                                                          ? AppColors
                                                                          .appButtonColor
                                                                          : Colors
                                                                          .black54,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: Icon(
                                                                      isBookmarked
                                                                          ? Icons
                                                                          .bookmark
                                                                          : Icons
                                                                          .bookmark_outline,
                                                                      color:
                                                                      Colors.white,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                      : StandardCard(index: index,
                                                  getAllPostList: post,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

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


