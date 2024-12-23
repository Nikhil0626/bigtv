import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider.dart';

class ArticlesSwipeCard extends StatefulWidget {
  final String screenType;
  final data;
  final isEdit;
  final index;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final int? currentSwipedIndex;
  final ValueChanged<int> onSwiped;
  final VoidCallback onTap;
  final VoidCallback resetSwipedIndex;

  const ArticlesSwipeCard(
      {required this.data,
      required this.isEdit,
      required this.screenType,
      required this.index,
      required this.onDelete,
      required this.onEdit,
      required this.currentSwipedIndex,
      required this.onSwiped,
      required this.onTap,
      required this.resetSwipedIndex,
      super.key});

  @override
  State<ArticlesSwipeCard> createState() => _ArticlesSwipeCardState();
}

class _ArticlesSwipeCardState extends State<ArticlesSwipeCard> {
  double offset = 0.0;
  bool isExpand = false;

  @override
  void didUpdateWidget(ArticlesSwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSwipedIndex != widget.index && offset != 0) {
      setState(() {
        offset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data.imageUrl.toString());

    final List<String> imageUrls = widget.data.imageUrl.split(";");
print(" imgsssss ${imageUrls.toString()}");
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return GestureDetector(
        onHorizontalDragUpdate: (details) {
          offset += details.delta.dx;
          if (offset < -105) offset = -105; // Limit swipe to the left only
          if (offset > 0) offset = 0; // Prevent swipe to the right
          setState(() {});
        },
        onHorizontalDragEnd: (details) {
          if (offset < -50) {
            widget.onSwiped(widget.index);
            setState(() {});
          } else {
            offset = 0;
            widget.resetSwipedIndex; // Reset swipe if threshold not met
            setState(() {});
          }
        },
        onTap: widget.onTap,
        child: widget.isEdit
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.data.imageUrl.toString() == "No image" ||
                            widget.data.imageUrl.toString() == "" ||
                            widget.data.imageUrl == null ||
                        widget.data.imageUrl.toString() == "NULL"
                        ? Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                border:
                                    Border.all(width: 1, color: Colors.black)),
                            child: Center(
                              child: Text(
                                widget.data.userName
                                    .toString()
                                    .split('')
                                    .first
                                    .toString()
                                    .toUpperCase(),
                                style: fontStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(imageUrls.first.toString()),
                          ),
                    width(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.data.generatedTitle.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: fontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.headerTextColor,
                                  ),
                                ),
                              ),
                              width(width: 10),
                            ],
                          ),
                          height(height: 4),
                          Text(
                            widget.data.teluguText.toString(),
                            maxLines: 4,
                            style: fontStyle(
                              fontSize: 14,
                              color: AppColors.bodyTextColor,
                            ),
                          ),
                          height(height: 4),
                          InkWell(
                            onTap: () {
                              homeProvider
                                  .launchURL(widget.data.tweetUrl!.toString());
                            },
                            child: Text(
                              widget.data.tweetUrl.toString(),
                              style: fontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.appButtonColor,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          height(height: 12),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(2)),
                                    border: Border.all(
                                        color: AppColors.borderColor)),
                                padding: const EdgeInsets.all(2),
                                child: SvgPicture.asset(
                                  "assets/x-logo.svg",
                                  width: 12,
                                  height: 12,
                                ),
                              ),
                              width(width: 4),
                              RichText(
                                text: TextSpan(
                                    text:
                                    " @${widget.data.profileName.toString()}  ",
                                    style: fontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff6b7280),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: homeProvider
                                            .formatTimeDifference(widget
                                            .data.tweetCreatedAt
                                            .toString(),isTweets: widget.screenType=="send"?true:false),
                                        style: fontStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color:AppColors.bodyTextColor,
                                        ),
                                      )
                                    ]),
                              ),
                              width(width: 4),
Spacer(),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/user.svg",
                                    width: 12,
                                    height: 12,
                                  ),
                                  width(width: 4),
                                  SizedBox(
                                    width: 100,
                                    child: Expanded(
                                      child: Text(
                                          " ${widget.data.draftBy.toString()}  ",
                                          maxLines: 1,
                                          style: fontStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xff6b7280),
                                          ),),
                                    ),
                                  ),
                                  width(width: 4),
                                  Text(
                                   homeProvider
                                        .formatTimeDifference(widget
                                        .data.tweetCreatedAt
                                        .toString(),isTweets: widget.screenType=="send"?true:false),
                                    style: fontStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                      color:AppColors.bodyTextColor,
                                    ),
                                  ),

                                ],
                              )

                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
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
                              decoration: const BoxDecoration(
                                  color: AppColors.appButtonColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
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
                        ],
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: Container(
                      // duration: const Duration(milliseconds: 100),
                      transform: Matrix4.translationValues(offset, 0, 0),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.data.imageUrl.toString() == "No image" ||
                                    widget.data.imageUrl.toString() == "" ||
                                    widget.data.imageUrl == null ||widget.data.imageUrl.toString() == "NULL"
                                ? Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30)),
                                        border: Border.all(
                                            width: 1, color: Colors.black)),
                                    child: Center(
                                      child: Text(
                                        widget.data.userName
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
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                        imageUrls.first.toString()),
                                  ),
                            width(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.data.generatedTitle.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: fontStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.headerTextColor,
                                          ),
                                        ),
                                      ),
                                      width(width: 10),
                                    ],
                                  ),
                                  height(height: 4),
                                  Text(
                                    widget.data.teluguText.toString(),
                                    maxLines: 4,
                                    style: fontStyle(
                                      fontSize: 14,
                                      color: AppColors.bodyTextColor,
                                    ),
                                  ),
                                  height(height: 4),
                                  InkWell(
                                    onTap: () {
                                      homeProvider.launchURL(
                                          widget.data.tweetUrl!.toString());
                                    },
                                    child: Text(
                                      widget.data.tweetUrl.toString(),
                                      style: fontStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.appButtonColor,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  height(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(2)),
                                            border: Border.all(
                                                color: AppColors.borderColor)),
                                        padding: EdgeInsets.all(2),
                                        child: SvgPicture.asset(
                                          "assets/x-logo.svg",
                                          width: 12,
                                          height: 12,
                                        ),
                                      ),
                                      width(width: 4),
                                      RichText(
                                        text: TextSpan(
                                            text:
                                                " @${widget.data.profileName.toString()}  ",
                                            style: fontStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xff6b7280),
                                            ),
                                            children: [
                                              TextSpan(
                                                text: homeProvider
                                                    .formatTimeDifference(widget
                                                        .data.tweetCreatedAt
                                                        .toString(),isTweets: widget.screenType=="schedule"?true:false),
                                                style: fontStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                  color:
                                                      const Color(0xff6b7280),
                                                ),
                                              )
                                            ]),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/user.svg",
                                            width: 12,
                                            height: 12,
                                          ),
                                          width(width: 4),
                                          SizedBox(
                                            width: 100,
                                            child: Expanded(
                                              child: Text(
                                                " ${widget.screenType=="schedule"?widget.data.scheduledBy.toString():widget.data.draftBy.toString()}  ",
                                                maxLines: 1,
                                                style: fontStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xff6b7280),
                                                ),),
                                            ),
                                          ),
                                          width(width: 4),
                                          Text(
                                            homeProvider
                                                .formatTimeDifference(widget
                                                .data.tweetCreatedAt
                                                .toString(),isTweets: widget.screenType=="schedule"?true:false),
                                            style: fontStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                              color:AppColors.bodyTextColor,
                                            ),
                                          ),

                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
      );
    });
  }
}
