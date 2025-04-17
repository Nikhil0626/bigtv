import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/botton_actions.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../screens/home_screen/home_screens/google_ads_view.dart';
import '../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../screens/home_screen/home_screens/standard_post_view.dart';
import '../../screens/videos_main/video_views/gallery_screen.dart';
import '../../screens/videos_main/video_views/video_preview.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_and _source.dart';
import '../auth_screens/authentication_provider/authentication_provider.dart';
import '../settings_screen/settings_provider/settings_provider.dart';
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
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Consumer<AuthenticationProvider>(builder: (_, authenticationProvider, __) {
                return Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    // color: Colors.greenAccent,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: authenticationProvider.getAllCategoryList.length,
                      itemBuilder: (context, index) {
                        final isSelected = authenticationProvider.selectedCategories.contains(authenticationProvider.getAllCategoryList[index].categoryName.toString());

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.loginBgColor : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            authenticationProvider.getAllCategoryList[index].categoryName.toString(),
                            textAlign: TextAlign.center,
                            style: homeScreenFontStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ));
              }),
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
                      child: Screenshot(
                        controller: _screenshotControllers[index],
                        child: Container(
                          height: 330.h,
                          color: AppColors.ePaperCardColor,
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
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(16.r),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: homeProvider.getAllPostList[index]['image_url'],
                                                height: 330.h,
                                                width: MediaQuery.of(context).size.width,
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) => Container(
                                                  height: 330.h,
                                                  width: MediaQuery.of(context).size.width,
                                                  color: AppColors.borderColor.withOpacity(.2),
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  height: 330.h,
                                                  width: MediaQuery.of(context).size.width,
                                                  color: Colors.grey.shade200,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 100,
                                                      color: Colors.grey.shade300,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 14,
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.read<SettingsProvider>().saveBookmarks(homeProvider.getAllPostList[index]['id'].toString());
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
                                                    isHome: true,
                                                    imageUrls: homeProvider.getAllPostList[index]['gallery'] ?? [],
                                                    postDetails: homeProvider.getAllPostList[index],
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 14,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        context.read<SettingsProvider>().saveBookmarks(
                                                              homeProvider.getAllPostList[index]['id'].toString(),
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
                                            ),
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            Container(
                                              height: 330.h,
                                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: AppColors.cardBackgroundColor, // Unique color per card
                                                borderRadius: BorderRadius.circular(12),
                                                // boxShadow: [
                                                //   BoxShadow(
                                                //     color: Colors.black.withOpacity(0.2), // Shadow color
                                                //     blurRadius: 6, // Softness of the shadow
                                                //     spreadRadius: 2, // How far the shadow spreads
                                                //     offset: Offset(0, 3), // Offset (x, y)
                                                //   ),
                                                // ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(16.r),
                                                          ),
                                                          child: homeProvider.getAllPostList[index]['type'] == "Video"
                                                              ? SizedBox(
                                                                  height: 180,
                                                                  width: MediaQuery.of(context).size.width,
                                                                  child: VideoPreview(
                                                                    imageUrl: homeProvider.getAllPostList[index]['image_url'],
                                                                    url: homeProvider.getAllPostList[index]['video_url'] ?? "",
                                                                    isFoldable: false,
                                                                  ),
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl: homeProvider.getAllPostList[index]['image_url'].toString(),
                                                                  height: 180,
                                                                  width: MediaQuery.of(context).size.width,
                                                                  fit: BoxFit.fill,
                                                                  placeholder: (context, url) => Container(
                                                                    height: 180,
                                                                    width: MediaQuery.of(context).size.width,
                                                                    color: AppColors.borderColor.withOpacity(.2),
                                                                  ),
                                                                  errorWidget: (context, url, error) => Container(
                                                                    height: 180,
                                                                    width: MediaQuery.of(context).size.width,
                                                                    color: Colors.grey.shade200,
                                                                    child: Center(
                                                                      child: Icon(
                                                                        Icons.image,
                                                                        size: 100,
                                                                        color: Colors.grey.shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          top: 10,
                                                          right: 14,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              context.read<SettingsProvider>().saveBookmarks(homeProvider.getAllPostList[index]['id'].toString());
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
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
                                                    child: Text(
                                                      homeProvider.getAllPostList[index]['title'],
                                                      style: fontStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                                                    child: DateAndSource(data: homeProvider.getAllPostList[index]),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 5.sp),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                                          return BottomActions(
                                                            iconColor: AppColors.iconColors,
                                                            postType: homeProvider.getAllPostList[index]['subType'] ?? "",
                                                            icon:
                                                                settingsProvider.isLikeList.contains(homeProvider.getAllPostList[index]['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                            label: 'లైక్',
                                                            isLike: settingsProvider.isLikeList.contains(homeProvider.getAllPostList[index]['id'].toString()),
                                                            onTap: () {
                                                              log("Like");
                                                              settingsProvider.isLikePost(homeProvider.getAllPostList[index]);

                                                              // flipProvider.isLikePost(homeProvider.getAllPostList[index]);
                                                            },
                                                          );
                                                        }),

                                                        BottomActions(
                                                          postType: homeProvider.getAllPostList[index]['subType'] ?? "",
                                                          icon: "assets/svg/new_comment.svg",
                                                          label: 'కామెంట్',
                                                          iconColor: AppColors.iconColors,
                                                          onTap: () {
                                                            context.read<AuthProvider>().sendEvent("CommentPage");
                                                            EventRepo().sendEvent({
                                                              "key": "comments",
                                                              "data": {
                                                                "device_id": "${GlobalVariables().deviceId}",
                                                                "userId": context.read<FlipProvider>().userId ?? "",
                                                                "postId": homeProvider.getAllPostList[index]['id'].toString(),
                                                              }
                                                            });
                                                            log("Comment --- ${context.read<AuthProvider>().loginType}");
                                                            showComments(context, homeProvider.getAllPostList[index]);
                                                            EventRepo().sendEvent({
                                                              "key": "comments",
                                                              "data": {"deviceId": GlobalVariables().deviceId.toString(), "openTime": DateTime.now().toString()}
                                                            });
                                                          },
                                                        ),
                                                        Spacer(),
                                                        BottomActions(
                                                          postType: homeProvider.getAllPostList[index]['subType'] ?? "",
                                                          icon: "assets/svg/share.svg",
                                                          label: 'షేర్',
                                                          iconColor: AppColors.iconColors,
                                                          onTap: () async {
                                                            EventRepo().sendEvent({
                                                              "key": "share_via_articles",
                                                              "data": {
                                                                "device_id": "${GlobalVariables().deviceId}",
                                                                "userId": context.read<FlipProvider>().userId ?? "",
                                                                "postId": homeProvider.getAllPostList[index]['id'].toString(),
                                                                "isWhatAppShare": false,
                                                              }
                                                            });

                                                            sendShareDetails(
                                                                context.read<FlipProvider>().userId, homeProvider.getAllPostList[index]['id'], homeProvider.getAllPostList[index]['content'].toString());

                                                            if (homeProvider.getAllPostList[index]['type'] == "Standard" || homeProvider.getAllPostList[index]['type'] == "Video") {
                                                              try {
                                                                final image = await _screenshotControllers[index].capture(
                                                                  pixelRatio: 2,
                                                                );
                                                                if (image != null) {
                                                                  final directory = await getTemporaryDirectory();
                                                                  final imagePath = '${directory.path}/${homeProvider.getAllPostList[index]['id']}.png';
                                                                  final imageFile = File(imagePath);
                                                                  await imageFile.writeAsBytes(image);

                                                                  Share.shareXFiles([XFile(imageFile.path)], text: homeProvider.getAllPostList[index]['linkURLAndroid'].toString());
                                                                } else {
                                                                  CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                                }
                                                              } catch (e) {
                                                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                              }
                                                            } else if (homeProvider.getAllPostList[index]['type'] == "Gallery") {
                                                              createAndSharePdf(context, homeProvider.getAllPostList[index]);
                                                            }
                                                          },
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                  height(height: 10)
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              left: 40,
                                              top: 184,
                                              child: Container(
                                                height: 30,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2), // Shadow color
                                                      blurRadius: 6, // Softness of the shadow
                                                      spreadRadius: 2, // How far the shadow spreads
                                                      offset: Offset(0, 1), // Offset (x, y)
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "Chota ",
                                                          style: fontStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "News",
                                                          style: fontStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xff00A8FF),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                        ),
                      ),
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
