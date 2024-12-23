import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../globel_keys/app_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_popups/delete_popup.dart';
import '../home_screen/home_provider.dart';
import 'articles_swipe_card.dart';
import 'preview_screen.dart';

class ReadyToPublishScreen extends StatefulWidget {
  const ReadyToPublishScreen({super.key});

  @override
  State<ReadyToPublishScreen> createState() => _ReadyToPublishScreenState();
}

class _ReadyToPublishScreenState extends State<ReadyToPublishScreen> {
  int? currentSwipedIndex;

  void onSwiped(int index) {
    setState(() {
      currentSwipedIndex = index;
    });
  }

  void resetSwipedIndex() {
    setState(() {
      currentSwipedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return homeProvider.isEngageTweetsLoading
          ? const AppLoadingScreen()
          : homeProvider.readyToPublishList.isEmpty
              ? const AppNoData()
              : ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                        color: AppColors.borderColor,
                      ),
                  itemCount: homeProvider.readyToPublishList.length,
                  itemBuilder: (context, index) {
                    var data = homeProvider.readyToPublishList[index];

                    return Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: ArticlesSwipeCard(
                        screenType:"schedule",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewScreen(
                                  tweetId: data.id.toString(),
                                  pageType: "schedule",
                                  tweetTitle: data.generatedTitle.toString(),
                                  tweetBody: data.generatedData.toString(),
                                  tweetImage: data.imageUrl.toString()!="No image" || data.imageUrl.toString() != null?data.imageUrl.toString():"",

                              ),
                              ));
                        },
                        data: data,
                        isEdit: false,
                        index: index,
                        onEdit: () {
                          resetSwipedIndex();
                          Navigator.pushNamed(
                              context, RoutesManager.newsGenerateScreen,
                              arguments: {
                                'tweetId': data.id,
                                'tweetText': data.teluguText,
                                "screenType":"schedule"
                              });
                        },
                        onDelete: () {
                          resetSwipedIndex();
                          showDeleteConfirmation(
                              context, index, data, "schedule");
                        },
                        currentSwipedIndex: currentSwipedIndex,
                        onSwiped: onSwiped,
                        resetSwipedIndex: resetSwipedIndex,
                      ),
                    );
                  });
    });
  }
}
