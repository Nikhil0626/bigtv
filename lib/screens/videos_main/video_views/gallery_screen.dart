import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../globel_keys/app_router.dart';
import '../../../main.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/date_conversion.dart';
import '../../home_screen/home_models/home_screen_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../home_screen/post_bottom_actions.dart';
import '../video_bloc/videos_bloc.dart';
import '../video_bloc/videos_event.dart';
import '../video_bloc/videos_state.dart';

class GalleryScreen extends StatefulWidget {
  final String postId;

  const GalleryScreen({super.key, required this.postId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int topSpace = 0;

  @override
  void initState() {
    context.read<VideosBloc>().add(GetAllVideos(type: widget.postId));
    topSpace = (MediaQuery.of(mainNavigatorKey.currentContext!).padding.bottom)
                .toInt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesManager.getAllMenuItemScreen,
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.appButtonColor,
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RoutesManager.getAllMenuItemScreen,
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: Row(
            children: [
             width(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Gallery",
                  style: fontStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<VideosBloc, VideosState>(
          builder: (context, state) {
            if (state is LoadingState) {
              return const AppLoadingScreen();
            } else if (state is VideoSuccessState) {
              return ListView.separated(
                itemCount: state.getAllVideoList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if(state.getAllVideoList[index].gallery!.isEmpty ){
                      CustomToast.showErrorToast(msg: "Images Not Found...");
                      }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPageCarousel(
                              imageUrls:
                              state.getAllVideoList[index].gallery ?? [],
                              className: "Gallery ",
                              postDetails: state.getAllVideoList[index],
                            ),
                          ),
                        );
                      }

                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            child: CachedNetworkImage(
                              imageUrl: state
                                  .getAllVideoList[index].imageUrl!.url
                                  .toString(),
                              height: 110,
                              width: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 110,
                                width: 80,
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          width(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.getAllVideoList[index].title.toString(),
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                height(height: 10),
                                Text(
                                  dateFormat(
                                    state.getAllVideoList[index].created
                                        .toString(),
                                  ),
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  );
                },
              );
            }
            return const Center(child: Text(AppStrings.appNotWorking));
          },
        ),
      ),
    );
  }
}

class FullPageCarousel extends StatefulWidget {
  final List<GalleryImage> imageUrls;
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
          CarouselSlider(
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
                    image: NetworkImage(image.url,),
                    fit: isFoldable?BoxFit.fill:BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    isAntiAlias: true,

                  ),
                ),
              );
            }).toList(),
          ),
          Positioned(
            bottom: widget.isHome ?Platform.isIOS? 45:20 : Platform.isIOS? 95:70,
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
          if (!widget.isHome)
            Align(
              alignment: Alignment.bottomCenter,
              child: GalleryPostBottomActions(
                article: widget.postDetails!,
              ),
            ),
        ],
      ),
    );
  }
}
