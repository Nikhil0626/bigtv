import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/standard_post_view.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../loading_screen/home_shimmer.dart';
import '../in_app_web_view.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spaces.dart';
import '../ad_manager_screen/test_ads.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
import '../video_image_view/gallery_screen.dart';
import 'ai_tag_posts_pageview.dart';
import 'home_provider/home_provider.dart';
import 'image_view.dart';
import 'main_screen_pageview.dart';

class MainScreenCard extends StatefulWidget {
  const MainScreenCard({
    super.key,
  });

  @override
  State<MainScreenCard> createState() => _MainScreenCardState();
}

class _MainScreenCardState extends State<MainScreenCard> with TickerProviderStateMixin {
  List<Map<String, dynamic>> removedCards = [];
  Offset slideOffset = Offset.zero;
  bool isAnimating = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    log("hello home screen in 2222");
    context.read<HomeProvider>().getAllPostList = [];
    context.read<HomeProvider>().getAllAiTags();
    log("pushActionStream: flutter test  11111 Home kwfhewkufeiu  ${context.read<HomeProvider>().postId}");
    if (context.read<HomeProvider>().postId.toString() != "0") {
      log("getIndividualPost in Home screen ${context.read<HomeProvider>().postId.toString()}");
      context.read<HomeProvider>().getIndividualPost(context.read<HomeProvider>().postId.toString());
    } else {
      context.read<HomeProvider>().getAllPost();
    }
    _pageController = PageController(viewportFraction: 1.0);
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
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, SettingsProvider>(builder: (_, homeProvider, settingsProvider, __) {
      return SafeArea(
        child: InkWell(
          onTap: () {
            homeProvider.pageChange(isValue: !homeProvider.isBottomEnable);
          },
          child: Center(
            child: homeProvider.isHomeLoading
                ? HomeShimmer()
                : homeProvider.getAllPostList.isEmpty
                    ? AppNoData()
                    : Column(
                        children: [
                          homeProvider.getAllAiTagsList.isEmpty
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 50,
                                  // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),

                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homeProvider.getAllAiTagsList.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () async {
                                          context.read<HomeProvider>().setSelectedTagId(homeProvider.getAllAiTagsList[index]['aitagid']);
                                          context.read<HomeProvider>().getAllPostsByAiId(homeProvider.getAllAiTagsList[index]['aitagid'].toString());
                                          context.read<HomeProvider>().aiTagDataLoaded(true);
                                        },
                                        child: Container(
                                          height: 30,
                                          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                                          decoration: BoxDecoration(
                                            color: homeProvider.selectedTagId == homeProvider.getAllAiTagsList[index]['aitagid']
                                                ? AppColors.appButtonColor // Highlighted tag color
                                                : AppColors.cardBackgroundColor,
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                                            child: Text(
                                              homeProvider.getAllAiTagsList[index]['aitagname'].toString(),
                                              textAlign: TextAlign.center,
                                              style: homeScreenFontStyle(
                                                color: homeProvider.selectedTagId == homeProvider.getAllAiTagsList[index]['aitagid'] ? Colors.white : AppColors.textColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                          Expanded(child: MainScreenPageView(startIndex: 0)),
                        ],
                      ),
          ),
        ),
      );
    });
  }

  int currentIndexs = 0;

  void _undo() {
    if (currentIndexs > 0) {
      setState(() {
        currentIndexs--;
      });
      controller.undo();
    }
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
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          SizedBox(height: 10),
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
