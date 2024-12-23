
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/articles_view/published_tweets_screen.dart';
import 'package:tweetai/screens/articles_view/ready_to_publish_screen.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../home_screen/home_provider.dart';
import 'draft_screen.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage>
    with SingleTickerProviderStateMixin {
  int current = 0;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:  RefreshIndicator(
        color:AppColors.appButtonColor,
        backgroundColor: Colors.white,
        onRefresh: () async{
          await context.read<HomeProvider>().getEngageTweets();
        },
          child: Column(
            children: [
              TabBar(
                  isScrollable: false,
                  indicatorColor: AppColors.appButtonColor,
                  dividerColor: Colors.white,
                  controller: tabController,
                  labelStyle: fontStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.appButtonColor,
                      fontSize: 13),
                  unselectedLabelStyle: fontStyle(
                      fontWeight: FontWeight.normal,
                      color: AppColors.headerTextColor,
                      fontSize: 13),
                  tabs: [
                    Tab(
                      child: Text(
                        "Draft (${context.read<HomeProvider>().draftTweetsList.length})",
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Schedule (${context.read<HomeProvider>().readyToPublishList.length})",
                        maxLines: 1,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Sent (${context.read<HomeProvider>().publishedTweetsList.length})",
                      ),
                    ),
                  ]),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    DraftScreen(),
                    ReadyToPublishScreen(),
                    PublishedTweetsScreen()
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
