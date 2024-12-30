import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweet_model.dart';
import 'package:tweetai/utils/tweet_bottom_widget.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider.dart';

class XTweetSwipeCard extends StatefulWidget {
  final XTwitterModel item;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final int index;
  final int? currentSwipedIndex;
  final ValueChanged<int> onSwiped;
  final VoidCallback resetSwipedIndex;

  const XTweetSwipeCard({required this.item, required this.onDelete, required this.onTap, super.key, required this.index,
    required this.currentSwipedIndex,
    required this.onSwiped,
    required this.resetSwipedIndex,});

  @override
  _XTweetSwipeCardState createState() => _XTweetSwipeCardState();
}


class _XTweetSwipeCardState extends State<XTweetSwipeCard> {
  double offset = 0.0;
  bool maxLines = false;
  @override
  void didUpdateWidget(XTweetSwipeCard oldWidget) {
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
                                width(width: 3),

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
                              padding: const EdgeInsets.only(top: 5.0),
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
                                  padding: const EdgeInsets.only(top: 5.0),
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
                                  TweetBottomWidget(
                                    icon: "assets/chat.svg",
                                    count: formatCount(
                                        widget.item.replyCount ?? 00),
                                  ),
                                  TweetBottomWidget(
                                    icon: "assets/retweet.svg",
                                    count: formatCount(
                                        widget.item.retweetCount ?? 0),
                                  ),
                                  TweetBottomWidget(
                                      icon: "assets/fav.svg",
                                      count: formatCount(
                                          widget.item.likeCount ?? 00)),
                                  TweetBottomWidget(
                                      icon: "assets/replay.svg",
                                      count: formatCount(
                                          widget.item.replyCount ?? 00)),
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