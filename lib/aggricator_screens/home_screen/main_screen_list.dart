import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../event_repo.dart';
import '../in_app_web_view.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../ad_manager_screen/test_ads.dart';
import '../video_image_view/gallery_screen.dart';
import 'ai_tag_posts_pageview.dart';
import 'image_view.dart';
import 'list_standerd_post_view.dart';
import 'main_screen_pageview.dart';

class MainScreenList extends StatefulWidget {
  const MainScreenList({super.key});

  @override
  State<MainScreenList> createState() => _MainScreenListState();
}

class _MainScreenListState extends State<MainScreenList> {
  final List<ScreenshotController> _screenshotControllers = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // context.read<HomeProvider>().getAllPostList =[];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return RefreshIndicator(
        onRefresh: () => homeProvider.getAllPost(postId: "0"),
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              homeProvider.getAllAiTagsList.isEmpty?SizedBox.shrink():    Container(
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
                          onTap: () async{
                            SharedPreferences preferences = await SharedPreferences.getInstance();
                            String? userId = preferences.getString("userId");
                            String? deviceId = preferences.getString("deviceId");

                            EventRepo().sendEvent({
                              "key": "ai_articles_opened",
                              "data": {"device_id": "$deviceId", "userId": userId, "aiTagName":homeProvider.getAllAiTagsList[index]['aitagname'].toString(),"aiTagId": homeProvider.getAllAiTagsList[index]['aitagid'].toString()}
                            });
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
                            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
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
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: homeProvider.getAllPostList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    log(homeProvider.getAllPostList[index].toString());
                    log({homeProvider.getAllPostList.length - 5}.toString());
                    if (index == homeProvider.getAllPostList.length - 5) {
                      homeProvider.getAllPost(postId: homeProvider.getAllPostList.last['id'].toString()); // Fetch next page
                    }
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreenPageView(
                                  startIndex: index,
                                ),
                              ));
                        },
                        child: homeProvider.getAllPostList[index]['type'].toString() == "WebUrl"
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => InAppWebViewScreen(webUrl: homeProvider.webUrl.toString(), title: "IPL Update"),));
                                  },
                                  child: SizedBox(
                                    height: 300.h,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                      child: Image.asset(
                                        "assets/svg/ipl.png",
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : homeProvider.getAllPostList[index]['type'] == "GoogleAds"
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      child: SizedBox(
                                        height: 270.h,
                                        child: banner(),
                                        // child: GoogleAdsView(
                                        //   article: homeProvider.getAllPostList[index],
                                        //   flipProvider: homeProvider,
                                        //   // screenshotController: ScreenshotController(),
                                        //   isFoldable: false,
                                        // ),
                                      ),
                                    ),
                                  )
                                : homeProvider.getAllPostList[index]['type'] == "Image"
                                    ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SizedBox(
                                            height: 330.h,
                                            child: ImageView(
                                              index: index,
                                              getAllPostList: homeProvider.getAllPostList[index],
                                            )),
                                      )
                                    : homeProvider.getAllPostList[index]['type'] == "Gallery"
                                        ? Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: SizedBox(
                                              height: 330.h,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                                child: Stack(
                                                  children: [
                                                    FullPageCarousel(
                                                      isHome: false,
                                                      imageUrls: homeProvider.getAllPostList[index]['gallery'] ?? [],
                                                      postDetails: homeProvider.getAllPostList[index],
                                                    ),
                                                    Positioned(
                                                        top: 10,
                                                        right: 14,
                                                        child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              homeProvider.isBookMarkPost(homeProvider.getAllPostList[index], context);

                                                              print("");
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(7),
                                                              decoration: BoxDecoration(
                                                                color: (homeProvider.isBookMark.contains(homeProvider.getAllPostList[index]['id'].toString()) ||
                                                                        homeProvider.getAllPostList[index]['isBookmarked'] == 1)
                                                                    ? AppColors.appButtonColor
                                                                    : Colors.black54,
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Icon(
                                                                (homeProvider.isBookMark.contains(homeProvider.getAllPostList[index]['id'].toString()) ||
                                                                        homeProvider.getAllPostList[index]['isBookmarked'] == 1)
                                                                    ? Icons.bookmark
                                                                    : Icons.bookmark_outline,
                                                                color: Colors.white,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          );
                                                        })),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : ListStandardPostView(articalData: homeProvider.getAllPostList[index], index: index));
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}


// isStickyPost