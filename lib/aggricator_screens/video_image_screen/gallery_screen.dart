import 'dart:developer';
import 'dart:io';


import 'package:carousel_slider/carousel_slider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import '../../../globel_keys/app_router.dart';
import '../../../services/image_to_pdf_helper.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/commant_screen.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';

import '../../utils/botton_actions.dart';
import '../events_data/event_repo.dart';



class FullPageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  final String className;
  final postDetails;
  final bool isHome;

  const FullPageCarousel({super.key, required this.imageUrls, this.className = "", required this.postDetails, this.isHome = false});

  @override
  FullPageCarouselState createState() => FullPageCarouselState();
}

class FullPageCarouselState extends State<FullPageCarousel> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  ScreenshotController sc = ScreenshotController();
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload gallery images so they are ready when the user swipes to this post
    for (var image in widget.imageUrls) {
      String url = image is String ? image : (image['Url'] ?? "");
      if (url.isNotEmpty) {
        precacheImage(NetworkImage(url), context);
      }
    }
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayFeatures = MediaQuery.of(context).displayFeatures;
    bool isFoldable = displayFeatures.isNotEmpty;

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
                  style: fontStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Screenshot(
            controller: sc,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  pageSnapping: true,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    _currentIndex.value = index;
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  enlargeCenterPage: true,
                ),
                items: widget.imageUrls.map((image) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreview(
                            imageUrl: image is String ? image : (image['Url'] ?? ""),
                            title: widget.postDetails['title'] ?? "",
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            image is String ? image : (image['Url'] ?? ""),
                          ),
                          fit: isFoldable ? BoxFit.fill : BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          isAntiAlias: true,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, currentIndex, child) {
                return AnimatedSmoothIndicator(
                  activeIndex: currentIndex,
                  count: widget.imageUrls.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    activeDotColor: Colors.cyan.withValues(alpha: .3),
                    dotColor: Colors.grey.shade400,
                  ),
                  onDotClicked: (index) {
                    _controller.jumpToPage(index);
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.transparent, // Optional background
                padding: EdgeInsets.symmetric(horizontal: 8.0.sp, vertical: 10.sp),
                child: Row(
                  children: [
                    // Like Button with Provider
                    Consumer<SettingsProvider>(
                      builder: (_, settingsProvider, __) {
                        bool isLiked = settingsProvider.isLikeList.contains(widget.postDetails['id'].toString());
                        return BottomActions(
                          iconColor: AppColors.iconColors,
                          postType: widget.postDetails['subType']?.toString() ?? "",
                          icon: isLiked ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                          label: 'లైక్',
                          isLike: isLiked,
                          onTap: () async {
                            log("Like");
                            settingsProvider.isLikePost(widget.postDetails);
                             EventRepo().addEvent({
                              "like": !settingsProvider.isLikeList.contains(widget.postDetails['id'].toString()),
                              "postId": widget.postDetails['id'].toString()??"000",
                              "createAt": DateTime.now().toString(),
                               "postTitle": widget.postDetails['title'].toString()

                             }, "liked_article");


                          },
                        );
                      },
                    ),

                    width(width: 12.sp),

                    BottomActions(
                      postType: widget.postDetails['subType'] ?? "",
                      icon: "assets/svg/new_comment.svg",
                      label: 'కామెంట్',
                      iconColor: AppColors.iconColors,
                      onTap: () async {
                        context.read<AuthenticationProvider>().sendEvent("CommentPage");
                        showComments(context, widget.postDetails['id'],widget.postDetails['title'],);
                      },
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showShareOptionsBottomSheet(context, widget.postDetails);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Image.asset("assets/images/WhatsApp_icon.png", height: 30.sp, width: 30.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showShareOptionsBottomSheet(
    BuildContext context,
    article,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
            child:Container(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 20),
              height: 280,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  height(height: 10),
                  Text(
                    "Share Our Post",
                    style: homeScreenFontStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  height(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      InkWell(
                        onTap: () async{
                          try {
                            Navigator.pop(sheetContext);
                            var currentImage = article['gallery'][_currentIndex.value];
                            String imageUrl = currentImage is String ? currentImage : (currentImage['Url'] ?? "");
                            final response = await http.get(Uri.parse(imageUrl));
                            if (response.statusCode == 200) {
                              // Get temporary directory
                              final tempDir = await getTemporaryDirectory();
                              final filePath = '${tempDir.path}/shared_image.jpg';

                              // Write the file
                              final file = File(filePath);
                              await file.writeAsBytes(response.bodyBytes);

                              // Share the image to WhatsApp directly
                              final String title = article['title']?.toString() ?? "";
                              final String link = Platform.isIOS ? (article['linkURLIos']?.toString() ?? "") : (article['linkURLAndroid']?.toString() ?? "");
                              final String shareText = title + "\n" + link;
                              
                                try {
                                  const platform = MethodChannel('com.chotanews/whatsapp');
                                  await platform.invokeMethod('shareToWhatsApp', {'imagePath': file.path, 'text': shareText});
                                  if (Platform.isIOS) {
                                    CustomToast.showInfoToast(msg: "Text copied to clipboard. Paste it in WhatsApp.");
                                  }
                                } catch (e) {
                                if (e is PlatformException && e.code == "APP_NOT_INSTALLED") {
                                  CustomToast.showInfoToast(msg: "WhatsApp is not installed");
                                } else {
                                  await Share.shareXFiles([XFile(file.path)], text: shareText);
                                }
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image download failed.')),
                                );
                              }
                            }
                          } catch (e) {
                            log('Error downloading or sharing image: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Something went wrong: $e')),
                              );
                            }
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),

                            height(height: 8),
                            Text(
                              "Share This Image",
                              style: newAppFont(fontWeight: FontWeight.w600, color: AppColors.headerTextColor),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap:() {
                          Navigator.pop(sheetContext);
                          createAndSharePdf(context, widget.postDetails);
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.file_copy_sharp,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                            height(height: 8),
                            Text(
                              "Share All Images",
                              style: newAppFont(fontWeight: FontWeight.w600, color: AppColors.headerTextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  height(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 35.h,
                      // margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: AppColors.appButtonColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  height(height: 20)
                ],
              ),
            ));
      },
    );
  }
}




