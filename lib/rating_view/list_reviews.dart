import 'package:chotanews/rating_view/rating_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../utils/app_fonts.dart';

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
    context.read<RatingProvider>().getReviews(widget.postId);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "కుబేర సినిమా టీజర్",
          style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 16), // fixes bottom overlap
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Overall Reviews",
                    style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              height(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.ratingColor,
                    size: 28,
                  ),
                  width(width: 7),
                  Text(
                    "3.5/5",
                    style: fontStyle(fontSize: 24.sp, fontWeight: FontWeight.w600,color: Colors.black),
                  ),
                ],
              ),
              height(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Most helpful reviews",
                          style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.filter_list_rounded,
                            color: Colors.black,
                            size: 25,
                          ),
                        )
                      ],
                    ),
                    height(height: 12),
                    ListView.builder(
                      itemCount: 20,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(

                          width: 327,
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
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
                                  width(width: 8),
                                  Text(
                                    "User Name",
                                    style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.star,
                                    color: AppColors.ratingColor,
                                    size: 23,
                                  ),
                                  width(width: 4),
                                  Text(
                                    "4/5",
                                    style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              height(height: 5),
                              Text(
                                "Lorem ipsum dolor sit amet, consectetur and Lorem ipsum dolor sit amet, consectetur ",
                                style: fontStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                                maxLines: 2,
                              ),
                              height(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "1 min ago",
                                    style: fontStyle(color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
