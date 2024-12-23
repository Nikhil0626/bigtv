
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_no_data.dart';
import '../home_screen/home_provider.dart';
import 'articles_swipe_card.dart';
import 'preview_screen.dart';

class PublishedTweetsScreen extends StatefulWidget {
  const PublishedTweetsScreen({super.key});

  @override
  State<PublishedTweetsScreen> createState() => _PublishedTweetsScreenState();
}

class _PublishedTweetsScreenState extends State<PublishedTweetsScreen> {
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
      return ListView.separated(
          separatorBuilder: (context, index) => const Divider(
                color: AppColors.borderColor,
                height: 1,
              ),
          itemCount: homeProvider.publishedTweetsList.length,
          itemBuilder: (context, index) {
            var data = homeProvider.publishedTweetsList[index];

            return Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: homeProvider.publishedTweetsList.isEmpty
                  ? const AppNoData()
                  : ArticlesSwipeCard(
                screenType:"send",
                      data: data,
                      isEdit: true,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewScreen(
                                tweetId: data.id.toString(),
                                pageType: "send",
                                tweetTitle: data.generatedTitle.toString(),
                                tweetBody: data.generatedData.toString(),
                                tweetImage: data.imageUrl.toString() !="No image" || data.imageUrl != null?data.imageUrl.toString():"",
                              ),
                            ));
                      },
                      index: index,
                      onEdit: () {},
                      onDelete: () {},
                      currentSwipedIndex: currentSwipedIndex,
                      onSwiped: onSwiped,
                      resetSwipedIndex: resetSwipedIndex,
                    ),
            );
          });
    });
  }
}
