import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../referral_provider/referral_provider.dart';

class AllRewards extends StatefulWidget {
  const AllRewards({super.key});

  @override
  State<AllRewards> createState() => _AllRewardsState();
}

class _AllRewardsState extends State<AllRewards> {
  @override
  void initState() {

    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.black, size: 25),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Rewards",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
      ),
      body: Consumer<ReferralProvider>(
          builder: (_,referralProvider,__) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical:12),
              child: GridView.builder(
                  itemCount: referralProvider.referralRewardsList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6.w,
                    mainAxisSpacing: 6.h,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final reward = referralProvider.referralRewardsList[index];
                    return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4), // horizontal, vertical
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: Image.network(
                                  reward['icon_url'] ?? '',
                                  fit: BoxFit.fill,
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image),
                                ),
                              ),
                            ),
                            height(height: 4),
                            Text(
                              reward['name'] ?? "Reward Title",
                              textAlign: TextAlign.center,
                              style: fontStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            height(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Coupon Value : ${reward['coupon_value'] == null ? "Test card" : reward['coupon_value'] ?? ""} RS",
                                style: fontStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            height(height: 2),
                            Text(
                              "${reward['required_referrals'].toString()} referral" ?? '',
                              style: fontStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ));
                  }
              ),
            );
          }
      ),
    );
  }
}





