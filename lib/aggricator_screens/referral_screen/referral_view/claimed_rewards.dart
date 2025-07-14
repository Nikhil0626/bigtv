import 'package:chotanews/aggricator_screens/settings_screen/settings_view/no_claimed_rewards.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../referral_provider/referral_provider.dart';

class ClaimedRewards extends StatefulWidget {
  const ClaimedRewards({super.key});

  @override
  State<ClaimedRewards> createState() => _ClaimedRewardsState();
}

class _ClaimedRewardsState extends State<ClaimedRewards> {
  @override
  void initState() {
    super.initState();
    context.read<ReferralProvider>().getClaimedRewards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
            size: 25,
          ),
        ),
        title: Text(
          "Claimed Rewards",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ReferralProvider>(builder: (_, referralProvider, __) {
        return referralProvider.isLoading
            ? NoClaimedRewards()
            : referralProvider.referralRewardsClaimed.isEmpty
                ? AppNoData()
                : Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16),
                        height: MediaQuery.of(context).size.height * .2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16)), // rounded corners
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF00A8FF), // End color
                              Color(0xFF1371A2), // Start color
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.green.shade50,
                                      child: SvgPicture.asset(
                                        'assets/images/download.svg',
                                        fit: BoxFit.contain,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    height(height: 8.h),
                                    Text(
                                      "${referralProvider.referralRewardsClaimed['points']['total'] ?? 0}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    height(height: 4.h),
                                    Text(
                                      "Downloads",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue.shade50,
                                      child: SvgPicture.asset(
                                        'assets/images/claimed_reward.svg',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    height(height: 8.h),
                                    Text(
                                      "${referralProvider.referralRewardsClaimed['points']['claimed']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    height(height: 4.h),
                                    Text(
                                      "Claimed",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            // Third Box
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.orange.shade50,
                                      child: SvgPicture.asset(
                                        'assets/images/pending.svg',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    height(height: 8.h),
                                    Text(
                                      "${referralProvider.referralRewardsClaimed['points']['balance']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    height(height: 4.h),
                                    Text(
                                      "Balance",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      height(height: 15),
                      Padding(
                        padding: EdgeInsets.only(left: 22),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Transactions History",
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      height(height: 5),
                      Expanded(
                        child: referralProvider.referralRewardsClaimed['rewards'].isEmpty
                            ? NoClaimedRewards()
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListView.builder(
                                  itemCount: referralProvider.referralRewardsClaimed['rewards'].length,
                                  itemBuilder: (context, index) {
                                    var data = referralProvider.referralRewardsClaimed['rewards'][index];
                                    return SizedBox(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white, // Background color
                                          borderRadius: BorderRadius.circular(10), // Rounded corners
                                          border: Border.all(
                                            color: AppColors.cardBackgroundColor, // Border color
                                            width: 1, // Border width
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3), // Shadow color
                                              spreadRadius: 1, // How much the shadow spreads
                                              blurRadius: 5, // Softness of the shadow
                                              offset: Offset(0, 3), // Position of shadow (horizontal, vertical)
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(data['icon_url']),
                                              ),
                                              width(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${data['name']}",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    height(height: 4),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text: "Coupon Code: ",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text: "${data['coupon_code']}",
                                                                  style: TextStyle(
                                                                    color: Colors.deepPurple, // Highlight color
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        InkWell(
                                                          onTap: () {
                                                            Clipboard.setData(ClipboardData(text: "${data['coupon_code']}"));
                                                            CustomToast.showSuccessToast(msg: "Code Copied Successfully");
                                                          },
                                                          child: Icon(Icons.copy, size: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    height(height: 4),
                                                    Text(
                                                      "${data['created_at']}",
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      )
                    ],
                  );
      }),
    );
  }
}
