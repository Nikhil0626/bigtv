import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_fonts.dart';
import '../../../utils/date_format.dart';
import '../rating_provider/rating_provider.dart';

class ListReviews extends StatefulWidget {
  final String postId;

  const ListReviews({super.key, required this.postId});

  @override
  State<ListReviews> createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {
  @override
  void initState() {
    super.initState();
    context.read<RatingProvider>().getReviews(widget.postId, "newest");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        title: Text(
          "సినిమా రివ్యూస్",
          style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Consumer<RatingProvider>(
          builder: (_, ratingProvider, __) {
            final reviews = ratingProvider.getAllReviews['reviews'] ?? [];
            final overallRating = ratingProvider.getAllReviews['overall_rating']?.toString() ?? "0";

            return reviews.isEmpty
                ? Center(child: AppNoData())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            "Overall Reviews",
                            style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: AppColors.ratingColor, size: 28),
                          width(width: 7.w),
                          Text(
                            "$overallRating/5",
                            style: fontStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      height(height: 20.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              "Most helpful reviews",
                              style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            // InkWell(
                            //   onTap: () {
                            //     ratingProvider.filterData(widget.postId);
                            //   },
                            //   child: Transform.rotate(
                            //     angle: 0.0, // 180 degrees in radians (π)
                            //     child: Icon(Icons.filter_list, size: 25),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      height(height: 15),
                      Expanded(
                        child: ListView.builder(
                          itemCount: reviews.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            final userName = review['user']?['name'] ?? "Anonymous";
                            final comment = review['comment'] ?? "";
                            final rating = review['rating']?.toString() ?? "0";
                            final timeAgo = formatTimeDifference(review['created_at'] ?? "");
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade400),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, size: 35, color: Colors.black),
                                      width(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          userName,
                                          style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.star, color: AppColors.ratingColor, size: 23),
                                      width(width: 4.w),
                                      Text(
                                        "$rating/5",
                                        style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  height(height: 5.h),
                                  Text(
                                    comment,
                                    style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  height(height: 8.h),
                                  Text(
                                    timeAgo,
                                    style: fontStyle(
                                      color: Colors.black54,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
