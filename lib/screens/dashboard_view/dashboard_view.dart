import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/utils/app_spaces.dart';

import '../../globel_keys/app_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_popups/delete_popup.dart';
import '../../utils/app_toasts.dart';
import '../articles_view/preview_screen.dart';
import '../home_screen/home_provider.dart';
import 'home_filter_view.dart';
import 'home_swipe_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
  void initState() {
    context.read<HomeProvider>().getEngageTweets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return context.watch<HomeProvider>().isEngageTweetsLoading
        ? const AppLoadingScreen()
        : Consumer<HomeProvider>(builder: (_, homeProvider, __) {
            return RefreshIndicator(
              color: AppColors.appButtonColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await context
                    .read<HomeProvider>()
                    .getEngageTweets(filter: true);
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 2),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // Background color for the search bar
                            border: Border.all(
                              color: Colors.grey.shade300, // Soft border color
                              width: 1, // Thin border
                            ),
                            borderRadius: BorderRadius.circular(5),
                            // Smooth rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                // Subtle shadow for depth
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 3), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Icon(
                                  Icons.search,
                                  color: AppColors
                                      .bodyTextColor, // Soft icon color
                                ),
                              ),
                              width(width: 10),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  controller: homeProvider.homeSearchController,
                                  decoration: InputDecoration(
                                    hintText: "Search...",
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 0),

                                    hintStyle: fontStyle(
                                        fontSize: 14,
                                        color: AppColors
                                            .bodyTextColor // Subtle hint text color
                                        ),
                                    border:
                                        InputBorder.none, // Removes the border
                                  ),
                                  style: fontStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.headerTextColor),
                                  onChanged: (value) {
                                    homeProvider.searchTweetHome(
                                        value.trim(), context);
                                  },
                                ),
                              ),
                              width(width: 10),
                              if(homeProvider.homeSearchController.text.length>0)
                              IconButton(
                                onPressed: () {
                                  homeProvider.homeSearchController.clear();
                                  FocusScope.of(context).unfocus();
                                  homeProvider.searchTweetHome("", context);
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 20,
                                  color: AppColors.bodyTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        color: AppColors.borderColor,
                      ),
                      Expanded(
                        child: homeProvider.filteredEngageList.isEmpty
                            ? const AppNoData()
                            : ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemCount:
                                    homeProvider.filteredEngageList.length,
                                itemBuilder: (context, index) {
                                  final tweet =
                                      homeProvider.filteredEngageList[index];
                                  return HomeSwipeCard(
                                    onTap: tweet.text == null
                                        ? () {
                                            CustomToast.showInfoToast(
                                                msg: "Preview Not Available");
                                          }
                                        : () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PreviewScreen(
                                                    tweetId:
                                                        tweet.id.toString(),
                                                    pageType: "send",
                                                    tweetTitle: tweet
                                                        .profileName
                                                        .toString(),
                                                    tweetBody: tweet.teluguText
                                                        .toString(),
                                                    tweetImage: tweet.profilePic
                                                                    .toString() !=
                                                                "No image" ||
                                                            tweet.profilePic
                                                                    .toString() !=
                                                                null
                                                        ? tweet.profilePic
                                                            .toString()
                                                        : "",
                                                  ),
                                                ));
                                          },
                                    item: tweet,
                                    onDelete: () {
                                      resetSwipedIndex();
                                      showDeleteConfirmation(
                                          context, index, tweet, "home");
                                    },
                                    onEdit: () {
                                      resetSwipedIndex();
                                      Navigator.pushNamed(context,
                                          RoutesManager.newsGenerateScreen,
                                          arguments: {
                                            'tweetId': tweet.id,
                                            'tweetText': '${tweet.teluguText}'
                                          });
                                    },
                                    homeProvider: homeProvider,
                                    index: index,
                                    currentSwipedIndex: currentSwipedIndex,
                                    onSwiped: onSwiped,
                                    resetSwipedIndex: resetSwipedIndex,
                                  );

                                  // _buildTweetItem(index, tweet,homeProvider);
                                },
                              ),
                      ),
                    ],
                  ),
                  if (homeProvider.isFilterEnable)
                    const Align(
                        alignment: Alignment.topCenter, child: HomeFilterView())
                ],
              ),
            );
          });
  }
}
