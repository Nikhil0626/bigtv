// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../utils/app_colors.dart';
// import '../../utils/app_fonts.dart';
// import '../../utils/app_loading_screen.dart';
// import '../../utils/app_spaces.dart';
// import '../videos_main/video_views/video_preview.dart';
// import 'botton_actions.dart';
// import 'first_card_home_feeds.dart';
// import 'home_bloc.dart';
// import 'home_state.dart';
// import 'images_view.dart';
//
// enum FlipDirection { up, down }
//
// typedef IndexedItemBuilder<T> = Widget Function(
//     BuildContext context, int index);
//
// class MyHomePage1 extends StatelessWidget {
//   final digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
//   final String title;
//
//   MyHomePage1({Key? key, required this.title}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//         child: Column(
//           children: [
//             BlocConsumer<HomeBloc, HomeScreenState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   return Container(
//                     color: Colors.transparent,
//
//                     child: state is LoadingHomeScreenState
//                         ? Container(
//                       color: Colors.grey,
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height,
//                       child: const Center(
//                         child: AppLoadingScreen(),
//                       ),
//                     )
//                         : state is SuccessHomeScreenState
//                         ? FlipPanel.builder(
//                       itemBuilder: (context, index) {
//                         return GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () {
//
//                           },
//                           child: state.pageType == "Image"
//                               ? CachedNetworkImage(
//                             imageUrl: state.getAllHomeScreenNews[index].imageUrl.url??"",
//                             imageBuilder: (context, imageProvider) =>
//                                 Container(
//                                   height: MediaQuery.of(context).size.height,
//                                   width: MediaQuery.of(context).size.width,
//                                   decoration: BoxDecoration(
//                                     image: DecorationImage(
//                                       image: imageProvider,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                             errorWidget: (context, url, error) => Container(
//                               height: MediaQuery.of(context).size.height,
//                               width: MediaQuery.of(context).size.width,
//                               decoration: BoxDecoration(
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(32)),
//                                   border: Border.all(
//                                       width: 1,
//                                       color:  Colors.black)),
//                               child: Center(
//                                 child: Text(
//                                   "H",
//                                   style: fontStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                             ),
//                           )
//                               : state.pageType == "Gallery"
//                               ? CarouselScreen(
//                             imageList: state
//                                 .getAllHomeScreenNews[
//                             index]
//                                 .gallery ??
//                                 [],
//                           )
//                               : state.getAllHomeScreenNews[index]
//                               .title ==
//                               "Home" ||state.getAllHomeScreenNews[index]
//                               .title ==
//                               "content" ||
//                               state
//                                   .getAllHomeScreenNews[
//                               index]
//                                   .homepage !=
//                                   null
//                               ? FirstCardHomeFeeds(
//                             getHomeList: state
//                                 .getAllHomeScreenNews[
//                             index]
//                                 .homepage,
//                           )
//                               : Container(
//                             decoration: BoxDecoration(
//                               color: state.pageType ==
//                                   "Video"
//                                   ? Colors.black
//                                   : Colors.white,
//                             ),
//                             child: Stack(
//                               children: [
//                                 SizedBox(
//                                   height: MediaQuery.of(
//                                       context)
//                                       .size
//                                       .height /
//                                       2,
//                                   child: state.pageType ==
//                                       "Video"
//                                       ? VideoPreview(
//                                     url: state
//                                         .getAllHomeScreenNews[
//                                     index]
//                                         .videoUrl!
//                                         .url
//                                         .toString(),
//                                   )
//                                       : state
//                                       .getAllHomeScreenNews[
//                                   index]
//                                       .imageUrl
//                                       .url
//                                       .toString() !=
//                                       null
//                                       ? CachedNetworkImage(
//                                     imageUrl: state.getAllHomeScreenNews[index].imageUrl.url??"",
//                                     imageBuilder: (context, imageProvider) =>
//                                         Container(
//                                           height: MediaQuery.of(context).size.height,
//                                           width: MediaQuery.of(context).size.width,
//                                           decoration: BoxDecoration(
//                                             image: DecorationImage(
//                                               image: imageProvider,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                     errorWidget: (context, url, error) => Container(
//                                       height: MediaQuery.of(context).size.height,
//                                       width: MediaQuery.of(context).size.width,
//                                       decoration: BoxDecoration(
//                                           borderRadius: const BorderRadius.all(
//                                               Radius.circular(32)),
//                                           border: Border.all(
//                                               width: 1,
//                                               color:  Colors.black)),
//                                       child: Center(
//                                         child: Text(
//                                           "H",
//                                           style: fontStyle(
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.w500),
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                       : const SizedBox
//                                       .shrink(),
//                                 ),
//                                 Align(
//                                   alignment: Alignment
//                                       .bottomCenter,
//                                   child: Container(
//                                     padding:
//                                     const EdgeInsets
//                                         .symmetric(
//                                         horizontal:
//                                         16,
//                                         vertical:
//                                         8),
//                                     height: MediaQuery.of(
//                                         context)
//                                         .size
//                                         .height /
//                                         2,
//                                     decoration:
//                                     const BoxDecoration(
//                                       color:
//                                       Colors.white,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment
//                                           .start,
//                                       children: [
//                                         Text(
//                                           state.getAllHomeScreenNews[index]
//                                               .title ??
//                                               "No Title",
//                                           style:
//                                           fontStyle(
//                                             fontSize:
//                                             18,
//                                             fontWeight:
//                                             FontWeight
//                                                 .bold,
//                                             color: Colors
//                                                 .black,
//                                           ),
//                                         ),
//                                         height(
//                                             height: 10),
//                                         Text(
//                                           state.pageType ??
//                                               "No Title",
//                                           style:
//                                           fontStyle(
//                                             fontSize:
//                                             18,
//                                             fontWeight:
//                                             FontWeight
//                                                 .bold,
//                                             color: Colors
//                                                 .black,
//                                           ),
//                                         ),
//                                         height(
//                                             height: 16),
//                                         Text(
//                                           state
//                                               .getAllHomeScreenNews[
//                                           index]
//                                               .content,
//                                           style:
//                                           fontStyle(
//                                             fontSize:
//                                             16,
//                                             color: Colors
//                                                 .grey[
//                                             800],
//                                           ),
//                                         ),
//                                         const Spacer(),
//                                         const Divider(
//                                           color: AppColors
//                                               .borderColor,
//                                         ),
//                                         height(
//                                             height: 4),
//                                         Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment
//                                               .spaceAround,
//                                           children: [
//                                             BottomActions(
//                                               icon: Icons
//                                                   .refresh,
//                                               label:
//                                               'రిలోడ్',
//                                               onTap:
//                                                   () {},
//                                             ), // Reload
//                                             BottomActions(
//                                               icon: Icons
//                                                   .thumb_up,
//                                               label:
//                                               'లైక్',
//                                               onTap:
//                                                   () {},
//                                             ), // Like
//                                             BottomActions(
//                                               icon: Icons
//                                                   .comment,
//                                               label:
//                                               'కామెంట్',
//                                               onTap:
//                                                   () {},
//                                             ), // Comment
//                                             BottomActions(
//                                               icon: Icons
//                                                   .share,
//                                               label:
//                                               'షేర్',
//                                               onTap:
//                                                   () {},
//                                             ), // Share
//                                           ],
//                                         ),
//                                         height(
//                                             height: 10)
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                   itemsCount: digits.length,
//                   )
//                         : Container(
//                       color: Colors.grey,
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height,
//                       child: const Center(
//                         child: Text(
//                           "Something went wrong. Please try again.",
//                           style: TextStyle(
//                               color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FlipPanel<T> extends StatefulWidget {
//   final IndexedItemBuilder<T>? indexedItemBuilder;
//   final int? itemsCount;
//
//   const FlipPanel({
//     Key? key,
//     this.indexedItemBuilder,
//     this.itemsCount,
//   }) : super(key: key);
//
//   const FlipPanel.builder({
//     Key? key,
//     required IndexedItemBuilder<T> itemBuilder,
//     required this.itemsCount,
//   })  : assert(itemsCount != null),
//         assert(itemsCount != null),
//         indexedItemBuilder = itemBuilder,
//         super(key: key);
//
//   @override
//   _FlipPanelState<T> createState() => _FlipPanelState<T>();
// }
//
// class _FlipPanelState<T> extends State<FlipPanel>
//     with TickerProviderStateMixin {
//   FlipDirection direction = FlipDirection.up;
//   AnimationController? _controller;
//   Animation? _animation;
//   int? _currentIndex;
//   bool? _isReversePhase;
//
//   // bool? _running;
//   final _perspective = 0.00003;
//   final _zeroAngle = 0.0001;
//   Widget? _child1, _child2;
//   Widget? _upperChild1, _upperChild2;
//   Widget? _lowerChild1, _lowerChild2;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = 1;
//     _isReversePhase = true;
//     // _running = false;
//
//     _controller =
//     AnimationController(duration: Duration(milliseconds: 1000), vsync: this)
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           _isReversePhase = true;
//           _controller!.reverse();
//         }
//         if (status == AnimationStatus.dismissed) {
//           setState(() {
//             // _running = false;
//             _currentIndex = (_currentIndex! + 1) % widget.itemsCount!;
//           });
//         }
//       })
//       ..addListener(() {
//         setState(() {
//           // _running = true;
//         });
//       });
//
//     _animation =
//         Tween(begin: _zeroAngle, end: math.pi / 2).animate(_controller!);
//   }
//
//   @override
//   void dispose() {
//     _controller!.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _buildChildWidgetsIfNeed(context);
//
//     return GestureDetector(
//       onVerticalDragUpdate: (details) {
//         if (details.primaryDelta! > 0) {
//           // if (!_running!) {
//           _flipForward();
//           // }
//         } else if (details.primaryDelta! < 0) {
//           // if (!_running!) {
//           _flipBackward();
//           // }
//         }
//       },
//       child: AnimatedBuilder(
//         animation: _controller!,
//         builder: (context, child) {
//           return _buildPanel();
//         },
//       ),
//     );
//   }
//
//   void _flipBackward() {
//     // if (_running!) return;
//     print("bottom to top");
//
//     setState(() {
//       _isReversePhase = true;
//       direction = FlipDirection.up;
//       // _running = false; // Set running to true only when animation starts
//     });
//
//     _controller!.reverse().then((_) {
//       setState(() {
//         // _running = true; // Reset after animation completes
//         _currentIndex = (_currentIndex! - 1) % widget.itemsCount!;
//       });
//     });
//   }
//
//   void _flipForward() async{
//     // if (_running!) return;
//     print("top to bottom");
//     setState(() {
//       _isReversePhase = false;
//       direction = FlipDirection.up;
//       // _running = true; // Set running to true only when animation starts
//     });
//     _controller!.forward().then((_) {
//       setState(() {
//         // _running = false; // Reset after animation completes
//         _currentIndex = (_currentIndex! + 1) % widget.itemsCount!;
//       });
//     });
//   }
//
//   void _buildChildWidgetsIfNeed(BuildContext context) {
//     Widget makeUpperClip(Widget widget) {
//       return ClipRect(
//         child: Align(
//           alignment: Alignment.topCenter,
//           heightFactor: 0.5,
//           child: widget,
//         ),
//       );
//     }
//
//     Widget makeLowerClip(Widget widget) {
//       return ClipRect(
//         child: Align(
//           alignment: Alignment.bottomCenter,
//           heightFactor: 0.5,
//           child: widget,
//         ),
//       );
//     }
//
//     // if (_running!) {
//     if (_child1 == null) {
//       print("child111111");
//       _child1 = widget.indexedItemBuilder!(
//           context, (_currentIndex! - 1) % widget.itemsCount!);
//       _upperChild1 = makeUpperClip(_child1!);
//       _lowerChild1 = makeLowerClip(_child1!);
//     }
//     if (_child2 == null) {
//       print("child222222");
//
//       _child2 = widget.indexedItemBuilder!(
//           context, (_currentIndex! + 1) % widget.itemsCount!);
//       _upperChild2 = makeUpperClip(_child2!);
//       _lowerChild2 = makeLowerClip(_child2!);
//     }
//     // } else {
//     print("child elseeeee");
//     _child1 = widget.indexedItemBuilder!(
//         context, _currentIndex! % widget.itemsCount!);
//     _upperChild1 = makeUpperClip(_child1!);
//     _lowerChild1 = makeLowerClip(_child1!);
//     // }
//   }
//
//   Widget _TopBuildUpperFlipPanel() => Stack(
//     children: [
//       Transform(
//           alignment: Alignment.bottomCenter,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, _perspective)
//             ..rotateX(_zeroAngle),
//           child: _upperChild1),
//       Transform(
//         alignment: Alignment.bottomCenter,
//         transform: Matrix4.identity()
//           ..setEntry(3, 2, _perspective)
//           ..rotateX(_isReversePhase! ? _animation!.value : math.pi / 2),
//         child: _upperChild2,
//       ),
//     ],
//   );
//
//   Widget _BottomBuildUpperFlipPanel() => Stack(
//     children: [
//       Transform(
//           alignment: Alignment.bottomCenter,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, _perspective)
//             ..rotateX(_zeroAngle),
//           child: _upperChild2),
//       Transform(
//         alignment: Alignment.bottomCenter,
//         transform: Matrix4.identity()
//           ..setEntry(3, 2, _perspective)
//           ..rotateX(_isReversePhase! ? math.pi / 2 : _animation!.value),
//         child: _upperChild1,
//       ),
//     ],
//   );
//
//   Widget _TopBuildLowerFlipPanel() => Stack(
//     children: [
//       Transform(
//           alignment: Alignment.topCenter,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, _perspective)
//             ..rotateX(_zeroAngle),
//           child: _lowerChild2),
//       Transform(
//         alignment: Alignment.topCenter,
//         transform: Matrix4.identity()
//           ..setEntry(3, 2, _perspective)
//           ..rotateX(_isReversePhase! ? math.pi / 2 : -_animation!.value),
//         child: _lowerChild1,
//       ),
//     ],
//   );
//
//   Widget _BottombuildLowerFlipPanel() => Stack(
//     children: [
//       Transform(
//           alignment: Alignment.topCenter,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, _perspective)
//             ..rotateX(_zeroAngle),
//           child: _lowerChild1),
//       Transform(
//         alignment: Alignment.topCenter,
//         transform: Matrix4.identity()
//           ..setEntry(3, 2, _perspective)
//           ..rotateX(_isReversePhase! ? -_animation!.value : math.pi / 2),
//         child: _lowerChild2,
//       ),
//     ],
//   );
//
//   Widget _buildPanel() {
//     return direction == FlipDirection.up
//         ? Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         _TopBuildUpperFlipPanel(),
//         _TopBuildLowerFlipPanel(),
//       ],
//     )
//         : Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         _BottomBuildUpperFlipPanel(),
//         _BottombuildLowerFlipPanel(),
//       ],
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../videos_main/video_views/video_preview.dart';
import 'botton_actions.dart';
import 'first_card_home_feeds.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'images_view.dart';

enum FlipDirection { up, down }

typedef IndexedItemBuilder<T> = Widget Function(
    BuildContext context, int index);

class MyHomePage1 extends StatefulWidget {
  final String title;

  MyHomePage1({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage1> createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  @override
  void initState() {
    context.read<HomeBloc>().add(GetAllNewsFeed());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeScreenState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is LoadingHomeScreenState) {
            return const Center(child: AppLoadingScreen());
          } else if (state is SuccessHomeScreenState) {
            return FlipPanel.builder(
              itemBuilder: (context, index) => Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: _buildContent(context, state, index)),
              itemsCount: state.getAllHomeScreenNews.length,
            );
          } else {
            return const Center(
                child: Text("Something went wrong. Please try again."));
          }
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, SuccessHomeScreenState state, int index) {
    var item = state.getAllHomeScreenNews[index];

    if (state.pageType == "Image") {
      return CachedNetworkImage(
          imageUrl: item.imageUrl?.url ?? "", fit: BoxFit.cover);
    } else if (state.pageType == "Gallery") {
      return CarouselScreen(imageList: item.gallery ?? []);
    } else if (state.pageType == "Video") {
      return VideoPreview(url: item.videoUrl?.url ?? "", );
    } else if (item.homepage != null) {
      return FirstCardHomeFeeds(getHomeList: item.homepage);
    }

    return _buildTextContent(context, item);
  }

  Widget _buildTextContent(BuildContext context, var item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height / 2.2,
            child: CachedNetworkImage(
                imageUrl: item.imageUrl?.url ?? "", fit: BoxFit.cover)),
        Expanded(child:Column(
          children: [
            Text(item.title ?? "No Title",
                style: fontStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Text(item.content,
                  style: fontStyle(fontSize: 16, color: Colors.grey[800])),
            ),
            const Divider(color: AppColors.borderColor),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // BottomActions(icon: Icons.refresh, label: 'Refresh', onTap: () {}),
                // BottomActions(icon: Icons.thumb_up, label: 'Like', onTap: () {}),
                // BottomActions(icon: Icons.comment, label: 'Comment', onTap: () {}),
                // BottomActions(icon: Icons.share, label: 'Share', onTap: () {}),
              ],
            ),
          ],
        ))

      ],
    );
  }
}

class FlipPanel<T> extends StatefulWidget {
  final IndexedItemBuilder<T>? indexedItemBuilder;
  final int? itemsCount;

  const FlipPanel({
    Key? key,
    this.indexedItemBuilder,
    this.itemsCount,
  }) : super(key: key);

  const FlipPanel.builder({
    Key? key,
    required IndexedItemBuilder<T> itemBuilder,
    required this.itemsCount,
  })  : assert(itemsCount != null),
        assert(itemsCount != null),
        indexedItemBuilder = itemBuilder,
        super(key: key);

  @override
  _FlipPanelState<T> createState() => _FlipPanelState<T>();
}
class _FlipPanelState<T> extends State<FlipPanel> with TickerProviderStateMixin {
  FlipDirection direction = FlipDirection.down;
  AnimationController? _controller;
  Animation? _animation;
  int? _currentIndex;
  bool? _isReversePhase;
  final _perspective = 0.00003;
  final _zeroAngle = 0.0001;
  Widget? _child1, _child2;
  Widget? _upperChild1, _upperChild2;
  Widget? _lowerChild1, _lowerChild2;
  bool _isSwiping = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _isReversePhase = true;

    _controller =
    AnimationController(duration: Duration(milliseconds: 500), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isReversePhase = true;
          _controller!.reverse();
          _refreshDataForCurrentIndex();
        }
        if (status == AnimationStatus.dismissed) {
          setState(() {
            // Update the index when the flip animation is complete
            _currentIndex = _currentIndex!;
            _refreshDataForCurrentIndex();  // Ensure data refresh
          });
        }
      })
      ..addListener(() {
        setState(() {

        });
      });

    _animation =
        Tween(begin: _zeroAngle, end: math.pi / 2).animate(_controller!);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _refreshDataForCurrentIndex() {
    setState(() {
      if (_currentIndex! < 0) {
        _currentIndex = 0; // Prevent negative index
      } else if (_currentIndex! >= widget.itemsCount!) {
        _currentIndex = widget.itemsCount! - 1; // Prevent index out of range
      }

      _child1 = widget.indexedItemBuilder!(context, _currentIndex!);
      _upperChild1 = _makeUpperClip(_child1!);
      _lowerChild1 = _makeLowerClip(_child1!);

      int prevIndex = _currentIndex! - 1;
      if (prevIndex >= 0) {
        _child2 = widget.indexedItemBuilder!(context, prevIndex);
        _upperChild2 = _makeUpperClip(_child2!);
        _lowerChild2 = _makeLowerClip(_child2!);
      } else {
        _child2 = null;
      }
    });
  }


  // void _refreshDataForCurrentIndex() {
  //   setState(() {
  //     // Ensure that the current index stays within valid bounds
  //     if (_currentIndex! < 0) {
  //       _currentIndex = 0; // Prevent negative index
  //     } else if (_currentIndex! >= widget.itemsCount!) {
  //       _currentIndex = widget.itemsCount! - 1; // Prevent index out of range
  //     }
  //
  //     // Safely set the widget for the current index
  //     _child1 = widget.indexedItemBuilder!(context, _currentIndex!);
  //     _upperChild1 = _makeUpperClip(_child1!);
  //     _lowerChild1 = _makeLowerClip(_child1!);
  //
  //     // Safely set the widget for the next index (for _child2)
  //     int nextIndex = _currentIndex! + 1;
  //     if (nextIndex < widget.itemsCount!) {
  //       _child2 = widget.indexedItemBuilder!(context, nextIndex);
  //       _upperChild2 = _makeUpperClip(_child2!);
  //       _lowerChild2 = _makeLowerClip(_child2!);
  //     } else {
  //       _child2 = null; // Handle the case when the next index exceeds the range
  //     }
  //   });
  // }

  void _flipBackward() {
    if (_currentIndex! > 0) { // Ensure index does not go below 0
      setState(() {
        _isReversePhase = false;
        direction = FlipDirection.down;
        _currentIndex = (_currentIndex! - 1).clamp(0, widget.itemsCount! - 1);
      });

      _controller!.forward().then((_) {
        setState(() {
          _refreshDataForCurrentIndex();  // Refresh data after backward flip
        });
      });
    }
  }


  void _flipForward() {
    setState(() {
      _isReversePhase = false;
      direction = FlipDirection.up;
      _currentIndex = (_currentIndex! + 1).clamp(0, widget.itemsCount! + 1);
      print("Flipped Forward, Current Index: $_currentIndex");/// Ensure index doesn't exceed max index
    });

    _controller!.forward().then((_) {
      setState(() {
        _refreshDataForCurrentIndex();  // Refresh data on forward flip
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    _buildChildWidgetsIfNeed(context);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Only handle the drag if no animation is in progress and a swipe isn't already being processed
        if (!_controller!.isAnimating && !_isSwiping) {
          _isSwiping = true; // Mark that a swipe is in progress

          if (details.primaryDelta! > 0) {
            // Swipe down (flip backward)
            _flipBackward();  // Trigger backward flip when swiping down
          } else if (details.primaryDelta! < 0) {
            // direction = FlipDirection.down;

            _flipForward();
            setState(() {

            });// Trigger forward flip when swiping up
          }
        }
        // if (details.primaryDelta! > 0) {
        //   // Swipe down (flip backward)
        //   if (!_controller!.isAnimating) {
        //     _flipBackward();  // Trigger backward flip when swiping down
        //   }
        // } else if (details.primaryDelta! < 0) {
        //   // Swipe up (flip forward)
        //   if (!_controller!.isAnimating) {
        //     _flipForward();  // Trigger forward flip when swiping up
        //   }
        // }
      },

      onVerticalDragEnd: (details) {
        // Reset the swipe tracking when the drag ends
        _isSwiping = false;
      },
      onVerticalDragCancel: () {
        // Reset the swipe tracking if the drag is canceled
        _isSwiping = false;
      },
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          return _buildPanel();
        },
      ),
    );
  }

  void _buildChildWidgetsIfNeed(BuildContext context) {
    if (_child1 == null) {
      _child1 = widget.indexedItemBuilder!(
          context, (_currentIndex! + 1));
      _upperChild1 = _makeUpperClip(_child1!);
      _lowerChild1 = _makeLowerClip(_child1!);
    }

    if (_child2 == null) {
      _child2 = widget.indexedItemBuilder!(
          context, (_currentIndex! + 1));
      _upperChild2 = _makeUpperClip(_child2!);
      _lowerChild2 = _makeLowerClip(_child2!);
    }

    _child1 = widget.indexedItemBuilder!(
        context, _currentIndex!);
    _upperChild1 = _makeUpperClip(_child1!);
    _lowerChild1 = _makeLowerClip(_child1!);
  }

  Widget _makeUpperClip(Widget widget) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.5,
        child: widget,
      ),
    );
  }

  Widget _makeLowerClip(Widget widget) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 0.5,
        child: widget,
      ),
    );
  }

  Widget _TopBuildUpperFlipPanel() => Stack(
    children: [
      Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _upperChild1),
      Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase! ? _animation!.value : math.pi / 2),
        child: _upperChild2,
      ),
    ],
  );

  Widget _BottomBuildUpperFlipPanel() => Stack(
    children: [
      Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _upperChild2),
      Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase! ? math.pi / 2 : _animation!.value),
        child: _upperChild1,
      ),
    ],
  );

  Widget _TopBuildLowerFlipPanel() => Stack(
    children: [
      Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _lowerChild2),
      Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase! ? math.pi / 2 : -_animation!.value),
        child: _lowerChild1,
      ),
    ],
  );

  Widget _BottombuildLowerFlipPanel() => Stack(
    children: [
      Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _lowerChild1),
      Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase! ? -_animation!.value : math.pi / 2),
        child: _lowerChild2,
      ),
    ],
  );

  Widget _buildPanel() {
    if(direction == FlipDirection.up){
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TopBuildUpperFlipPanel(),
          _TopBuildLowerFlipPanel(),
        ],
      );
    }else{
      return  Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BottomBuildUpperFlipPanel(),
          _BottombuildLowerFlipPanel(),
        ],
      );
    }
    // return Container(
    //   color: Colors.white,
    //   child: direction == FlipDirection.up
    //       ?
    //       :
    // );
  }
}

