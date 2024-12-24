import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider.dart';
import '../x_tweete_view/x_tweet_screen.dart';
import 'home_swipe_card_provider.dart';
import 'models/engage_tweet_model.dart';

class HomeSwipeCard extends StatefulWidget {
  final EngageTweetModel item;
  final HomeProvider homeProvider;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  final int index;
  final int? currentSwipedIndex;
  final ValueChanged<int> onSwiped;
  final VoidCallback resetSwipedIndex;

  const HomeSwipeCard({
    super.key,
    required this.item,
    required this.homeProvider,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    required this.index,
    required this.currentSwipedIndex,
    required this.onSwiped,
    required this.resetSwipedIndex,
  });

  @override
  State<HomeSwipeCard> createState() => _HomeSwipeCardState();
}

// class _HomeSwipeCardState extends State<HomeSwipeCard> {
//   double offset = 0.0;
//   bool isExpand = false;
//
//   @override
//   void didUpdateWidget(HomeSwipeCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.currentSwipedIndex != widget.index && offset != 0) {
//       setState(() {
//         offset = 0;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeSwipeCardProvider>(
//         builder: (_, homeSwipeCardProvider, __) {
//       return GestureDetector(
//           onTap: widget.onTap,
//           onHorizontalDragUpdate: (details) {
//             offset += details.delta.dx;
//             if (offset > 0) offset = 0;
//             if (offset < -150) offset = -150;
//             setState(() {});
//           },
//           onHorizontalDragEnd: (details) {
//             if (offset <-50) {
//               homeSwipeCardProvider.handleDragEnd(details,
//                   widget.onSwiped(widget.index), widget.resetSwipedIndex);
//             } else {
//               offset = 0;
//               widget.resetSwipedIndex; // Reset swipe if threshold not met
//               setState(() {});
//             }
//           },
//           child: Stack(
//             children: [
//               if (offset < 0)
//                 Positioned.fill(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       InkWell(
//                         onTap: widget.onEdit,
//                         child: Container(
//                           width: 100,
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           decoration: const BoxDecoration(
//                               color: AppColors.appButtonColor,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(8))),
//                           alignment: Alignment.center,
//                           // padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Text(
//                             "Generate",
//                             maxLines: 2,
//                             style: fontStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.wColor),
//                           ),
//                         ),
//                       ),
//                       width(width: 8),
//                       InkWell(
//                         onTap: widget.onDelete,
//                         child: Container(
//                           width: 100,
//                           decoration: const BoxDecoration(
//                               color: Colors.red,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(8))),
//                           alignment: Alignment.center,
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           child: Text(
//                             "Delete",
//                             maxLines: 2,
//                             style: fontStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.wColor),
//                           ),
//                         ),
//                       ),
//                       width(width: 10)
//                     ],
//                   ),
//                 ),
//               Transform.translate(
//                 offset: Offset(offset, 0),
//                 child: Container(
//                   // duration: const Duration(milliseconds: 300),
//                   transform: Matrix4.translationValues(offset, 0, 0),
//                   color: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       widget.item.profilePic == null
//                           ? Container(
//                               height: 32,
//                               width: 32,
//                               decoration: BoxDecoration(
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(32)),
//                                   border: Border.all(
//                                       width: 1, color: Colors.black)),
//                               child: Center(
//                                 child: Text(
//                                   widget.item.userName
//                                       .toString()
//                                       .split('')
//                                       .first
//                                       .toString()
//                                       .toUpperCase(),
//                                   style: fontStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               height: 32,
//                               width: 32,
//                               decoration: BoxDecoration(
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(40)),
//                                 border:
//                                     Border.all(width: 1, color: Colors.black),
//                               ),
//                               child: CircleAvatar(
//                                 radius: 30,
//                                 backgroundImage: NetworkImage(
//                                     widget.item.profilePic.toString()),
//                               ),
//                             ),
//                       width(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   widget.item.profileName.toString(),
//                                   maxLines: 1,
//                                   style: fontStyle(
//                                     fontSize: 16,
//                                     color: AppColors.headerTextColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 width(width: 3),
//                                 const Icon(
//                                   Icons.verified,
//                                   color: Colors.blue,
//                                   size: 16,
//                                 ),
//                                 width(width: 3),
//                                 Text(
//                                   textAlign: TextAlign.center,
//                                   "@${widget.item.profileName}",
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                   style: fontStyle(
//                                     color: const Color(0xff6b7280),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 width(width: 3),
//                                 Text(
//                                   textAlign: TextAlign.center,
//                                   widget.homeProvider.formatTimeDifference(
//                                       widget.item.tweetCreatedAt.toString()),
//                                   style: fontStyle(
//                                     color: const Color(0xff6b7280),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 Spacer(),
//                                 // InkWell(
//                                 //   onTap: () {
//                                 //
//                                 //   },
//                                 //   child: Container(
//                                 //       height: 20,
//                                 //       width: 20,
//                                 //       padding: const EdgeInsets.all(1),
//                                 //       decoration: BoxDecoration(
//                                 //         borderRadius: const BorderRadius.all(
//                                 //             Radius.circular(5)),
//                                 //         border: Border.all(
//                                 //             width: 1, color: Colors.black),
//                                 //       ),
//                                 //       child: SvgPicture.asset(
//                                 //         "assets/x-logo.svg",
//                                 //         width: 17,
//                                 //         height: 17,
//                                 //       )),
//                                 // )
//                               ],
//                             ),
//
//                             height(height: 4),
//                             Text(
//                               widget.item.teluguText!.toString(),
//                               style: fontStyle(
//                                 fontSize: 14,
//                                 color: AppColors.bodyTextColor,
//                               ),
//                               maxLines: 4,
//                             ),
//                             height(height: 4),
//                             InkWell(
//                               onTap: () {
//                                 widget.homeProvider.launchURL(
//                                     widget.item.tweetUrl!.toString());
//                               },
//                               child: Text(
//                                 widget.item.tweetUrl.toString(),
//                                 maxLines: 1,
//                                 style: fontStyle(
//                                   fontSize: 14,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ),
//                             height(height: 10),
//                             Padding(
//                               padding: const EdgeInsets.only(right: 10.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   MiniCardsDataWidget(
//                                     icon: "assets/chat.svg",
//                                     count: formatCount(
//                                         widget.item.replyCount ?? 00),
//                                   ),
//                                   MiniCardsDataWidget(
//                                     icon: "assets/retweet.svg",
//                                     count: formatCount(
//                                         widget.item.retweetCount ?? 0),
//                                   ),
//                                   MiniCardsDataWidget(
//                                       icon: "assets/fav.svg",
//                                       count: formatCount(
//                                           widget.item.likeCount ?? 00)),
//                                   MiniCardsDataWidget(
//                                       icon: "assets/replay.svg",
//                                       count: formatCount(
//                                           widget.item.replyCount ?? 00)),
//                                   MiniCardsDataWidget(
//                                       icon: "assets/trade.svg",
//                                       count: formatCount(
//                                           widget.item.engagementCount ?? 00)),
//                                 ],
//                               ),
//                             ),
//                             // width(width: 5),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ));
//     });
//   }
// }


class _HomeSwipeCardState extends State<HomeSwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFirstSwipeHintShown = false; // Ensure animation only plays once

  double offset = 0.0;
  bool isExpand = false;

  @override
  void initState() {
    super.initState();

    if (widget.index == 0 && !_isFirstSwipeHintShown) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );

      _animation = Tween<double>(begin: 0.0, end: -50.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      )..addListener(() {
        setState(() {
          offset = _animation.value;
        });
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playSwipeIndication();
      });
    }
  }

  void _playSwipeIndication() async {
    await _animationController.forward();
    await _animationController.reverse();
    setState(() {
      _isFirstSwipeHintShown = true; // Avoid repeating animation
    });
  }

  @override
  void didUpdateWidget(HomeSwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSwipedIndex != widget.index && offset != 0) {
      setState(() {
        offset = 0;
      });
    }
  }

  @override
  void dispose() {
    if (_animationController.isAnimating || _animationController.isCompleted) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeSwipeCardProvider>(
        builder: (_, homeSwipeCardProvider, __) {
          return GestureDetector(
              onTap: widget.onTap,
              onHorizontalDragUpdate: (details) {
                offset += details.delta.dx;
                if (offset > 0) offset = 0;
                if (offset < -220) offset = -220;
                setState(() {});
              },
              onHorizontalDragEnd: (details) {
                if (offset < -50) {
                  homeSwipeCardProvider.handleDragEnd(
                      details, widget.onSwiped(widget.index), widget.resetSwipedIndex);
                } else {
                  offset = 0;
                  widget.resetSwipedIndex(); // Reset swipe if threshold not met
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  if (offset < 0)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: widget.onEdit,
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  color: AppColors.appButtonColor,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                              alignment: Alignment.center,
                              child: Text(
                                "Generate",
                                maxLines: 2,
                                style: fontStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.wColor),
                              ),
                            ),
                          ),
                          width(width: 8),
                          InkWell(
                            onTap: widget.onDelete,
                            child: Container(
                              width: 100,
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Delete",
                                maxLines: 2,
                                style: fontStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.wColor),
                              ),
                            ),
                          ),
                          width(width: 10)
                        ],
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          widget.item.profilePic == null
                              ? Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32)),
                                border: Border.all(
                                    width: 1, color: Colors.black)),
                            child: Center(
                              child: Text(
                                widget.item.userName
                                    .toString()
                                    .split('')
                                    .first
                                    .toString()
                                    .toUpperCase(),
                                style: fontStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                              : Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(40)),
                              border:
                              Border.all(width: 1, color: Colors.black),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  widget.item.profilePic.toString()),
                            ),
                          ),
                          width(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.item.profileName.toString(),
                                      maxLines: 1,
                                      style: fontStyle(
                                        fontSize: 16,
                                        color: AppColors.headerTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    width(width: 3),
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    width(width: 3),
                                    Text(
                                      textAlign: TextAlign.center,
                                      "@${widget.item.profileName}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: fontStyle(
                                        color: const Color(0xff6b7280),
                                        fontSize: 12,
                                      ),
                                    ),
                                    width(width: 3),
                                    Text(
                                      textAlign: TextAlign.center,
                                      widget.homeProvider.formatTimeDifference(
                                          widget.item.tweetCreatedAt.toString()),
                                      style: fontStyle(
                                        color: const Color(0xff6b7280),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                height(height: 4),
                                Text(
                                  widget.item.teluguText!.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.bodyTextColor,
                                  ),
                                  maxLines: 4,
                                ),
                                height(height: 4),
                                InkWell(
                                  onTap: () {
                                    widget.homeProvider.launchURL(
                                        widget.item.tweetUrl!.toString());
                                  },
                                  child: Text(
                                    widget.item.tweetUrl.toString(),
                                    maxLines: 1,
                                    style: fontStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
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
                                      MiniCardsDataWidget(
                                          icon: "assets/trade.svg",
                                          count: formatCount(
                                              widget.item.engagementCount ?? 00)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ));
        });
  }
}
