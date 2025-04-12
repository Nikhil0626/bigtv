import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/individual_paper.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shimmer/shimmer.dart';

import '../../../screens/home_screen/home_provider/provider.dart';
import '../../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../../utils/app_colors.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';

class PapersScreenCard extends StatefulWidget {
  const PapersScreenCard({super.key});

  @override
  State<PapersScreenCard> createState() => _PapersScreenCardState();
}

class _PapersScreenCardState extends State<PapersScreenCard> {
  int currentIndex = 0;
  final CardSwiperController controller = CardSwiperController();
  final ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    context.read<EPapersProvider>().getMainEPapers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EPapersProvider>(builder: (_, ePapersProvider, __) {
        return SizedBox(
          width: MediaQuery.of(context).size.width.w,
          height: MediaQuery.of(context).size.height - 150.h,
          child: Center(
            child: ePapersProvider.isMainPapers?Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CardSwiper(
                allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                controller: controller,
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
            ):
                ePapersProvider.getAllMainPapersList.isEmpty?AppNoData( )
                : CardSwiper(
                    allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                    controller: controller,
                    cardsCount: ePapersProvider.getAllMainPapersList.length,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      print("Swiped from $previousIndex to $currentIndex  direction $direction");
                      return true;
                    },
                    numberOfCardsDisplayed: 4,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndividualPaper(
                                  paper: ePapersProvider.getAllMainPapersList[index].source,
                                ),
                              ));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                child: CachedNetworkImage(
                                  imageUrl: ePapersProvider.getAllMainPapersList[index].imageUrl,
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


                              Positioned(
                                top: 14,
                                right: 14,
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<SettingsProvider>().saveBookmarks(
                                          ePapersProvider.getAllMainPapersList[index].id.toString(),
                                        );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.bookmark,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: (){Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => InAppWebViewScreen(
                                            webUrl: ePapersProvider.getAllMainPapersList[index].sourceUrl.toString(),
                                            title: "Advertise with us",
                                          ),
                                        ));
                                        },
                                        child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: Image.network(
                                              ePapersProvider.getAllMainPapersList[index].logo,
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.fill,
                                            )
                                        ),
                                      ),
                                      width(width: 6.h),
                                      Text(
                                        ePapersProvider.getAllMainPapersList[index].source,
                                        style: newAppFont(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      // Spacer(),
                                      // Icon(
                                      //   Icons.ios_share,
                                      //   color: Colors.grey.shade600,
                                      //   size: 20,
                                      // ),
                                      width(width: 15.w),
                                    ],
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
