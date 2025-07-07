import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/settings_screen/referral_provider/referral_provider.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_fonts.dart';
import '../../event_repo.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ReferralProvider>().getReferralStats();
    getData();
  }

  String? myReferralCode;
  String? myReferralLink;



  void getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    myReferralCode =
        sharedPreferences.getString("myReferralCode") ?? "hello raja";
    myReferralLink =
        sharedPreferences.getString("myReferralLink") ?? "hello raja";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.black, size: 25)),
        title: Text(
          "Refer & Earn",
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Consumer<ReferralProvider>(builder: (_, referralProvider, __) {
          double progress = referralProvider.referralData['downloads'] /
              (referralProvider.referralData['needed'] +
                  referralProvider.referralData['downloads']);
          int difference = referralProvider.referralData['needed'];
          progress = progress.clamp(0.0, 1.0);
          return SingleChildScrollView(
              child: Column(
            children: [
              Container(
                // width: 350,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(18.0),
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
                      child: Text(
                        "Refer & Earn",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    height(height: 10.h),
                    Text(
                      "Share ChotaNews app with friends and earn rewards!",
                      style: TextStyle(
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
                      style: TextStyle(
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
                            "$myReferralCode",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            // onTap: (){
                            //   Clipboard.setData(ClipboardData(text: "${myReferralCode}"));
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text("Copied to clipboard")),
                            //   );
                            // },
                            child: Icon(
                              Icons.copy,
                              color: Colors.lightBlue,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    height(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          EventRepo().addEvent({
                            "shareApp": Platform.isIOS ? "iOS" : "Android",
                            "createAt": DateTime.now().toString(),
                          }, "share_app");
                          Share.share(
                            "Click link and get bonus: $myReferralLink",
                          );
                        },
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
                            Icon(Icons.share_outlined,
                                color: Colors.white, size: 25),
                            width(width: 12.w),
                            Text(
                              "Invite Friends",
                              style: TextStyle(
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
              height(height: 10.h),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        flex: 1,
                        child: InvitedCardScreen(
                          count: referralProvider.referralData['invited']
                              .toString(),
                          image: 'assets/images/users.svg',
                          name: "Invited",
                        )),
                    Expanded(
                        flex: 1,
                        child: InvitedCardScreen(
                          count: referralProvider.referralData['downloads']
                              .toString(),
                          image: 'assets/images/download.svg',
                          name: "Downloads",
                        )),
                    Expanded(
                        flex: 1,
                        child: InvitedCardScreen(
                          count: referralProvider.referralData['pending']
                              .toString(),
                          image: 'assets/images/pending.svg',
                          name: "Pending",
                        )),
                  ],
                ),
              ),
              height(height: 10.h),
              Container(
                height: 130,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
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
                              style: TextStyle(
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
                              "${referralProvider.referralData['downloads']} Friends referred",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${referralProvider.referralData['needed']} / ${referralProvider.referralData['needed'] +
                                  referralProvider.referralData['downloads']} needed",
                              style: TextStyle(
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
                              widthFactor: progress,
                              child: Container(
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                        height(height: 4.h),
                        Text(
                          "You're ${difference} friends away from your next reward!",
                          style: TextStyle(
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
              if (referralProvider.referralRewardsList.isNotEmpty)
                SizedBox(
                  height: 88.h,
                  width: 327.w,
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: PageController(viewportFraction: 1.0),
                      itemCount: referralProvider.referralRewardsList.length,
                      itemBuilder: (context, index) {
                        final reward =
                            referralProvider.referralRewardsList[index];
                        return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/svg/whatsapp_background.png'),
                              opacity: 0.3,
                              fit: BoxFit.cover, //
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.h,
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Center(
                                  child: CachedNetworkImage(
                                    imageUrl: reward['icon_url'],
                                    width: 70.w,
                                    height: 70.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${reward['reward_category']}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  height(height: 4.h),
                                  Text(
                                    "${reward['value']}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              //hai
                              TextButton(
                                onPressed: () async {
                                  await referralProvider.postClaimedRewards(reward,"","", false);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.lightBlue.shade500,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Claim",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              height(height: 5.h),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: Text(
                      "Popular Rewards",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllRewards(),
                              ));
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        )),
                  )
                ],
              ),
              height(height: 10.h),
              GridView.builder(
                  itemCount: referralProvider.referralRewardsList.length > 3
                      ? 4
                      : referralProvider.referralRewardsList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6.w,
                    mainAxisSpacing: 6.h,
                    childAspectRatio: 1.0,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final reward = referralProvider.referralRewardsList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: reward['icon_url'] ?? '',
                                  fit: BoxFit.cover,
                                  width: 70.w,
                                  height: 70.h,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(strokeWidth: 2),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  reward['name'] ?? "Reward Title",
                                  style: fontStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  reward['value'] ??
                                      "Reward description goes here.",
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "${reward['required_referrals'].toString()} referral" ??
                                      '',
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          )),
                    );
                  }),
              height(height: 15.h),
              // SizedBox(
              //   height: 60.h,
              //   width: 327.w,
              //   child: Card(
              //     elevation: 7,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     color: Colors.white,
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceAround,
              //         children: [
              //           Container(
              //             width: 32.w,
              //             height: 32.h,
              //             decoration: BoxDecoration(
              //               color: Colors.lightBlue,
              //               borderRadius: BorderRadius.circular(8),
              //             ),
              //             child: Center(
              //               child: SvgPicture.asset(
              //                 'assets/images/users.svg',
              //                 color: Colors.white,
              //                 fit: BoxFit.contain,
              //                 width: 24,
              //                 height: 24,
              //               ),
              //             ),
              //           ),
              //           height(height: 2.h),
              //           Text(
              //             "Referral History",
              //             style: TextStyle(
              //               color: Colors.black,
              //               fontSize: 16.sp,
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //           height(height: 2.h),
              //           IconButton(
              //             onPressed: () {},
              //             icon: Icon(
              //               Icons.arrow_forward_ios_outlined,
              //               color: Colors.grey.shade600,
              //               size: 25,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        height(height: 2.h),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClaimedRewards(),
                              ),
                            );
                          },
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
          ));
        }),
      ),
    );
  }
}


 

class InvitedCardScreen extends StatelessWidget {
  final String image;

  final String count;

  final String name;

  const InvitedCardScreen({
    super.key,
    required this.image,
    required this.count,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
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
                  image ?? "",
                  fit: BoxFit.contain,
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              height(height: 8.h),
              Text(
                count ?? "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              height(height: 4.h),
              Text(
                name ?? "",
                style: TextStyle(
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
    );
  }
}
