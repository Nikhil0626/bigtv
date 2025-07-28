import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/app_colors.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../home_screen/home_support_widgets/image_preview.dart';
import '../rating_provider/rating_provider.dart';
import 'list_reviews.dart';

class MovieRatings extends StatefulWidget {
  const MovieRatings({super.key, this.article});

  final article;

  @override
  State<MovieRatings> createState() => _MovieRatingsState();
}

class _MovieRatingsState extends State<MovieRatings> {
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    context.read<RatingProvider>().commentController.text = "";
    if(widget.article['userHasReviewed'] == false && context.read<RatingProvider>().isArticleRated(widget.article['id'])) {
      context.read<RatingProvider>().selectedStar = 0;
    }else{
      context.read<RatingProvider>().ratingUpdate(widget.article['userRating']??0, widget.article['id']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Screenshot(
      controller: adsScreenshotController,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreview(
                      imageUrl: widget.article['image_url'],
                      title: widget.article['title'],
                    ),
                  ));
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .35,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.article['image_url'] ?? "",
                  height: screenHeight * 0.28,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.borderColor.withOpacity(.2),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * .58,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  height(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: AppColors.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ratingBlock("Chota Meter", widget.article['chotaMeter']),
                            ratingBlock("Critic Rating", widget.article['chotarating']),
                          ],
                        ),
                        if (widget.article['externalRatings'] != null && widget.article['externalRatings'] is List && widget.article['externalRatings'].isNotEmpty) Divider(),
                        height(height: 4),
                        if (widget.article['externalRatings'] != null && widget.article['externalRatings'] is List && widget.article['externalRatings'].isNotEmpty)
                          SizedBox(
                            height: widget.article['externalRatings'].length * 30.0, // approx height per item
                            child: ListView.builder(
                              itemCount: widget.article['externalRatings'].length,
                              physics: NeverScrollableScrollPhysics(), // prevent scroll inside Column
                              itemBuilder: (context, index) {
                                final rating = widget.article['externalRatings'][index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${rating['platform_name']}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: fontStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Row(
                                          children: [
                                            Icon(Icons.star, size: 16, color: AppColors.ratingColor),
                                            width(width: 10),
                                            Text(
                                              "${rating['platform_rating']}",
                                              style: fontStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  height(height: 10),
                  Text(widget.article['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: fontStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  height(height: 10),
                  Consumer<RatingProvider>(builder: (_, ratingProvider, __) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            return (widget.article['userHasReviewed'] == false && !ratingProvider.isArticleRated(widget.article['id']))
                                ? GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus(); // dismiss keyboard if open
                                      ratingProvider.ratingUpdate(index + 1, widget.article['id']);
                                      // ratingProvider.ratingUpdate(index + 1, widget.article['id']);
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (index < ratingProvider.getPostRating(widget.article['id']) )
                                          Icon(
                                            Icons.star,
                                            color: AppColors.ratingColor,
                                            size: 36,
                                          ),
                                        Icon(
                                          Icons.star_outline_outlined,
                                          color: index < ratingProvider.getPostRating(widget.article['id'])  ? AppColors.ratingColor : Colors.grey,
                                          size: 36,
                                        ),
                                      ],
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (index < ratingProvider.getPostRating(widget.article['id']) )
                                        Icon(
                                          Icons.star,
                                          color: AppColors.ratingColor,
                                          size: 36,
                                        ),
                                      Icon(
                                        Icons.star_outline_outlined,
                                        color: index < ratingProvider.getPostRating(widget.article['id'])  ? AppColors.ratingColor : Colors.grey,
                                        size: 36,
                                      ),
                                    ],
                                  );
                          }),
                        ),
                        height(height: 12),
                        if (widget.article['userHasReviewed'] == false && !ratingProvider.isArticleRated(widget.article['id']))
                          TextFormField(
                            onTap: () {
                              context.read<HomeProvider>().pageChange(isValue: false);
                            },
                            controller: ratingProvider.commentController,
                            style: fontStyle(fontSize: 13, fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              hintText: "Type your comment here (optional)",
                              hintStyle: fontStyle(fontSize: 12, color: Colors.black45),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.lightBlue),
                              ),
                            ),
                          ),
                        if (widget.article['userHasReviewed'] == false && !ratingProvider.isArticleRated(widget.article['id'])) height(height: 10),
                        if (widget.article['userHasReviewed'] == false && !ratingProvider.isArticleRated(widget.article['id']))
                          GestureDetector(
                            onTap: ratingProvider.selectedStar >= 1
                                ? () async {
                                    SharedPreferences sp = await SharedPreferences.getInstance();
                                    bool isLogin = sp.getString("loginType") != "login" ? true : false;

                                    if (isLogin) {
                                      CustomToast.showErrorToast(msg: "Your a guest user, Pleas login to give a rating");
                                    } else {
                                      ratingProvider.postSubmitRating(widget.article['id'], widget.article['userHasReviewed']);
                                    }
                                  }
                                : null,
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ratingProvider.selectedStar >= 1 ? Colors.lightBlue : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Submit",
                                style: fontStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  height(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Critics Reviews", style: fontStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Spacer(),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListReviews(
                                          postId: widget.article["id"].toString(),
                                        )));
                          },
                          child: Text("More >", style: fontStyle(color: Colors.lightBlue, fontSize: 14, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 12,
            child: InkWell(
              onTap: () async {
                try {
                  final image = await adsScreenshotController.capture(
                    pixelRatio: 2.0,
                  );
                  if (image != null) {
                    final directory = await getTemporaryDirectory();
                    final imagePath = '${directory.path}/${widget.article['id']}.png';
                    final imageFile = File(imagePath);
                    await imageFile.writeAsBytes(image);
                    Share.shareXFiles([XFile(imageFile.path)], text: widget.article['linkURLAndroid'].toString());
                  } else {
                    CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                  }
                } catch (e) {
                  CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                }
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: MediaQuery.of(context).size.height * .58 - 15,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Chota ",
                        style: fontStyle(
                          fontSize: Platform.isIOS ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "News",
                        style: fontStyle(
                          fontSize: Platform.isIOS ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff00A8FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ratingBlock(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: fontStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          height(height: 2),
          Row(
            children: [
              Icon(Icons.star, color: AppColors.ratingColor, size: 20),
              width(width: 6),
              Text("$value", style: fontStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox height({required double height}) => SizedBox(height: height);

  SizedBox width({required double width}) => SizedBox(width: width);
}
