
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../screens/home_screen/home_screens/google_ads_view.dart';
import '../../screens/videos_main/video_views/gallery_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        context.read<HomeProvider>().getAllPost(postId: context.read<HomeProvider>().getAllPostList.last['id'].toString()); // Fetch next page
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return RefreshIndicator(
        onRefresh: () => homeProvider.getAllPost(),
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
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
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: homeProvider.getAllPostList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    _screenshotControllers.addAll(
                      List.generate(homeProvider.getAllPostList.length, (_) => ScreenshotController()),
                    );
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
                      child: homeProvider.getAllPostList[index]['type'] == "GoogleAds"
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 330.h,
                                  child: GoogleAdsView(
                                    article: homeProvider.getAllPostList[index],
                                    flipProvider: homeProvider,
                                    // screenshotController: ScreenshotController(),
                                    isFoldable: false,
                                  ),
                                ),
                              ),
                            )
                          : homeProvider.getAllPostList[index]['type'] == "Image"
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SizedBox(
                                    height: 330.h,
                                    child: ImageView(index: index,getAllPostList: homeProvider.getAllPostList[index],)
                                  ),
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
                                                child:Consumer<HomeProvider>(builder: (_, homeProvider, __) {
                                                  return  GestureDetector(
                                                    onTap: () {

                                                      homeProvider.isBookMarkPost(homeProvider.getAllPostList[index], context);

                                                      print("");
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(7),
                                                      decoration: BoxDecoration(
                                                        color:  (homeProvider.isBookMark.contains(homeProvider.getAllPostList[index]['id'].toString()) || homeProvider.getAllPostList[index]['isBookmarked'] == 1)
                                                            ? AppColors.appButtonColor
                                                            : Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        (homeProvider.isBookMark.contains(homeProvider.getAllPostList[index]['id'].toString()) || homeProvider.getAllPostList[index]['isBookmarked'] == 1)
                                                            ? Icons.bookmark
                                                            : Icons.bookmark_outline,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  );
                                                })
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  :ListStandardPostView(articalData: homeProvider.getAllPostList[index],index:index)
                    );
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
