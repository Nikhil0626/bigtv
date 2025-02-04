import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/date_format.dart';
import '../../utils/image_view_popup.dart';
import '../videos_main/video_views/video_preview.dart';
import 'botton_actions.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'images_view.dart';

enum FlipDirection { up, down }

typedef IndexedItemBuilder<T> = Widget Function(
    BuildContext context, int index);

class MyHomePage1 extends StatefulWidget {
final String tabName;
 const MyHomePage1({super.key,required this.tabName});

  @override
  State<MyHomePage1> createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  @override
  void initState() {
    initDynamicLinks();
    if(widget.tabName=="Home"){
      context.read<HomeBloc>().add(GetAllNewsFeed());
    }else{
      context.read<HomeBloc>().add(GetAllDistrictFeed());

    }
    super.initState();
  }
  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink?.link != null) {
      handleDeepLink(initialLink!.link);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      handleDeepLink(dynamicLinkData.link);
    }).onError((error) {
      print("Dynamic Link Error: $error");
    });
  }

  void handleDeepLink(Uri deepLink) {
    print("Opened with deep link: ${deepLink.toString()}");
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
            return Expanded(
              child: FlipPanel.builder(
                itemBuilder: (context, index) => _buildContent(context, state, index),
                itemsCount: state.getAllHomeScreenNews.length,
              ),
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
    log("post typeee -------  ${state.pageType}");
    if (state.pageType == "Image") {
      return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height-35,
        width: MediaQuery.of(context).size.width,
        child: CachedNetworkImage(
            imageUrl: item.imageUrl.url ?? "", fit: BoxFit.cover),
      );
    } else if (state.pageType == "Gallery") {
      return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height-35,
          width: MediaQuery.of(context).size.width,
          child: CarouselScreen(imageList: item.gallery ?? []));
    }

    // else if (item.homepage != null) {
    //   return FirstCardHomeFeeds(getHomeList: item.homepage);
    // }
    else{
      return _buildTextContent(context, item,state);
    }

  }

  Widget _buildTextContent(BuildContext context, var item, SuccessHomeScreenState state) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height-35,
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: (){
          context.read<HomeBloc>().add(MenuChange());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: state.pageType == "Video"
                          ? VideoPreview(url: item.videoUrl?.url ?? "")
                          : CachedNetworkImage(
                              imageUrl: item.imageUrl.url ?? "",
                              imageBuilder: (context, imageProvider) => Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32)),
                                ),
                                child: const Icon(
                                  Icons.account_box,
                                  size: 200,
                                ),
                              ),
                            )),
                  Positioned(
                      bottom: 1,
                      child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              color: AppColors.appButtonColor.withOpacity(.4),
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10))),
                          child: Image.asset("assets/images/brandlogo.png"))),
                  Positioned(
                      bottom: 10,
                      right: 10,
                      child: InkWell(
                          onTap: () {
                            if (state.pageType == "Video") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPreview(
                                      url: item.videoUrl?.url,
                                      isVideoScreen: true,
                                    ),
                                  ));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewPopup(
                                      imageUrl: item.imageUrl.url,
                                    ),
                                  ));
                            }
                          },
                          child: const Center(
                              child: Icon(
                            Icons.zoom_out_map_sharp,
                            color: AppColors.appButtonColor,
                            size: 24,
                          )))),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(item.title ?? "No Title",
                        style:
                            fontStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    height(height: 10),
                    Expanded(
                      child: Text(item.content,
                          style:
                              fontStyle(fontSize: 16, color: Colors.grey[800])),
                    ),
                    height(height: 4),
                    Text(formatTimeDifference( item.created),
                        style:
                        fontStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                    const Divider(color: AppColors.borderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BottomActions(
                            icon: "assets/svg/reload.svg",
                            label: 'రిలోడ్ ',
                            onTap: () {
                              log("Refresh");
                              context.read<HomeBloc>().add(GetAllNewsFeed());
                            }),
                        BottomActions(
                            icon: "assets/svg/like.svg",
                            label: 'లైక్',
                            onTap: () {
                              log("Like",);
                              context.read<HomeBloc>().add(GetAllNewsFeed());
                            }),
                        BottomActions(
                            icon: "assets/svg/comment.svg",
                            label: 'కామెంట్',
                            onTap: () {
                              log("Comment");
                              context.read<HomeBloc>().add(GetAllNewsFeed());
                            }),
                        BottomActions(
                            icon: "assets/svg/share.svg",
                            label: ' షేర్',
                            onTap: () {
                              log("Comment");
                              context.read<HomeBloc>().add(
                                  SendNewsToSocialMedia(id: item.linkURLAndroid));
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
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

class _FlipPanelState<T> extends State<FlipPanel>
    with TickerProviderStateMixin {
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

    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this)
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
            _refreshDataForCurrentIndex(); // Ensure data refresh
          });
        }
      })
      ..addListener(() {
        setState(() {});
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
      /// Ensure that the current index stays within valid bounds
      if (_currentIndex! < 0) {
        _currentIndex = 0; // Prevent negative index
      } else if (_currentIndex! >= widget.itemsCount!) {
        _currentIndex = widget.itemsCount! - 1; // Prevent index out of range
      }

      /// Safely set the widget for the current index
      _child1 = widget.indexedItemBuilder!(context, _currentIndex!);
      _upperChild1 = _makeUpperClip(_child1!);
      _lowerChild1 = _makeLowerClip(_child1!);

      /// Safely set the widget for the next index (for _child2)
      int nextIndex = _currentIndex! - 1;
      if (nextIndex < widget.itemsCount!) {
        _child2 = widget.indexedItemBuilder!(context, nextIndex);
        _upperChild2 = _makeUpperClip(_child2!);
        _lowerChild2 = _makeLowerClip(_child2!);
      } else {
        _child2 = null; // Handle the case when the next index exceeds the range
      }
    });
  }

  void _flipBackward() {
    if (_currentIndex! > 0) {
      setState(() {
        _isReversePhase = false;
        direction = FlipDirection.down;
        _currentIndex = (_currentIndex! - 1).clamp(0, widget.itemsCount! - 1);
      });

      _controller!.forward().then((_) {
        setState(() {
          _refreshDataForCurrentIndex(); // Refresh data after backward flip
        });
      });
    }
  }

  void _flipForward() {
    setState(() {
      _isReversePhase = false;
      direction = FlipDirection.up;
      _currentIndex = (_currentIndex! + 1).clamp(0, widget.itemsCount! + 1);
    });

    _controller!.forward().then((_) {
      setState(() {
        _refreshDataForCurrentIndex(); // Refresh data on forward flip
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildChildWidgetsIfNeed(context);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (!_controller!.isAnimating && !_isSwiping) {
          context.read<HomeBloc>().add(OnSwipeCard(index: _currentIndex!));
          _isSwiping = true;
          if (details.primaryDelta! > 0) {
            _flipBackward();
          } else if (details.primaryDelta! < 0) {
            _flipForward();
          }
        }
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
      _child1 = widget.indexedItemBuilder!(context, (_currentIndex! + 1));
      _upperChild1 = _makeUpperClip(_child1!);
      _lowerChild1 = _makeLowerClip(_child1!);
    }

    if (_child2 == null) {
      _child2 = widget.indexedItemBuilder!(context, (_currentIndex! + 1));
      _upperChild2 = _makeUpperClip(_child2!);
      _lowerChild2 = _makeLowerClip(_child2!);
    }

    _child1 = widget.indexedItemBuilder!(context, _currentIndex!);
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
    if (direction == FlipDirection.up) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TopBuildUpperFlipPanel(),
          _TopBuildLowerFlipPanel(),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BottomBuildUpperFlipPanel(),
          _BottombuildLowerFlipPanel(),
        ],
      );
    }
  }
}

class VideoScreenView extends StatelessWidget {
final  String url;
  const VideoScreenView({super.key,required this.url});

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController  controller = YoutubePlayerController(
      initialVideoId: url,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    return  YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
  }
}
