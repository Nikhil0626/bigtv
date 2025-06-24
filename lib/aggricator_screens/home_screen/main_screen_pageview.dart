import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_provider/home_provider.dart';
import 'main_screen_byts_view.dart';

class MainScreenPageView extends StatefulWidget {
  final int startIndex;
  final bool isAiTags;
  final String tagName;
  final String tagId;

  const MainScreenPageView({super.key, this.startIndex = 0, this.isAiTags = false, this.tagName = "", this.tagId = ""});

  @override
  _MainScreenPageViewState createState() => _MainScreenPageViewState();
}

class _MainScreenPageViewState extends State<MainScreenPageView> {

  int autoIndex = 0;
  final Gradient rainbowGradient = LinearGradient(
    colors: [
      Colors.blue,
      Colors.teal,
      Colors.red,
    ],
  );
HomeProvider? homeProvider;
  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context,listen: false);
    autoIndex = 0;
    super.initState();
    homeProvider?.pageController?.addListener(homeProvider!.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {


          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: PageView.builder(
                      physics: const ClampingScrollPhysics(parent: BouncingScrollPhysics()),
                      controller: homeProvider.pageController!,
                      scrollDirection: Axis.vertical,
                      itemCount: homeProvider.getAllPostList.length,
                      onPageChanged: (value) {
                        log("IndividualPostView  $autoIndex--- $value");
                        if(homeProvider.isBottomEnable) {
                          homeProvider.pageChange(isValue: false);
                        }
                        if (homeProvider.getAllPostList.length == value + 1 && homeProvider.isAiTagDataLoaded) {
                          Future.delayed(
                            Duration(milliseconds: 2000),
                                () {
                              log("IndividualPostView dddd $autoIndex--- $value ==== ");
                              homeProvider.aiTagDataLoaded(false);
                              homeProvider.setSelectedTagId(0);
                              homeProvider.getAllPost(postIds:"0");
                            },
                          );
                        }

                        context.read<HomeProvider>().flipEvent('news', homeProvider.getAllPostList[value]['id'], value > autoIndex ? true : false);
                        autoIndex = value;
                        setState(() {});
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.white,
                          child: MainScreenBytView(
                            article: homeProvider.getAllPostList[index],
                            PageController: homeProvider.pageController!,
                            length: homeProvider.getAllPostList.length,
                            index: index,
                            aiTagName: "",
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (context.watch<HomeProvider>().isAiTagDataLoaded && widget.isAiTags == false)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 3),
                    inactiveTrackColor: Colors.transparent,
                    activeTrackColor: Colors.white,
                    thumbColor: Colors.white,
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return rainbowGradient.createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Slider(
                      value: homeProvider.pageController!.hasClients ? (homeProvider.pageController!.page ?? 0) : 0,
                      min: 0,
                      max: (homeProvider.getAllPostList.length - 1).toDouble(),
                      onChanged: null, // read-only slider
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'main_screen_byts_view.dart';
//
// class MainScreenPageView extends StatefulWidget {
//   const MainScreenPageView({super.key});
//
//   @override
//   State<MainScreenPageView> createState() => _MainScreenPageViewState();
// }
//
// class _MainScreenPageViewState extends State<MainScreenPageView>  with TickerProviderStateMixin  {
//   int currentIndex = 0;
//   bool isSwiping = false;
//   bool isSwipeDown = false;
//   bool showBackCard = false;
//
//   late AnimationController _swipeAnimationController;
//   late Animation<double> _fadeAnimation;
//
//   double dragOffsetY = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _swipeAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 5),
//     );
//     _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeIn),
//     );
//   }
//
//
//
//   void _onVerticalDragUpdate(DragUpdateDetails details,getAllPost) {
//     setState(() {
//       dragOffsetY += details.delta.dy;
//       if (details.delta.dy < 0 && currentIndex < getAllPost.length - 1) {
//         isSwipeDown = false;
//         showBackCard = true;
//       } else if (details.delta.dy > 0 && currentIndex > 0) {
//         isSwipeDown = true;
//         showBackCard = true;
//       }
//     });
//   }
//
//   void _onVerticalDragEnd(DragEndDetails details,getAllPost) {
//     if (details.primaryVelocity == null || isSwiping) return;
//
//     if (details.primaryVelocity! < -200 && currentIndex < getAllPost.length - 1) {
//       _swipe(true);
//     } else if (details.primaryVelocity! > 200 && currentIndex > 0) {
//       _swipe(false);
//     } else {
//       setState(() {
//         dragOffsetY = 0.0;
//         showBackCard = false;
//       });
//     }
//   }
//
//
//   void _swipe(bool toNext) {
//     isSwiping = true;
//     _swipeAnimationController.reverse().then((_) {
//       setState(() {
//         currentIndex += toNext ? 1 : -1;
//         _swipeAnimationController.reset();
//         dragOffsetY = 0.0;
//         isSwiping = false;
//         showBackCard = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Consumer<HomeProvider>(
//       builder: (_,homeProvider,__) {
//
//         final posts = homeProvider.getAllPostList;
//
//         if (posts.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final current = homeProvider.getAllPostList[currentIndex];
//         final next = currentIndex < homeProvider.getAllPostList.length - 1 ? homeProvider.getAllPostList[currentIndex + 1] : null;
//         final previous = currentIndex > 0 ? homeProvider.getAllPostList[currentIndex - 1] : null;
//
//         return GestureDetector(
//           onVerticalDragUpdate: (details) {
//             _onVerticalDragUpdate(details,homeProvider.getAllPostList);
//           },
//           onVerticalDragEnd: (details) {
//             _onVerticalDragEnd(details,homeProvider.getAllPostList);
//           },
//           child: Stack(
//             children: [
//               if (showBackCard && next != null && !isSwipeDown) _buildCard(next,homeProvider, isBehind: true),
//               if (showBackCard && previous != null && isSwipeDown) _buildCard(previous,homeProvider, isBehind: true),
//               AnimatedBuilder(
//                 animation: _fadeAnimation,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: _fadeAnimation.value,
//                     child: Transform.translate(
//                       offset: Offset(0, dragOffsetY),
//                       child: _buildCard(current,homeProvider),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       }
//     );
//   }
//
//   Widget _buildCard( article,homeProvider, {bool isBehind = false}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       // margin: EdgeInsets.all(isBehind ? 24 : 12),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black26, blurRadius: 10),
//         ],
//       ),
//       child:  MainScreenBytView(
//                             article: article,
//                             PageController: homeProvider.pageController!,
//                             length: homeProvider.getAllPostList.length,
//                             index: currentIndex,
//                             aiTagName: "",
//                           ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _swipeAnimationController.dispose();
//     super.dispose();
//   }
// }
