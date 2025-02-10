import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_bloc.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_state.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../globel_keys/app_router.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/date_conversion.dart';
import '../../home_screen/home_screen_model.dart';
import '../vodeo_bloc/videos_event.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryScreen extends StatefulWidget {
  final String postId;

  const GalleryScreen({super.key, required this.postId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    context.read<VideosBloc>().add(GetAllVideos(type: widget.postId));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, RoutesManager.getAllMenuItemScreen);
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
                Navigator.pop(context);
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
              SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Gallery View",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullPageCarousel(
                            imageUrls: state.getAllVideoList[index].gallery ?? [],
                            className: "Gallery View",
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                            child: CachedNetworkImage(
                              imageUrl: state.getAllVideoList[index].imageUrl!.url.toString(),
                              height: 110,
                              width: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 110,
                                width: 80,
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                                    state.getAllVideoList[index].created.toString(),
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
  const FullPageCarousel({super.key, required this.imageUrls,this.className=""});

  @override
  _FullPageCarouselState createState() => _FullPageCarouselState();
}

class _FullPageCarouselState extends State<FullPageCarousel> {
  int _currentIndex = 0;

  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.className== ""? null:AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context,RoutesManager.getAllMenuItemScreen);
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
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            // carouselController: _controller, // Using the correct controller
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: false,
              autoPlayInterval: Duration(seconds: 3),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.imageUrls.map((image) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(image.url),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),

          // Smooth Page Indicator
          Positioned(
            bottom: 20,
            child: AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: widget.imageUrls.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.white,
                dotColor: Colors.grey.shade400,
              ),
              onDotClicked: (index) {
                _controller.jumpToPage(index); // Corrected method
              },
            ),
          ),
        ],
      ),
    );
  }
}
