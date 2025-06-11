import 'dart:developer';

import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'home_provider/home_provider.dart';
import 'main_screen_byts_view.dart';

class AiTagPostsPageView extends StatefulWidget {
  final bool isAiTags;
  final String tagName;
  final String tagId;

  const AiTagPostsPageView({super.key, this.isAiTags = false, this.tagName = "", this.tagId = ""});

  @override
  _AiTagPostsPageViewState createState() => _AiTagPostsPageViewState();
}

class _AiTagPostsPageViewState extends State<AiTagPostsPageView> {
  late PageController _pageController;
  int autoIndex = 0;

  @override
  void initState() {
    super.initState();
    autoIndex = 0;
    context.read<HomeProvider>().getAllPostsByAiId(widget.tagId);
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(() {
      setState(() {
        context.read<HomeProvider>().currentIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 14, right: 14),
                child: Row(
                  children: [
                    width(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    width(width: 16),
                    Expanded(
                        child: Text(
                      widget.tagName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: fontStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textColor),
                    )),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        color: AppColors.loginNumberBg,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: fontStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textColor,
                          ),
                          children: [
                            TextSpan(
                              text: "${homeProvider.getAllAiTagsPostList.isEmpty ? homeProvider.currentIndex : homeProvider.currentIndex + 1}",
                              style: fontStyle(color: AppColors.appButtonColor, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            TextSpan(
                              text: " / ",
                              style: fontStyle(color: AppColors.textColor, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            TextSpan(
                              text: "${homeProvider.getAllAiTagsPostList.length}",
                              style: fontStyle(color: AppColors.textColor, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    width(width: 10)
                  ],
                ),
              ),
              height(height: 10),
              Expanded(
                child: homeProvider.isAiTagsLoading
                    ? Center(
                        child: AppLoadingScreen(),
                      )
                    : homeProvider.getAllAiTagsPostList.isEmpty
                        ? Center(child: AppNoData())
                        : PageView.builder(
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            itemCount: homeProvider.getAllAiTagsPostList.length,
                            onPageChanged: (value) {
                              log("AiTagPostsPageView.  ${homeProvider.currentIndex}--- $value");
                              context.read<HomeProvider>().flipEvent('news', homeProvider.getAllAiTagsPostList[value]['id'], value > autoIndex ? true : false);

                              autoIndex = value;
                              setState(() {});
                              log(value.toString());
                              log(homeProvider.getAllAiTagsPostList.length.toString());
                              if (value == homeProvider.getAllAiTagsPostList.length - 1) {
                                context.read<HomeProvider>().addOneMoreArticle(); // <-- You need to implement this method
                              }
                            },
                            itemBuilder: (context, index) {
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
                                        child: MainScreenBytView(
                                          article: homeProvider.getAllAiTagsPostList[index],
                                          isaiTags: true,
                                          aiTagId: widget.tagId,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
