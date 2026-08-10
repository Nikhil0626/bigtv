

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/loading_screen/home_shimmer.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';


import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:provider/provider.dart';  
import 'main_screen_pageview.dart';

class MainScreenCard extends StatefulWidget {
  const MainScreenCard({
    super.key,
  });

  @override
  State<MainScreenCard> createState() => _MainScreenCardState();
}

class _MainScreenCardState extends State<MainScreenCard> with TickerProviderStateMixin {
  List<Map<String, dynamic>> removedCards = [];
  Offset slideOffset = Offset.zero;
  bool isAnimating = false;
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().getAllAiTags();
    if (context.read<HomeProvider>().postId.toString() == "0") {
      context.read<HomeProvider>().getAllPost();
    }
  }

  Map<int, GlobalKey> aiTagKeys = {};
  ScrollController aiTagScrollController = ScrollController();

  void aiTagsScrollToCenter(int index) {
    final keyContext = aiTagKeys[index]?.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      final size = box.size;
      final position = box.localToGlobal(Offset.zero);
      final screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

      final itemCenter = position.dx + size.width / 2;
      final targetOffset = aiTagScrollController.offset + itemCenter - screenWidth / 2;

      aiTagScrollController.animateTo(
        targetOffset.clamp(0.0, aiTagScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<HomeProvider, SettingsProvider>(builder: (_, homeProvider, settingsProvider, __) {
        return SafeArea(
          child: Center(
            child: homeProvider.isHomeLoading
                ? HomeShimmer()
                : Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 45.h,
                            color: AppColorTokens.primaryRed,
                            child: Row(
                              children: [
                                if (homeProvider.getAllAiTagsList.isNotEmpty)
                                  Expanded(
                                    child: ListView.separated(
                                      controller: homeProvider.aiTagScrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: homeProvider.getAllAiTagsList.length,
                                      separatorBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12.h),
                                          child: VerticalDivider(
                                            color: Colors.grey.withAlpha(5),
                                            thickness: 1,
                                            width: 10.w,
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        if (!homeProvider.aiTagKeys.containsKey(index)) {
                                          homeProvider.aiTagKeys[index] = GlobalKey();
                                        }

                                        final tag = homeProvider.getAllAiTagsList[index];
                                        final tagId = tag['aitagid'];
                                        final isSelected = homeProvider.selectedTagId == tagId;

                                        return InkWell(
                                          key: homeProvider.aiTagKeys[index],
                                          onTap: () async {
                                            homeProvider.setSelectedTagId(tagId);
                                            homeProvider.getAllPostsByAiId(tagId.toString());
                                            homeProvider.aiTagDataLoaded(true);
                                            context.read<VideoProvider>().pauseVideo();
                                            homeProvider.aiTagsScrollToCenter(index);
                                            EventRepo().addEvent({
                                              "aiTagName": tag['aitagname'].toString(),
                                              "aiTagId": tag['aitagid'].toString(),
                                              "createAt": DateTime.now().toString(),
                                            }, "ai_tag_click");
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: isSelected ? AppColorTokens.primaryRed : Colors.transparent,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              tag['aitagname'].toString(),
                                              style: TextStyle(
                                                color: AppColors.wColor,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(child: MainScreenPageView()),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      }),

    );
  }

  int currentIndexs = 0;
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          height(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              height: 20,
              width: 200,
              color: Colors.grey[300],
            ),
          ),
          height(height: 10.h),
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
          height(height: 20.h),
        ],
      ),
    );
  }

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
