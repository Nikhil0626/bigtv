import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utils/app_fonts.dart';
import 'all_rewards.dart';
import 'claimed_rewards.dart';
import 'no_claimed_rewards.dart';
class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}
class _ReferEarnState extends State<ReferEarn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back, color: Colors.black, size: 25),
        title: Text(
          "Refer & Earn",
          style: fontStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoClaimedRewards(),
                            ),
                          );
                        },
                        child: Text("Refer & Earn",
                          style: fontStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        ),
                      ),
                      height(height: 10.h),
                      Text(
                        "Share ChotaNews app with friends and earn rewards!",
                        style: fontStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height(height: 15.h),
                      Text(
                        "My Referral code",
                        style: fontStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      height(height: 10.h),
                      Container(
                        height: 44.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "CHOTA2024XYZ",
                              style: fontStyle(
                                color: Colors.lightBlue,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.copy,
                              color: Colors.lightBlue,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                      height(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share_outlined, color: Colors.white, size: 25),
                              width(width: 12.w),
                              Text(
                                "Invite Friends",
                                style: fontStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            height(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 140.h,
                    width: 98.w,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue.shade100,
                              child: SvgPicture.asset(
                                'assets/images/users.svg',
                                fit: BoxFit.contain,
                                width: 24.w,
                                height: 24.h,
                              ),
                            ),
                            height(height: 8.h),
                            Text(
                              "120",
                              style: fontStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            height(height: 4.h),
                            Text(
                              "Invited",
                              style: fontStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 140.h,
                  width: 98.w,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green.shade100,
                            child: SvgPicture.asset(
                              'assets/images/download.svg',
                              width: 24.w,
                              height: 24.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          height(height: 8.h),
                          Text(
                            "80",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          height(height: 4.h),
                          Text(
                            "Downloads",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 140.h,
                  width: 98.w,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.shade100,
                            child: SvgPicture.asset(
                              'assets/images/pending.svg',
                              width: 24.w,
                              height: 24.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          height(height: 8.h),
                          Text(
                            "40",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          height(height: 4.h),
                          Text(
                            "Pending",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            height(height: 10.h),
            SizedBox(
              height: 124.h,
              width: 328.w,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Progress to next Reward",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: SvgPicture.asset(
                              'assets/images/progress_reward.svg',
                              width: 18.w,
                              height: 18.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      height(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "10 Friends referred",
                            style: fontStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "20 needed",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      height(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 8.h,
                          width: 300.w,
                          color: Colors.grey.shade300,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.6,
                            child: Container(
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ),
                      height(height: 4.h),
                      Text(
                        "You're 10 friends away from your next reward!",
                        style: fontStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            height(height: 10.h),
            Container(
              height: 88.h,
              width: 327.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade700,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange.shade600,
                      child: SvgPicture.asset(
                        'assets/images/gift.svg',
                        width: 24.w,
                        height: 24.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reward Earned",
                        style: fontStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      height(height: 4.h),
                      Text(
                        "2 GB Data",
                        style: fontStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClaimedRewards(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade500,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Claim",
                      style: fontStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            height(height: 5.h),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    "Popular Rewards",
                    style: fontStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AllRewards(),));
                      },
                      child: Text(
                        "View All",
                        style: fontStyle(color: Colors.lightBlue, fontSize: 14.sp, fontWeight: FontWeight.w600),
                      )),
                )
              ],
            ),
            height(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 141.h,
                  width: 155.w,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.shade600,
                            child: SvgPicture.asset(
                              'assets/images/gift.svg',
                              fit: BoxFit.contain,
                              width: 24.w,
                              height: 24.h,
                            ),
                          ),
                          height(height: 6.h),
                          Text(
                            "2GB Data",
                            style: fontStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "Free 1 day",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "10 Referrals",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 141.h,
                  width: 155.w,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: SvgPicture.asset(
                              'assets/images/progress_reward.svg',
                              fit: BoxFit.contain,
                              width: 24.w,
                              height: 24.h,
                            ),
                          ),
                          height(height: 6.h),
                          Text(
                            "Amazon Gift Card",
                            style: fontStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "₹100",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "20 Referrals",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            height(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 141.h,
                  width: 155.w,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.deepPurple.shade400,
                            child: SvgPicture.asset(
                              'assets/images/subscription.svg',
                              fit: BoxFit.contain,
                              width: 24.w,
                              height: 24.h,
                            ),
                          ),
                          height(height: 6.h),
                          Text(
                            "OTT Subscription",
                            style: fontStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "Free 1 months",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "50 Referrals",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 141.h,
                  width: 155.w,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green.shade500,
                            child: SvgPicture.asset(
                              'assets/images/instant_cash.svg',
                              fit: BoxFit.contain,
                              width: 24.w,
                              height: 24.h,
                            ),
                          ),
                          height(height: 6.h),
                          Text(
                            "Instant Cash",
                            style: fontStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "₹1000",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          height(height: 2.h),
                          Text(
                            "100 Referrals",
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            height(height: 15.h),
            SizedBox(
              height: 60.h,
              width: 327.w,
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/users.svg',
                            color: Colors.white,
                            fit: BoxFit.contain,
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ),
                      height(height: 2.h),
                      Text(
                        "Referral History",
                        style: fontStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      height(height: 2.h),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.grey.shade600,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            height(height: 5.h),
            SizedBox(
              height: 60.h,
              width: 327.w,
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/progress_reward.svg',
                            color: Colors.white,
                            fit: BoxFit.contain,
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ),
                      height(height: 2.h),
                      Text(
                        "Claimed Rewards",
                        style: fontStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      height(height: 2.h),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.grey.shade600,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
