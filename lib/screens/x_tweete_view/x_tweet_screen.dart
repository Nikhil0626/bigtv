
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweet_model.dart';
import 'package:tweetai/utils/app_toasts.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_spaces.dart';
import '../articles_view/preview_screen.dart';
import '../home_screen/home_provider.dart';

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
      body: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
        return RefreshIndicator(
          color:AppColors.appButtonColor,
          backgroundColor: Colors.white,
          onRefresh: () => homeProvider.getTweetMetric(isCall: true),

          child: Column(
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
                          controller: homeProvider.xTweetsSearchController,
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
                            homeProvider.searchTweet(value.trim(),context,"tweet");
                          },
                        ),
                      ),
                      width(width: 10),
                      if( homeProvider.xTweetsSearchController.text.length>0)
                      IconButton(
                        onPressed: () {
                          homeProvider.xTweetsSearchController.clear();
                          FocusScope.of(context).unfocus();
                          homeProvider.searchTweet("",context,"tweet");
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
              Expanded(child: homeProvider.filteredTweetList.isEmpty?const AppNoData(): ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: AppColors.borderColor,
                ),
                itemCount: homeProvider.filteredTweetList.length,
                itemBuilder: (context, index) {
                  var item = homeProvider.filteredTweetList[index];
                  return SwipeableTile(
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

                        homeProvider.deleteXTweets(
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
        );


      }),
    );
  }
}

class SwipeableTile extends StatefulWidget {
  final XTwitterModel item;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final int index;
  final int? currentSwipedIndex;
  final ValueChanged<int> onSwiped;
  final VoidCallback resetSwipedIndex;

  const SwipeableTile({required this.item, required this.onDelete, required this.onTap, super.key, required this.index,
    required this.currentSwipedIndex,
    required this.onSwiped,
    required this.resetSwipedIndex,});

  @override
  _SwipeableTileState createState() => _SwipeableTileState();
}


class _SwipeableTileState extends State<SwipeableTile> {
  double offset = 0.0;
  bool maxLines = false;
  @override
  void didUpdateWidget(SwipeableTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSwipedIndex != widget.index && offset != 0) {
      offset = 0;
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap:widget.onTap,
        child: Stack(
          children: [
            if (offset < 0)
              Positioned.fill(
                child: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: widget.onDelete,
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(offset, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(offset, 0, 0),
                color: Colors.white,
                child: Padding(
                  padding:  const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.item.imageUrl == null
                          ? Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(40)),
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: Center(
                          child: Text(widget.item.userName.toString().split('').first.toString().toUpperCase(),style: fontStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),),
                        ),
                      )
                          : Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(40)),
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                          NetworkImage(widget.item.imageUrl.toString()),
                        ),
                      ),
                      width(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.item.userName.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: fontStyle(
                                      fontWeight: FontWeight.bold,
                                      color:const Color(0xff111928),
                                    ),
                                  ),
                                ),
                                width(width: 3),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                width(width: 3),

                                if (widget.item.profileName != null)
                                  Flexible(
                                    child: Text(
                                      "@${widget.item.profileName}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: fontStyle(
                                        color: const Color(0xff6b7280),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                width(width: 3.w),

                                Flexible(
                                  child: Text(
                                    context
                                        .read<HomeProvider>()
                                        .formatTimeDifference(
                                        widget.item.tweetCreatedAt ??
                                            "Nov 13, 2024 3:48 PM",isTweets:true),
                                    style: fontStyle(
                                      color: const Color(0xff6b7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),


                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0.sp),
                              child: Text(
                                widget.item.teluguText.toString(),
                                style: fontStyle(
                                  fontSize: 14,
                                  color: const Color(0xff6b7280),
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.item.tweetUrl != null)
                              InkWell(
                                onTap: (){
                                  context.read<HomeProvider>().launchURL(widget.item.tweetUrl
                                      .toString());
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 5.0.sp),
                                  child: Text(
                                    widget.item.tweetUrl.toString(),

                                    style: fontStyle(
                                      fontSize: 14,
                                      color: AppColors.appButtonColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            height(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MiniCardsDataWidget(
                                    icon: "assets/chat.svg",
                                    count: formatCount(
                                        widget.item.replyCount ?? 00),
                                  ),
                                  MiniCardsDataWidget(
                                    icon: "assets/retweet.svg",
                                    count: formatCount(
                                        widget.item.retweetCount ?? 0),
                                  ),
                                  MiniCardsDataWidget(
                                      icon: "assets/fav.svg",
                                      count: formatCount(
                                          widget.item.likeCount ?? 00)),
                                  MiniCardsDataWidget(
                                      icon: "assets/replay.svg",
                                      count: formatCount(
                                          widget.item.replyCount ?? 00)),
                                 // 00 MiniCardsDataWidget(
                                 //      icon: "assets/trade.svg",
                                 //      count: formatCount(
                                 //          widget.item.engagementCount ?? 00)),
                                ],
                              ),
                            ),
                            // height(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));




  }
}


class MiniCardsDataWidget extends StatelessWidget {
  final icon;
  final String count;

  const MiniCardsDataWidget(
      {super.key, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon,height: 14,width: 14,color: const Color(0xff6b7280),),
        width(width: 5),
        Text(
          count,
          textAlign: TextAlign.center,
          style: fontStyle(fontSize: 12, color: AppColors.headerTextColor,fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}