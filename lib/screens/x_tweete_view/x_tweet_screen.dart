
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/home_screen/home_provider.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweet_swipe_card.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweets_provider.dart';
import 'package:tweetai/utils/app_toasts.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_spaces.dart';
import '../../utils/tweet_user_list.dart';
import '../articles_view/preview_screen.dart';

class XTweetScreen extends StatefulWidget {
  const XTweetScreen({super.key});

  @override
  State<XTweetScreen> createState() => _XTweetScreenState();
}

class _XTweetScreenState extends State<XTweetScreen> {

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<XTweetsProvider>(builder: (_, xTweetsProvider, __) {
        return RefreshIndicator(
          color:AppColors.appButtonColor,
          backgroundColor: Colors.white,
          onRefresh: () => xTweetsProvider.getTweetMetric(isCall: true),

          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
                    child:Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color for the search bar
                        border: Border.all(
                          color: Colors.grey.shade300, // Soft border color
                          width: 1, // Thin border
                        ),
                        borderRadius: BorderRadius.circular(5), // Smooth rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Subtle shadow for depth
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
                              color:AppColors.bodyTextColor, // Soft icon color
                            ),
                          ),
                          width(width: 10),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.start,
                              controller: xTweetsProvider.xTweetsSearchController,
                              decoration: InputDecoration(


                                hintText: "Search...",
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),

                                hintStyle: fontStyle(
                                    fontSize: 14,
                                    color: AppColors.bodyTextColor // Subtle hint text color
                                ),
                                border: InputBorder.none, // Removes the border
                              ),
                              style:  fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color:  AppColors.headerTextColor
                              ),

                              onChanged: (value) {
                                xTweetsProvider.searchTweet(value.trim(),context,"tweet");
                              },
                            ),
                          ),
                          width(width: 10),
                          if( xTweetsProvider.xTweetsSearchController.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              xTweetsProvider.xTweetsSearchController.clear();
                              FocusScope.of(context).unfocus();
                              xTweetsProvider.searchTweet("",context,"tweet");
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
                  const Divider(color: AppColors.borderColor,),
                  Expanded(child: xTweetsProvider.filteredTweetList.isEmpty?const AppNoData(): ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.borderColor,
                    ),
                    itemCount: xTweetsProvider.filteredTweetList.length,
                    itemBuilder: (context, index) {
                      var item = xTweetsProvider.filteredTweetList[index];
                      return XTweetSwipeCard(
                        onTap: item.generatedData == null
                                      ? () {
                                          CustomToast.showInfoToast(
                                              msg: "Preview Not Available");
                                        }
                                      : (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewScreen(
                                  tweetId: item.id.toString(),
                                  pageType: "send",
                                  tweetTitle: item.generatedTitle.toString(),
                                  tweetBody: item.generatedData.toString(),
                                  tweetImage: item.imageUrl.toString()!="No image" || item.imageUrl.toString() != null?item.imageUrl.toString():"",

                                ),
                              ));
                        },
                        key: Key(item.id.toString()),
                        item: item,
                        onDelete: () {

                          xTweetsProvider.deleteXTweets(
                                index, item, context); // Remove the item
                        },
                        index:index,
                        currentSwipedIndex: currentSwipedIndex,
                        onSwiped: onSwiped,
                        resetSwipedIndex: resetSwipedIndex,
                      );
                    },
                  ))
                ],
              ),
              if (context.watch<HomeProvider>().isFilterEnableXTweet)
                Align(
                    alignment: Alignment.topCenter, child: BottomSheetExample())
            ],
          ),
        );


      }),
    );
  }
}




