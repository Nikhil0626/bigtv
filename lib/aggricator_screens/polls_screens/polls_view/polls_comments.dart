import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../rating_screen/rating_provider/rating_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/date_format.dart';

class PollsComments extends StatefulWidget {
  final String postId;

  const PollsComments({super.key, required this.postId});

  @override
  State<PollsComments> createState() => _PollsCommentsState();
}

class _PollsCommentsState extends State<PollsComments> {
  @override
  void initState() {
    super.initState();
    context.read<PollProvider>().getAllPollComments(widget.postId, "sort_by");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        title: Text(
          "Poll Review Comments",
          style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Consumer<PollProvider>(
          builder: (_, pollProvider, __) {
            return pollProvider.getAllPollCommentsList.isEmpty
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
                          SizedBox(width: 7.w),
                          Text(
                            "/5",
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
                          itemCount: pollProvider.getAllPollCommentsList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final review = pollProvider.getAllPollCommentsList[index];
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
