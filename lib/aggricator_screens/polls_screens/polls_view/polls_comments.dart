import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
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
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Poll Comments",
          style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<PollProvider>(
        builder: (_, pollProvider, __) {
          return pollProvider.isLoading?AppLoadingScreen():pollProvider.getAllPollCommentsList.isEmpty
              ? const Center(child: AppNoData())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          "Poll Results",
                          style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 150,
                      child: Builder(
                        builder: (_) {
                          final options = pollProvider.getAllPollCommentsList['options'] as List;
                          final int count = options.length;

                          return Align(
                            alignment: Alignment.center,
                            child: count == 2
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(count, (index) {
                                      final option = options[index];
                                      final percentage = option['percentage'] ?? 0;
                                      final optionName = option['option_text'] ?? '';

                                      final emoji = (index == 0) ? '👍' : '👎';
                                      final color = (index == 0) ? Colors.green : Colors.red;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color.withOpacity(0.12),
                                              ),
                                              child: Text(
                                                emoji,
                                                style: const TextStyle(fontSize: 26),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              optionName,
                                              style: fontStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$percentage%',
                                              style: fontStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: count,
                                    itemBuilder: (context, index) {
                                      final option = options[index];
                                      final percentage = option['percentage'] ?? 0;
                                      final optionName = option['option_text'] ?? '';

                                      // emoji + color for count 3 or 4
                                      String emoji = '❓';
                                      Color color = Colors.grey;

                                      if (count == 3) {
                                        if (index == 0) {
                                          emoji = '🙂';
                                          color = Colors.green;
                                        } else if (index == 1) {
                                          emoji = '😐';
                                          color = Colors.yellow.shade700;
                                        } else {
                                          emoji = '🙁';
                                          color = Colors.red;
                                        }
                                      } else if (count == 4) {
                                        if (index == 0) {
                                          emoji = '😍';
                                          color = Colors.green.shade900;
                                        } else if (index == 1) {
                                          emoji = '🙂';
                                          color = Colors.green;
                                        } else if (index == 2) {
                                          emoji = '😐';
                                          color = Colors.yellow;
                                        } else {
                                          emoji = '🙁';
                                          color = Colors.red;
                                        }
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color.withOpacity(0.12),
                                              ),
                                              child: Text(
                                                emoji,
                                                style: const TextStyle(fontSize: 26),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              optionName,
                                              style: fontStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            height(height: 1),
                                            Text(
                                              '$percentage%',
                                              style: fontStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          );
                        },
                      ),
                    ),

                    height(height: 10.h),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            "Poll reviews",
                            style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    height(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pollProvider.getAllPollCommentsList['comments'].length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final review = pollProvider.getAllPollCommentsList['comments'][index];
                          final String userName = review['userName'] ?? "Anonymous";
                          final String comment = review['comment'] ?? "";
                          final timeAgo = formatTimeDifference(review['createdAt']?.toString() ?? "");

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
                                    const Icon(Icons.account_circle, size: 35, color: Colors.black),
                                    width(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        userName,
                                        style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                                  style: fontStyle(color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w500),
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
    );
  }
}
