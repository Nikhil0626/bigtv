import 'dart:developer';

import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'main_screen_byts_view.dart';

class MainScreenPageView extends StatefulWidget {
  final int startIndex; // 👈 Accept index to start from
  final bool isAiTags;
  final String tagName;
  final String tagId;

  const MainScreenPageView({super.key, this.startIndex = 0, this.isAiTags = false, this.tagName = "", this.tagId = ""});

  @override
  _MainScreenPageViewState createState() => _MainScreenPageViewState();
}

class _MainScreenPageViewState extends State<MainScreenPageView> {
  late PageController _pageController;
  int autoIndex = 0;

  @override
  void initState() {
    autoIndex = 0;
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(widget.startIndex);
    });
  }

  void _scrollToIndex(int index) {
    if (index >= 0) {
      _pageController.jumpToPage(index); // For instant scroll
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
              if (widget.isAiTags)
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 10),
                  child: Row(
                    children: [
                      width(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      width(width: 10),
                      Expanded(
                          child: Text(
                        "${widget.tagName}",
                        style: fontStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textColor),
                      )),
                      Container(
                          padding: EdgeInsets.all(2.sp),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), color: AppColors.loginNumberBg),
                          child: Text(
                            "3/${homeProvider.getAllPostList.length}",
                            style: fontStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textColor),
                          )),
                      width(width: 10)
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: homeProvider.getAllPostList.length,
                    onPageChanged: (value) {
                      log("IndividualPostView  $autoIndex--- $value");
                      context.read<HomeProvider>().flipEvent('news', homeProvider.getAllPostList[value]['id'], value > autoIndex ? true : false);

                      autoIndex = value;
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      if (homeProvider.getAllPostList.length - 5 == index) {
                        log("is come from lin----k${homeProvider.getAllPostList[index]['id']}");
                        context.read<HomeProvider>().getAllPost(postId: homeProvider.getAllPostList.last['id'].toString());
                      }
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double position = 1.0;

                          if (_pageController.hasClients && _pageController.position.haveDimensions) {
                            double? page = _pageController.page ?? 0;
                            position = (1 - (page - index).abs()).clamp(0.0, 1.0);
                          }

                          return Opacity(
                            opacity: position,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - position)),
                              child: Container(
                                color: Colors.white,
                                child: MainScreenBytView(article: homeProvider.getAllPostList[index]),
                              ),
                            ),
                          );
                        },
                      );
                    },
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
