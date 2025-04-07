import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../screens/Auth_module/auth_provider/auth_provider.dart';
import '../../screens/home_screen/botton_actions.dart';
import '../../screens/home_screen/home_repo/event_repo.dart';
import '../../screens/home_screen/home_screens/google_ads_view.dart';
import '../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../screens/videos_main/video_views/gallery_screen.dart';
import '../../screens/videos_main/video_views/video_preview.dart';
import '../../services/image_to_pdf_helper.dart';
import '../../services/webengage_event_tracks.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_and _source.dart';
import 'main_screen_pageview.dart';

class MainScreenCard extends StatefulWidget {
  const MainScreenCard({super.key});

  @override
  State<MainScreenCard> createState() => _MainScreenCardState();
}

class _MainScreenCardState extends State<MainScreenCard> {
  int currentIndex = 0;
  final CardSwiperController controller = CardSwiperController();
  final ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    context.read<FlipProvider>().getArticles();
    context.read<AuthenticationProvider>().getAllCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<FlipProvider>(builder: (_, flipProvider, __) {
        return SizedBox(
          width: MediaQuery.of(context).size.width.w,
          height: MediaQuery.of(context).size.height - 150.h,
          child: Center(
            child: flipProvider.mainArticlesData.isEmpty
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
                        return ShimmerCard(); // ✅ Show shimmer card while loading
                      },
                    ),
                  )
                : Column(
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
                              final isSelected = authenticationProvider.selectedCategories.contains(authenticationProvider.getAllCategoryList[index].categoryName.toString()) ?? false;

                              return Container(
                                // height: 40,

                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.loginBgColor : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
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
                          ),
                        );
                      }),
                      Expanded(
                        child: CardSwiper(
                          allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                          controller: controller,
                          // Assign the controller
                          cardsCount: flipProvider.mainArticlesData.length,
                          onSwipe: (previousIndex, currentIndex, direction) {
                            print("Swiped from $previousIndex to $currentIndex");
                            return true;
                          },

                          numberOfCardsDisplayed: 4,
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
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackgroundColor, // Unique color per card
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2), // Shadow color
                                      blurRadius: 6, // Softness of the shadow
                                      spreadRadius: 2, // How far the shadow spreads
                                      offset: Offset(0, 3), // Offset (x, y)
                                    ),
                                  ],
                                ),
                                child: flipProvider.mainArticlesData[index].type == "WebView"
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InAppWebViewScreen(
                                          webUrl: flipProvider.webUrl.toString(),
                                          title: '',
                                        ),
                                      )
                                    : flipProvider.mainArticlesData[index].type == "GoogleAds"
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GoogleAdsView(
                                              article: flipProvider.mainArticlesData[index],
                                              flipProvider: flipProvider,
                                              screenshotController: adsScreenshotController,
                                              isFoldable: false,
                                            ),
                                          )
                                        : flipProvider.mainArticlesData[index].type == "Image"
                                            ? Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Image.network(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: MediaQuery.of(context).size.height,
                                                  fit: BoxFit.cover,
                                                  flipProvider.mainArticlesData[index].imageUrl.url ?? "",
                                                ),
                                              )
                                            : flipProvider.mainArticlesData[index].type == "Gallery"
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(12),
                                                    ),
                                                    child: FullPageCarousel(
                                                      isHome: true,
                                                      imageUrls: flipProvider.mainArticlesData[index].gallery ?? [],
                                                      postDetails: flipProvider.mainArticlesData[index],
                                                    ),
                                                  )
                                                : Stack(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(12),
                                                              ),
                                                              child: flipProvider.mainArticlesData[index].type == "Video"
                                                                  ? SizedBox(
                                                                height: MediaQuery.of(context).size.height*.35,
                                                                width: MediaQuery.of(context).size.width,
                                                                    child: VideoPreview(

                                                                        imageUrl: flipProvider.mainArticlesData[index].imageUrl.url,
                                                                        url: flipProvider.mainArticlesData[index].videoUrl?.url ?? "",
                                                                        isFoldable: false,
                                                                      ),
                                                                  )
                                                                  : CachedNetworkImage(
                                                                      imageUrl: flipProvider.mainArticlesData[index].imageUrl.url,
                                                                      height: MediaQuery.of(context).size.height*.35,
                                                                      width: MediaQuery.of(context).size.width,
                                                                      fit: BoxFit.fill,
                                                                      placeholder: (context, url) => Container(
                                                                        color: AppColors.borderColor.withOpacity(.2),
                                                                      ),
                                                                      errorWidget: (context, url, error) => Center(
                                                                        child: Icon(
                                                                          Icons.image,
                                                                          size: 100,
                                                                          color: Colors.grey.shade300,
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                          height(height: 8),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
                                                            child: Text(
                                                              flipProvider.mainArticlesData[index].title.toString(),
                                                              style: fontStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                                                            child: DateAndSource(data: flipProvider.mainArticlesData[index]),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 5.sp),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Consumer<FlipProvider>(builder: (_, flipProvider, __) {
                                                                  return BottomActions(
                                                                    iconColor: AppColors.iconColors,
                                                                    postType: flipProvider.mainArticlesData[index].subType ?? "",
                                                                    icon: flipProvider.isLikeList.contains(flipProvider.mainArticlesData[index].id.toString())
                                                                        ? "assets/svg/like_full.svg"
                                                                        : "assets/svg/like.svg",
                                                                    label: 'లైక్',
                                                                    isLike: flipProvider.isLikeList.contains(flipProvider.mainArticlesData[index].id.toString()),
                                                                    onTap: () {
                                                                      log("Like");
                                                                      flipProvider.isLikePost(flipProvider.mainArticlesData[index]);
                                                                    },
                                                                  );
                                                                }),
                                                                BottomActions(
                                                                  postType: flipProvider.mainArticlesData[index].subType ?? "",
                                                                  icon: "assets/svg/comment.svg",
                                                                  label: 'కామెంట్',
                                                                  iconColor: AppColors.iconColors,
                                                                  onTap: () {
                                                                    context.read<AuthProvider>().sendEvent("CommentPage");
                                                                    EventRepo().sendEvent({
                                                                      "key": "comments",
                                                                      "data": {
                                                                        "device_id": "${GlobalVariables().deviceId}",
                                                                        "userId": context.read<FlipProvider>().userId ?? "",
                                                                        "postId": flipProvider.mainArticlesData[index].id.toString(),
                                                                      }
                                                                    });
                                                                    log("Comment --- ${context.read<AuthProvider>().loginType}");
                                                                    showComments(context, flipProvider.mainArticlesData[index]);
                                                                    EventRepo().sendEvent({
                                                                      "key": "comments",
                                                                      "data": {"deviceId": GlobalVariables().deviceId.toString(), "openTime": DateTime.now().toString()}
                                                                    });
                                                                  },
                                                                ),
                                                                Spacer(),
                                                                BottomActions(
                                                                  postType: flipProvider.mainArticlesData[index].subType ?? "",
                                                                  icon: "assets/svg/share.svg",
                                                                  label: 'షేర్',
                                                                  iconColor: AppColors.iconColors,
                                                                  onTap: () async {
                                                                    EventRepo().sendEvent({
                                                                      "key": "share_via_articles",
                                                                      "data": {
                                                                        "device_id": "${GlobalVariables().deviceId}",
                                                                        "userId": context.read<FlipProvider>().userId ?? "",
                                                                        "postId": flipProvider.mainArticlesData[index].id.toString(),
                                                                        "isWhatAppShare": false,
                                                                      }
                                                                    });

                                                                    sendShareDetails(context.read<FlipProvider>().userId, flipProvider.mainArticlesData[index].id,
                                                                        flipProvider.mainArticlesData[index].content.toString());

                                                                    if (flipProvider.mainArticlesData[index].type == "Standard" || flipProvider.mainArticlesData[index].type == "Video") {
                                                                      try {
                                                                        final image = await adsScreenshotController.capture(
                                                                          pixelRatio: 0.5,
                                                                        );
                                                                        if (image != null) {
                                                                          final directory = await getTemporaryDirectory();
                                                                          final imagePath = '${directory.path}/${flipProvider.mainArticlesData[index].id}.png';
                                                                          final imageFile = File(imagePath);
                                                                          await imageFile.writeAsBytes(image);

                                                                          Share.shareXFiles([XFile(imageFile.path)],
                                                                              text: Platform.isIOS
                                                                                  ? flipProvider.mainArticlesData[index].linkURLIos.toString()
                                                                                  : flipProvider.mainArticlesData[index].linkURLAndroid.toString());
                                                                        } else {
                                                                          CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                                        }
                                                                      } catch (e) {
                                                                        CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                                      }
                                                                    } else if (flipProvider.mainArticlesData[index].type == "Gallery") {
                                                                      createAndSharePdf(context, flipProvider.mainArticlesData[index]);
                                                                    }
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 40,
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      log("Refresh");
                                                                      EventRepo().sendEvent({
                                                                        "key": "reload",
                                                                        "data": {
                                                                          "device_id": "${GlobalVariables().deviceId}",
                                                                          "userId": GlobalVariables().userId ?? "",
                                                                        }
                                                                      });
                                                                      flipProvider.getArticles(refresh: true);
                                                                    },
                                                                    child: Center(
                                                                      child: flipProvider.isRefresh
                                                                          ? const SizedBox(height: 20, width: 20, child: AppLoadingScreen())
                                                                          : SvgPicture.asset(
                                                                              "assets/svg/reload.svg",
                                                                              height: 20,
                                                                              width: 20,
                                                                              color: AppColors.iconColors,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          height(height: 20)
                                                        ],
                                                      ),
                                                      Positioned(
                                                        left: 30,
                                                        top: MediaQuery.of(context).size.height*.345,
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
                            );
                          },
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
          SizedBox(height: 20),
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
