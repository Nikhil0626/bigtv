import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final CardSwiperController controller = CardSwiperController();

@override
  void initState() {
  context.read<FlipProvider>().getArticles();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FlipProvider>(
        builder: (_,flipProvider,__) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width-50.w,
                height: MediaQuery.of(context).size.height-200.h,

              child: CardSwiper(
                allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                controller: controller, // Assign the controller
                cardsCount: flipProvider.mainArticlesData.length,
                onSwipe: (previousIndex, currentIndex, direction) {
                  print("Swiped from $previousIndex to $currentIndex");
                  return true;
                },
                // onUndo: (previousIndex, currentIndex, direction) {
                //
                // },
                numberOfCardsDisplayed:4,
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    child:Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.primaries[index % Colors.primaries.length], // Unique color per card
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16.r),
                          topLeft: Radius.circular(16.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:flipProvider.mainArticlesData[index].imageUrl.url,
                          height: MediaQuery.of(context).size.height-200.h,
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

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     body: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 1,
//           child: Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Center(
//               child: SizedBox(
//                 height: 500, // Adjust height of the swiper container
//                 width: 300,  // Adjust width of the swiper container
//                 child: Swiper(
//                   itemCount: moviePosters.length,
//                   layout: SwiperLayout.STACK, // Stack effect
//                   itemWidth: 250,
//                   itemHeight: 300,
//                   loop: true,
//                   autoplay: false,
//                   scrollDirection: Axis.vertical, // Enables top-to-bottom swipe
//                   itemBuilder: (context, index) {
//                     return Card(
//                       color: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.asset(
//                             moviePosters[index],
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Center(
//             child: SizedBox(
//               height: 500, // Adjust height of the swiper container
//               width: 300,  // Adjust width of the swiper container
//               child: Swiper(
//                 axisDirection: AxisDirection.up,
//                 itemCount: moviePosters.length,
//                 layout: SwiperLayout.TINDER, // Stack effect
//                 itemWidth: 250,
//                 itemHeight: 300,
//                 loop: true,
//                 autoplay: false,
//                 scrollDirection: Axis.vertical, // Enables top-to-bottom swipe
//                 itemBuilder: (context, index) {
//                   return Card(
//                     color: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.asset(
//                           moviePosters[index],
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//
//       ],
//     ),
//   );
// }
// }
