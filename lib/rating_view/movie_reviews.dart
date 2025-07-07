import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/rating_view/rating_provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../aggricator_screens/home_screen/home_provider/home_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_format.dart';
import 'list_reviews.dart';

class MovieRatings extends StatefulWidget {
  const MovieRatings({super.key, this.article});

  final article;

  @override
  State<MovieRatings> createState() => _MovieRatingsState();
}

class _MovieRatingsState extends State<MovieRatings> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.article['image_url'] ?? "",
                  height: screenHeight * (widget.article['subType'] == "BigBlackStandard" ? 0.5 : 0.3),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.borderColor.withOpacity(.2),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey.shade300),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        height(height: 10),
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), offset: Offset(0, 3))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ratingBlock("Chota Meter", widget.article['chotaMeter']),
                              width(width: 20),
                              ratingBlock("Critic Rating", widget.article['chotarating']),
                            ],
                          ),
                        ),
                        height(height: 10),
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Text(widget.article['title'], style: fontStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                        height(height: 8),
                        Consumer<RatingProvider>(builder: (_, ratingProvider, __) {
                          ratingProvider.selectedStar = widget.article['userRating'] ?? 0;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        ratingProvider.selectedStar = index + 1;
                                      });
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (index < ratingProvider.selectedStar)
                                          Icon(
                                            Icons.star,
                                            color: AppColors.ratingColor,
                                            size: 36,
                                          ),
                                        Icon(
                                          Icons.star_outline_outlined,
                                          color: index < ratingProvider.selectedStar ? AppColors.ratingColor : Colors.grey,
                                          size: 36,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              height(height: 12),
                              if (widget.article['userHasReviewed'] == false)
                                TextFormField(
                                  onTap: () {
                                    context.read<HomeProvider>().pageChange(isValue: false);
                                  },
                                  controller: ratingProvider.commentController,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                  decoration: InputDecoration(
                                    hintText: "Type your comment here (optional)",
                                    hintStyle: TextStyle(fontSize: 12, color: Colors.black45),
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
                              if (widget.article['userHasReviewed'] == false) height(height: 12),
                              if (widget.article['userHasReviewed'] == false)
                                GestureDetector(
                                  onTap: ratingProvider.selectedStar >= 1
                                      ? () {
                                          if (ratingProvider.commentController.text.isNotEmpty && ratingProvider.selectedStar > 1) {
                                            ratingProvider.postSubmitRating(widget.article['id']);
                                          } else {
                                            print("Add comment & select more than 1 star");
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
                            Text("Critics Reviews", style: fontStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                                child: Text("More >", style: fontStyle(color: Colors.lightBlue, fontSize: 16, fontWeight: FontWeight.w600))),
                          ],
                        ),
                        // height(height: 16),
                        // SizedBox(
                        //   height: 115,
                        //   width: 298,
                        //   child: ListView.builder(
                        //     shrinkWrap: true,
                        //     scrollDirection: Axis.horizontal,
                        //     itemCount: widget.article["topComments"].length,
                        //     itemBuilder: (context, index) {
                        //       return Container(
                        //         height: 100,
                        //         width: 298,
                        //         margin: EdgeInsets.only(right: 12),
                        //         padding: EdgeInsets.all(12),
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(12),
                        //           border: Border.all(color: Colors.lightBlue),
                        //         ),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 Icon(Icons.account_circle, size: 24, color: Colors.black),
                        //                 width(width: 8),
                        //                 Text(widget.article["topComments"][index]["userName"], style: fontStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        //                 Spacer(),
                        //                 Icon(Icons.star, color: AppColors.ratingColor, size: 18),
                        //                 width(width: 4),
                        //                 Text('${widget.article["topComments"][index]["rating"].toString()}/5', style: fontStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        //               ],
                        //             ),
                        //             height(height: 6),
                        //             Text(
                        //               widget.article["topComments"][index]["comment"],
                        //               style: fontStyle(
                        //                 color: Colors.grey.shade800,
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.w500,
                        //               ),
                        //               maxLines: 2,
                        //               overflow: TextOverflow.ellipsis,
                        //             ),
                        //             height(height: 6),
                        //             Text(
                        //                 " ${formatTimeDifference(
                        //                   widget.article["topComments"][index]["createdAt"],
                        //                 )}",
                        //                 // widget.article["topComments"][index]["createdAt"],
                        //                 style: fontStyle(color: Colors.grey.shade500, fontSize: 12)),
                        //           ],
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 15,
              right: 12,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * (widget.article['subType'] == "BigBlackStandard" ? 0.508 : 0.278),
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Chota ",
                        style: fontStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "News",
                        style: fontStyle(color: Colors.lightBlue, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ratingBlock(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: fontStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          height(height: 2),
          Row(
            children: [
              Icon(Icons.star, color: AppColors.ratingColor, size: 18),
              width(width: 4),
              Text("$value / 5", style: fontStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox height({required double height}) => SizedBox(height: height);

  SizedBox width({required double width}) => SizedBox(width: width);
}
