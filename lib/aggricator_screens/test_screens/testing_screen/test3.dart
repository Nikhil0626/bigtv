// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_card_swiper/flutter_card_swiper.dart';
// //

// //
// // class HomeScreenView extends StatefulWidget {
// //   const HomeScreenView({super.key});
// //
// //   @override
// //   State<HomeScreenView> createState() => _HomeScreenViewState();
// // }
// //
// // class _HomeScreenViewState extends State<HomeScreenView> {
// //   final CardSwiperController controller = CardSwiperController();
// //   final List<int> swipedIndices = [];
// //   int currentIndex = 0;
// //
// //   @override
// //   void initState() {
// //     context.read<HomeBloc>().add(GetAllNewsFeed());
// //     super.initState();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: BlocBuilder<HomeBloc, HomeScreenState>(
// //         builder: (context, state) {
// //           if (state is InitialHomeScreenState) {
// //             return _buildLoading();
// //           } else if (state is SuccessHomeScreenState) {
// //             return CardSwiper(
// //               controller: controller,
// //               cardsCount: state.getAllHomeScreenNews.length,
// //               onSwipe: (previousIndex, newIndex, direction) {
// //                 if (direction == CardSwiperDirection.top) {
// //                   // Swipe Up: Next card
// //                   swipedIndices.add(previousIndex!);
// //                   currentIndex = newIndex!;
// //                   context.read<HomeBloc>().add(OnSwipeCard(
// //                     previousIndex: previousIndex,
// //                     currentIndex: currentIndex,
// //                     direction: direction,
// //                   ));
// //                 } else if (direction == CardSwiperDirection.bottom) {
// //                   // Swipe Down: Previous card
// //                   if (swipedIndices.isNotEmpty) {
// //                     currentIndex = swipedIndices.removeLast();
// //                     context.read<HomeBloc>().add(OnSwipeCard(
// //                       previousIndex: previousIndex!,
// //                       currentIndex: currentIndex,
// //                       direction: direction,
// //                     ));
// //                   }
// //                 }
// //                 return true;
// //               },
// //               onUndo: _onUndo,
// //               numberOfCardsDisplayed: 2,
// //               maxAngle: 0,
// //               threshold: 1,
// //               allowedSwipeDirection:
// //               const AllowedSwipeDirection.symmetric(vertical: true),
// //               padding: const EdgeInsets.all(0),
// //               cardBuilder: (context, index, _, __) {
// //                 return _buildCardContent(context, state, index);
// //               },
// //             );
// //           } else {
// //             return _buildError();
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLoading() {
// //     return Container(
// //       color: Colors.grey,
// //       width: MediaQuery.of(context).size.width,
// //       height: MediaQuery.of(context).size.height,
// //       child: const Center(
// //         child: CircularProgressIndicator(),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildError() {
// //     return Container(
// //       color: Colors.grey,
// //       width: MediaQuery.of(context).size.width,
// //       height: MediaQuery.of(context).size.height,
// //       child: const Center(
// //         child: Text(
// //           "Something went wrong. Please try again.",
// //           style: fontStyle(color: Colors.white, fontSize: 16),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCardContent(
// //       BuildContext context, SuccessHomeScreenState state, int index) {
// //     final newsItem = state.getAllHomeScreenNews[index];
// //     return state.pageType == "Gallery"
// //         ? CarouselScreen(
// //       imageList: newsItem.gallery ?? [],
// //     )
// //         : Container(
// //       decoration: const BoxDecoration(
// //         color: Colors.white,
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           newsItem.imageUrl.url.toString() != null
// //               ? Image.network(
// //             newsItem.imageUrl.url.toString(),
// //             fit: BoxFit.cover,
// //             width: MediaQuery.of(context).size.width,
// //             height: MediaQuery.of(context).size.height / 2,
// //           )
// //               : const SizedBox.shrink(),
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   state.pageType ?? "No Title",
// //                   style: const fontStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   newsItem.content,
// //                   style: fontStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey[800],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   bool _onUndo(
// //       int? previousIndex,
// //       int currentIndex,
// //       CardSwiperDirection direction,
// //       ) {
// //     debugPrint(
// //       'The card $currentIndex was undone from the ${direction.name}',
// //     );
// //     if (swipedIndices.isNotEmpty) {
// //       this.currentIndex = swipedIndices.removeLast();
// //     }
// //     return true;
// //   }
// // }
//
//
//
// /*import 'dart:async';
//
// import 'package:chotanews/screens/testing_screen/test_bloc.dart';
// import 'package:chotanews/screens/testing_screen/test_event.dart';
// import 'package:chotanews/screens/testing_screen/test_state.dart';
// import 'package:flip_board/flip_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../utils/app_colors.dart';
// import '../../utils/app_fonts.dart';
// import '../../utils/app_spaces.dart';
//
// class FlipWidgetsPage extends StatefulWidget {
//   const FlipWidgetsPage({Key? key}) : super(key: key);
//
//   @override
//   State<FlipWidgetsPage> createState() => _FlipWidgetState();
// }
//
// class _FlipWidgetState extends State<FlipWidgetsPage> {
//   final _flipController = StreamController<int>.broadcast();
//   final _spinController = StreamController<int>.broadcast();
//   int _nextFlipValue = 0;
//   int _nextSpinValue = 0;
//
//   @override
//   void initState() {
//     context.read<TestBloc>().add(TestEventOne());
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _flipController.close();
//     _spinController.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final greyColors = ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey);
//     final amberColors = ColorScheme.fromSwatch(primarySwatch: Colors.amber);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Flip & Spin')),
//       body: _flipWheel(greyColors),
//     );
//   }
//
//   Widget _flipWheel(ColorScheme colors) => _wheel('Flip Widget', colors, _flipWidget, _flipButton,_flipButton1);
//
//
//   Widget _wheel(
//       String title,
//       ColorScheme colors,
//       Widget Function(AxisDirection) widgetBuilder,
//       Widget button,
//       Widget button1,
//       ) =>
//       Container(
//         height: MediaQuery.of(context).size.height-120,
//         width: MediaQuery.of(context).size.width,
//         color: colors.background,
//         child: Stack(
//           // mainAxisSize: MainAxisSize.min,min
//           children: <Widget>[
//             // _wheelTitle(title, colors),
//             widgetBuilder(AxisDirection.up),
//             // Row(
//             //   mainAxisSize: MainAxisSize.min,
//             //   children: [
//             //     widgetBuilder(AxisDirection.left),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Row(
//                 children: [
//                   button,
//                   button1,
//                 ],
//               ),
//             ),
//
//             //     widgetBuilder(AxisDirection.right),
//             //   ],
//             // ),
//             // widgetBuilder(AxisDirection.down),
//           ],
//         ),
//       );
//
//   Widget _wheelTitle(String title, ColorScheme colors) => Container(
//     margin: const EdgeInsets.only(bottom: 12.0),
//     child: Row(
//       children: [
//         Container(
//           margin: const EdgeInsets.only(left: 24.0),
//           padding: const EdgeInsets.all(8.0),
//           color: colors.secondary,
//           child: Text(
//             title,
//             style: fontStyle(
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//               color: colors.onSecondary,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget get _flipButton => IconButton(
//     onPressed: _flip,
//     icon: const Icon(Icons.add_circle, size: 48.0),
//   );
//
//
//   Widget get _flipButton1 => IconButton(
//     onPressed: _flip1,
//     icon: const Icon(Icons.subdirectory_arrow_left, size: 48.0),
//   );
//
//
//   Widget _flipWidget(AxisDirection direction) => FlipWidget(
//     flipType: FlipType.middleFlip,
//     itemStream: _flipController.stream,
//     itemBuilder: _itemBuilder,
//     initialValue: _nextFlipValue,
//     flipDirection: AxisDirection.down,
//     flipCurve:  FlipWidget.bounceSlowFlip,
//     flipDuration: const Duration(milliseconds: 1000),
//     perspectiveEffect: 0.008,
//     hingeWidth: 1.0,
//     hingeLength: 56.0,
//     hingeColor: Colors.black,
//   );
//
//
//   Widget _itemBuilder(BuildContext context, int? value) => Container(
//     width: MediaQuery.of(context).size.width,
//     height:  MediaQuery.of(context).size.height-130,
//     alignment: Alignment.center,
//     decoration: BoxDecoration(
//       color: Theme.of(context).colorScheme.primaryContainer,
//       borderRadius: const BorderRadius.all(Radius.circular(4.0)),
//       border: Border.all(color: Theme.of(context).colorScheme.background),
//     ),
//     child: BlocBuilder<TestBloc, TestState>(
//       builder: (context, state) {
//         if (state is InitialState) {
//           return Container(
//             color: Colors.grey,
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: const Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else if (state is Success) {
//           return ListView.builder(
//             itemCount: state.newPosts.length,
//             itemBuilder: (context, index) {
//               final post = state.newPosts[index];
//               return GestureDetector(
//
//                 child: SizedBox(
//                   height: MediaQuery.of(context).size.height,
//                   width: MediaQuery.of(context).size.width,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Image.network(
//                         post.imageUrl?.url ?? "",
//                         width: double.infinity,
//                         height: 350,
//                         fit: BoxFit.fill,
//                         loadingBuilder:
//                             (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes !=
//                                   null
//                                   ? loadingProgress
//                                   .cumulativeBytesLoaded /
//                                   (loadingProgress
//                                       .expectedTotalBytes ??
//                                       1)
//                                   : null,
//                             ),
//                           );
//                         },
//                         errorBuilder: (context, error, stackTrace) {
//                           return Image.asset(
//                             "assets/chota",
//                             width: double.infinity,
//                             height: 270,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//                     Text(
//                           post.title ?? "",
//                           style: const fontStyle(
//                             color: AppColors.headerTextColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       Expanded(
//                         child:  Text(
//                             post.content ?? "",
//                             style: fontStyle(
//                               color: AppColors.bodyTextColor,
//                               fontWeight: FontWeight.normal,
//                               fontSize: 16,
//
//                           ),
//                         ),
//                       ),
//                       height(height: 8),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         } else {
//           // Error or other unexpected state
//           return Container(
//             color: Colors.grey,
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: const Center(
//               child: Text(
//                 "Something went wrong. Please try again.",
//                 style: fontStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           );
//         }
//       },
//     ),
//   );
//
//   void _flip() => _flipController.add(++_nextFlipValue );
//   void _flip1() => _flipController.add(--_nextFlipValue );
// }*/
//
//
// import 'dart:async';
// import 'dart:developer';
//
// import 'package:chotanews/screens/home_animation_widgets/collapse_widget_screen.dart';
// import 'package:chotanews/screens/testing_screen/test_bloc.dart';
// import 'package:chotanews/screens/testing_screen/test_event.dart';
// import 'package:chotanews/screens/testing_screen/test_state.dart';
// import 'package:flip_board/flip_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../utils/app_colors.dart';
// import '../../utils/app_fonts.dart';
// import '../../utils/app_spaces.dart';
//
// class PreviewScreen extends StatefulWidget {
//   const PreviewScreen({super.key});
//
//   @override
//   State<PreviewScreen> createState() => _PreviewScreenState();
// }
//
// class _PreviewScreenState extends State<PreviewScreen> {
//   final _streamController = StreamController.broadcast();
//   int _currentIndex = 0;
//   AxisDirection _flipDirection = AxisDirection.down;
//   bool _isFlipping = false;
//   double _dragStartY = 0;
//   double _dragProgress = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _streamController.add(_currentIndex);
//     context.read<TestBloc>().add(TestEventOne());
//   }
//
//   @override
//   void dispose() {
//     _streamController.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocBuilder<TestBloc, TestState>(
//         builder: (context, state) {
//           if (state is InitialState) {
//             return Container(
//               color: Colors.grey,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           } else if (state is Success) {
//             return GestureDetector(
//
//               onVerticalDragStart: (details) {
//                 _dragStartY = details.globalPosition.dy;
//               },
//               onVerticalDragUpdate: (details) {
//                 final screenHeight = MediaQuery.of(context).size.height;
//                 final dragDistance = details.globalPosition.dy - _dragStartY;
//                 _dragProgress = dragDistance / screenHeight;
//
//                 if (_dragProgress.abs() > 0.5 && !_isFlipping) {
//                   if (_dragProgress > 0) {
//                     _nextPage(state.newPosts.length);  // Swiping down
//                   } else {
//                     _previousPage();  // Swiping up
//                   }
//                 }
//               },
//               // onVerticalDragUpdate: (details) {
//               //   if (!_isFlipping) {
//               //     if (details.primaryDelta! < 0) {
//               //       _nextPage(state.newPosts.length);
//               //     } else if (details.primaryDelta! > 0) {
//               //       _previousPage();
//               //     }
//               //   }
//               // },
//               // onVerticalDragEnd: (details) {
//               //   if (!_isFlipping) {
//               //     if (details.velocity.pixelsPerSecond.dy > 0) {
//               //       _nextPage(state.newPosts.length);
//               //     } else if (details.velocity.pixelsPerSecond.dy < 0) {
//               //       _previousPage();
//               //     }
//               //   }
//               // },
//               child: FlipWidget(
//                 initialValue: _currentIndex,
//                 flipType: FlipType.middleFlip,
//                 itemStream: _streamController.stream,
//                 flipDuration: Duration(seconds: 1),
//                 itemBuilder: (_, index) {
//                   final post = state.newPosts[index];
//                   return Container(
//                     color: Colors.white,
//                     height: MediaQuery.of(context).size.height,
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height/2,
//                           width: MediaQuery.of(context).size.width,
//                           child: Image.network(
//                             post.imageUrl?.url ?? "",
//                             width: double.infinity,
//                             height: 350,
//                             fit: BoxFit.fill,
//                             loadingBuilder: (context, child, loadingProgress) {
//                               if (loadingProgress == null) return child;
//                               return Center(
//                                 child: CircularProgressIndicator(
//                                   value: loadingProgress.expectedTotalBytes != null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                       (loadingProgress.expectedTotalBytes ?? 1)
//                                       : null,
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return Image.asset(
//                                 "assets/chota",
//                                 width: double.infinity,
//                                 height: 270,
//                                 fit: BoxFit.cover,
//                               );
//                             },
//                           ),
//                         ),
//
//                         Expanded(
//                           child: Column(
//                             children: [
//                              Text(
//                                   post.content ?? "",
//                                   style: fontStyle(
//                                     color: AppColors.bodyTextColor,
//                                     fontWeight: FontWeight.normal,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                Text(
//                                   post.title ?? "",
//                                   style: fontStyle(
//                                     color: AppColors.headerTextColor,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         height(height: 8),
//                       ],
//                     ),
//                   );
//                 },
//                 flipDirection: _flipDirection,
//               ),
//             );
//           } else {
//             return Container(
//               color: Colors.grey,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child:  Center(
//                 child: Text(
//                   "Something went wrong. Please try again.",
//                   style:fontStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   void _nextPage(int listLength) async {
//     if (_currentIndex < listLength - 1 && !_isFlipping) {
//       setState(() {
//         _isFlipping = true;
//         _currentIndex++;
//         _flipDirection = AxisDirection.up;
//         _streamController.add(_currentIndex);
//       });
//       await Future.delayed(const Duration(milliseconds: 2000));
//       setState(() {
//         _isFlipping = false;
//       });
//     }
//   }
//
//   void _previousPage() async {
//     if (_currentIndex > 0 && !_isFlipping) {
//       setState(() {
//         _isFlipping = true;
//         _currentIndex--;
//         _flipDirection = AxisDirection.down;
//         _streamController.add(_currentIndex);
//       });
//       await Future.delayed(const Duration(milliseconds: 2000));
//       setState(() {
//         _isFlipping = false;
//       });
//     }
//   }
//
//
//   // Utility method for padding
//   Widget addPadding({required Widget child}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
//       child: child,
//     );
//   }
// }
//
//


import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class NativeAdsPageView extends StatefulWidget {
  const NativeAdsPageView({super.key});

  @override
  State<NativeAdsPageView> createState() => _NativeAdsPageViewState();
}

class _NativeAdsPageViewState extends State<NativeAdsPageView> {
  final PageController _pageController = PageController();
  final List<NativeAd> _nativeAds = [];
  final int _adCount = 5; // Number of ads to preload
  final List<bool> _isLoaded = [];

  @override
  void initState() {
    super.initState();
    _loadNativeAds();
  }

  void _loadNativeAds() {
    for (int i = 0; i < _adCount; i++) {
      final nativeAd = NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110', // Replace with your AdUnit
        factoryId: 'adFactoryExample', // Make sure to register this factory in iOS & Android
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint("Native Ad $i loaded");
            setState(() {
              _isLoaded[i] = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint("Native Ad $i failed: $error");
            ad.dispose();
          },
        ),
      );

      _nativeAds.add(nativeAd);
      _isLoaded.add(false);
      nativeAd.load();
    }
  }

  @override
  void dispose() {
    for (var ad in _nativeAds) {
      ad.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Native Ads in PageView")),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal, // change to Axis.vertical for vertical scroll
        itemCount: _nativeAds.length,
        itemBuilder: (context, index) {
          if (!_isLoaded[index]) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 16 / 9, // 👈 Adjust to 1/1, 3/4, 16/9 dynamically if needed
              child: AdWidget(ad: _nativeAds[index]),
            ),
          );
        },
      ),
    );
  }
}

