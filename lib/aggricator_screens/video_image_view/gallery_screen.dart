import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
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

class FullPageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  final String className;
  final postDetails;
  final bool isHome;

  const FullPageCarousel({super.key, required this.imageUrls, this.className = "", required this.postDetails, this.isHome = false});

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
                        image: NetworkImage(
                          image['Url'],
                        ),
                        fit: isFoldable ? BoxFit.fill : BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        isAntiAlias: true,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            child: AnimatedSmoothIndicator(
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
                          onTap: () {
                            log("Like");
                            settingsProvider.isLikePost(widget.postDetails);
                          },
                        );
                      },
                    ),

                    SizedBox(width: 12.sp),

                    // Comment Button
                    BottomActions(
                      postType: widget.postDetails['subType'] ?? "",
                      icon: "assets/svg/new_comment.svg",
                      label: 'కామెంట్',
                      iconColor: AppColors.iconColors,
                      onTap: () async {
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        context.read<AuthenticationProvider>().sendEvent("CommentPage");
                        showComments(context, widget.postDetails['id']);
                      },
                    ),

                    Spacer(),

                    // Share Button
                    BottomActions(
                      postType: widget.postDetails['subType'] ?? "",
                      icon: "assets/svg/share.svg",
                      label: 'షేర్',
                      iconColor: AppColors.iconColors,
                      onTap: () async {
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        String? userId = sp.getString("userId");
                        sendShareDetails(userId, widget.postDetails['id'], widget.postDetails['content'].toString());
                        showShareOptionsBottomSheet(context, widget.postDetails);
                      },
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
      builder: (context) {
        return SafeArea(
            child:SizedBox(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(onTap: () {

                  },child:  IconButton(
                    icon: Icon(Icons.cancel_rounded,size: 20,color: Colors.red,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),),
                  height(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      ElevatedButton.icon(
                        icon: Icon(Icons.collections),
                        label: Text('This Image'),
                        onPressed: () async {
                          try {
                            Navigator.pop(context);
                            final response = await http.get(Uri.parse(article['gallery'][_currentIndex]['Url']));
                            if (response.statusCode == 200) {
                              // Get temporary directory
                              final tempDir = await getTemporaryDirectory();
                              final filePath = '${tempDir.path}/shared_image.jpg';

                              // Write the file
                              final file = File(filePath);
                              await file.writeAsBytes(response.bodyBytes);

                              // Share the image
                              await Share.shareXFiles([XFile(file.path)], text: Platform.isIOS?article['linkURLIos']:article['linkURLAndroid']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Image download failed.')),
                              );
                            }
                          } catch (e) {
                            print('Error downloading or sharing image: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Something went wrong: $e')),
                            );
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.collections),
                        label: Text('All Images'),
                        onPressed: () {
                          createAndSharePdf(context, widget.postDetails).then(
                                (value) {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  height(height: 10),
                ],
              ),
            ));
      },
    );
  }
}
