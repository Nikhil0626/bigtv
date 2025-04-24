import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwipeStackView extends StatefulWidget {
  @override
  _SwipeStackViewState createState() => _SwipeStackViewState();
}

class _SwipeStackViewState extends State<SwipeStackView>
    with TickerProviderStateMixin {
  List<Color> cardColors = [
    Colors.orange,
    Colors.blue,
    Colors.black,
    Colors.green,
    Colors.purple,
  ];

  List<Color> removedCards = [];

  Offset slideOffset = Offset.zero;
  bool isAnimating = false;

  void animateRemoveTopCard() async {
    if (cardColors.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, -1); // Slide up
    });
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      removedCards.add(cardColors.removeLast());
      slideOffset = Offset.zero;
      isAnimating = false;
    });
  }

  void animateUndoCard() async {
    if (removedCards.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, 1); // Start from bottom
      cardColors.add(removedCards.removeLast());
    });

    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      slideOffset = Offset.zero;
    });

    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      isAnimating = false;
    });
  }

  void animateRedoCard() => animateRemoveTopCard();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Swipe Stack"),
        actions: [
          IconButton(icon: Icon(Icons.undo), onPressed: animateUndoCard),
          IconButton(icon: Icon(Icons.redo), onPressed: animateRedoCard),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dy;

          if (velocity < -500) {
            animateRemoveTopCard();
          } else if (velocity > 500) {
            animateUndoCard();
          }
        },
        child: Center(
          child: cardColors.isEmpty
              ? Text(
            "No more cards!",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          )
              : Stack(
            alignment: Alignment.center,
            children: List.generate(cardColors.length, (index) {
              final isTopCard = index == cardColors.length - 1;
              double padding = (cardColors.length - index - 1) * 4.sp;

              return Positioned(
                top: padding,
                bottom: padding,
                left: padding,
                right: padding,
                child: AnimatedSlide(
                  offset: isTopCard ? slideOffset : Offset.zero,
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedOpacity(
                    opacity:
                    isTopCard && slideOffset.dy != 0 ? 0.0 : 1.0,
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOutCubic,
                    child: Card(
                      color: cardColors[index],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Text(
                          "Card ${index + 1}",
                          style: TextStyle(
                              fontSize: 20.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// import '../../aggricator_screens/home_screen/home_provider.dart';
// import '../../aggricator_screens/home_screen/image_view.dart';
// import '../../aggricator_screens/home_screen/standard_post_view.dart';
// import '../../utils/app_colors.dart';
// import '../home_screen/home_screens/in_app_web_view.dart';
// import '../videos_main/video_views/gallery_screen.dart';
//
// class SwipeStackView extends StatefulWidget {
//   @override
//   _SwipeStackViewState createState() => _SwipeStackViewState();
// }
//
// class _SwipeStackViewState extends State<SwipeStackView>
//     with TickerProviderStateMixin {
//   List<Map<String, dynamic>> displayedCards = [];
//   List<Map<String, dynamic>> removedCards = [];
//   Offset slideOffset = Offset.zero;
//   bool isAnimating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await context.read<HomeProvider>().getAllPost();
//       final posts = context.read<HomeProvider>().getAllPostList;
//       setState(() {
//         displayedCards = List<Map<String, dynamic>>.from(posts);
//       });
//     });
//   }
//
//   void animateRemoveTopCard() async {
//     if (displayedCards.isEmpty || isAnimating) return;
//     setState(() {
//       isAnimating = true;
//       slideOffset = Offset(0, -1);
//     });
//     await Future.delayed(Duration(milliseconds: 800));
//     setState(() {
//       removedCards.add(displayedCards.removeLast());
//       slideOffset = Offset.zero;
//       isAnimating = false;
//     });
//   }
//
//   void animateUndoCard() async {
//     if (removedCards.isEmpty || isAnimating) return;
//     setState(() {
//       isAnimating = true;
//       slideOffset = Offset(0, 1);
//       displayedCards.add(removedCards.removeLast());
//     });
//
//     await Future.delayed(Duration(milliseconds: 50));
//     setState(() {
//       slideOffset = Offset.zero;
//     });
//
//     await Future.delayed(Duration(milliseconds: 800));
//     setState(() {
//       isAnimating = false;
//     });
//   }
//
//   Widget buildCard(Map<String, dynamic> post, int index) {
//     final homeProvider = context.read<HomeProvider>();
//     final type = post['type'].toString();
//
//     if (type == "WebUrl") {
//       return InkWell(
//         onTap: () {
//           Navigator.push(context, MaterialPageRoute(
//             builder: (context) => InAppWebViewScreen(
//               webUrl: homeProvider.webUrl.toString(),
//               title: "IPL Update",
//             ),
//           ));
//         },
//         child: ClipRRect(
//           borderRadius: BorderRadius.all(Radius.circular(10.r)),
//           child: Image.asset(
//             "assets/svg/ipl.png",
//             fit: BoxFit.cover,
//           ),
//         ),
//       );
//     } else if (type == "Image") {
//       return ImageView(index: index, getAllPostList: post);
//     } else if (type == "Gallery") {
//       return Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             child: FullPageCarousel(
//               isHome: false,
//               imageUrls: post['gallery'] ?? [],
//               postDetails: post,
//             ),
//           ),
//           Positioned(
//             top: 18,
//             right: 22,
//             child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
//               return GestureDetector(
//                 onTap: () {
//                   homeProvider.isBookMarkPost(post, context);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(7),
//                   decoration: BoxDecoration(
//                     color: (homeProvider.isBookMark.contains(post['id'].toString()) ||
//                         post['isBookmarked'] == 1)
//                         ? AppColors.appButtonColor
//                         : Colors.black54,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     (homeProvider.isBookMark.contains(post['id'].toString()) ||
//                         post['isBookmarked'] == 1)
//                         ? Icons.bookmark
//                         : Icons.bookmark_outline,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       );
//     } else {
//       return StandardCard(getAllPostList: post, index: index);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context, designSize: Size(360, 690));
//
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: Text("Swipe Stack"),
//         actions: [
//           IconButton(icon: Icon(Icons.undo), onPressed: animateUndoCard),
//           IconButton(icon: Icon(Icons.redo), onPressed: animateRemoveTopCard),
//         ],
//       ),
//       body: GestureDetector(
//         onVerticalDragEnd: (details) {
//           final velocity = details.velocity.pixelsPerSecond.dy;
//           if (velocity < -500) {
//             animateRemoveTopCard();
//           } else if (velocity > 500) {
//             animateUndoCard();
//           }
//         },
//         child: Center(
//           child: displayedCards.isEmpty
//               ? Text(
//             "No more cards!",
//             style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//           )
//               : Stack(
//             alignment: Alignment.center,
//             children: List.generate(displayedCards.length, (index) {
//               final isTopCard = index == displayedCards.length - 1;
//               double height = 530 - (displayedCards.length - 1 - index).toDouble() * 20;
//
//               return AnimatedSlide(
//                 offset: isTopCard ? slideOffset : Offset.zero,
//                 duration: Duration(milliseconds: 800),
//                 curve: Curves.easeInOutCubic,
//                 child: AnimatedOpacity(
//                   opacity: isTopCard && slideOffset.dy != 0 ? 0.0 : 1.0,
//                   duration: Duration(milliseconds: 800),
//                   curve: Curves.easeInOutCubic,
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                     child: SizedBox(
//                       height: height,
//                       width: double.infinity,
//                       child: buildCard(displayedCards[index], index),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
//
// class MyStackedPageView extends StatelessWidget {
//   final List<Color> colors = [
//     Colors.red,
//     Colors.green,
//     Colors.blue,
//     Colors.orange,
//     Colors.purple,
//     Colors.cyan,
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return PageView.builder(
//       itemCount: colors.length,
//       scrollDirection: Axis.vertical,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.all(5.0),
//           child: Card(
//             color: colors[index],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Center(
//               child: Text(
//                 'Card ${index + 1}',
//                 style: TextStyle(fontSize: 24, color: Colors.white),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
