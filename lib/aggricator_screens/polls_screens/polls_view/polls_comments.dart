import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../rating_screen/rating_provider/rating_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/date_format.dart';

class PollsComments extends StatefulWidget {
  const PollsComments({super.key});

  @override
  State<PollsComments> createState() => _PollsCommentsState();
}

class _PollsCommentsState extends State<PollsComments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        title: Text(
          "కుబేర సినిమా టీజర్",
          style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Consumer<RatingProvider>(
          builder: (_, ratingProvider, __) {
            final reviews = ratingProvider.getAllReviews['reviews'] ?? [];
            final overallRating = ratingProvider.getAllReviews['overall_rating']?.toString() ?? "0";

            return reviews.isEmpty
                ? Center(child: Text("No reviews available"))
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
                    SizedBox(width: 7.w),
                    Text(
                      "$overallRating/5",
                      style: fontStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "Most helpful reviews",
                        style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      Icon(Icons.filter_list_rounded, size: 25),
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
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.star, color: AppColors.ratingColor, size: 23),
                                SizedBox(width: 4.w),
                                Text(
                                  "$rating/5",
                                  style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              comment,
                              style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
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
