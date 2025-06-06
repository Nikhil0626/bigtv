import 'dart:developer';

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
      // Colors.yellow,
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
    // _pageController = PageController(viewportFraction: 1.0);
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToIndex(widget.startIndex);
    // });
  }

  void _scrollToIndex(int index) {
    if (index >= 0) {
      homeProvider?.pageController!.jumpToPage(index); // For instant scroll
      // _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut); // Smooth scroll
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          if (homeProvider.getAllPostList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: PageView.builder(
                    controller: homeProvider.pageController!,
                    scrollDirection: Axis.vertical,
                    itemCount: homeProvider.getAllPostList.length,
                    onPageChanged: (value) {
                      log("IndividualPostView  $autoIndex--- $value");
                      homeProvider.pageChange(isValue: false);
                      if (homeProvider.getAllPostList.length == value + 1 && homeProvider.isAiTagDataLoaded) {
                        Future.delayed(
                          Duration(milliseconds: 150),
                          () {
                            log("IndividualPostView dddd $autoIndex--- $value ==== ");
                            context.read<HomeProvider>().aiTagDataLoaded(false);
                            context.read<HomeProvider>().getAllPost();

                          },
                        );
                      }

                      // if (homeProvider.getAllPostList.length - 40 == value && !homeProvider.isAiTagDataLoaded) {
                      //   int currentIndex = homeProvider.pageController!.page?.round() ?? value;
                      //   log("is come from lin----k ${homeProvider.getAllPostList[value]['id']}  --- ${currentIndex}");
                      //   context.read<HomeProvider>().getAllPost(postId: homeProvider.getAllPostList.last['id'].toString());
                      //   Future.delayed(Duration(seconds: 1),() {
                      //     WidgetsBinding.instance.addPostFrameCallback((_) {
                      //       if (homeProvider.pageController!.hasClients) {
                      //         homeProvider.pageController!.jumpToPage(currentIndex);
                      //         log("Jumped back to page $currentIndex");
                      //       } else {
                      //         log("PageController is NOT attached yet. Skipping jump.");
                      //       }
                      //     });
                      //   },);
                      //
                      // }

                      context.read<HomeProvider>().flipEvent('news', homeProvider.getAllPostList[value]['id'], value > autoIndex ? true : false);
                      autoIndex = value;
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: homeProvider.pageController!,
                        builder: (context, child) {
                          double position = 1.0;

                          if (homeProvider.pageController!.hasClients && homeProvider.pageController!.position.haveDimensions) {
                            double? page = homeProvider?.pageController!.page ?? 0;
                            position = (1 - (page - index).abs()).clamp(0.0, 1.0);
                          }

                            return Opacity(
                              opacity: position,
                              child: Transform.translate(
                                offset: Offset(0, 50 * (1 - position)),
                                child: Container(
                                  color: Colors.white,
                                  child: MainScreenBytView(
                                    article: homeProvider.getAllPostList[index],
                                    PageController: homeProvider.pageController!,
                                    length: homeProvider.getAllPostList.length,
                                    index: index,
                                    aiTagName: "",
                                  ),
                                ),
                              ),
                            );

                        },
                      );
                    },
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
