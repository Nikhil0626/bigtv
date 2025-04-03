
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/individual_paper.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_colors.dart';
import '../../home_screen/main_screen_pageview.dart';

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
      body: Consumer<EPapersProvider>(
        builder: (_,ePapersProvider,__) {
          return SizedBox(
            width: MediaQuery.of(context).size.width.w,
            height: MediaQuery.of(context).size.height - 150.h,
            child: Center(
              child: ePapersProvider.isMainPapers
                  ? Shimmer.fromColors(
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
              )
                  : CardSwiper(
                allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                controller: controller,
                cardsCount:  ePapersProvider.getAllMainPapersList.length,
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
                            builder: (context) => IndividualPaper(paper: ePapersProvider.getAllMainPapersList[index].source,),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:ePapersProvider.getAllMainPapersList[index].imageUrl,
                          // height: 330,
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
                  );
                },
              ),
            ),
          );
        }
      ),
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
