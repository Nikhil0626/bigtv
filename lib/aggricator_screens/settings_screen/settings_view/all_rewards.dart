import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/settings_screen/referral_provider/referral_provider.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_fonts.dart';

class AllRewards extends StatefulWidget {
  const AllRewards({super.key});

  @override
  State<AllRewards> createState() => _AllRewardsState();
}

class _AllRewardsState extends State<AllRewards> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ReferralProvider>().getAvailableRewards();
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
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final referral = referralProvider.referralRewardsList[index];
                      return Card(
                        elevation: 5,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: referral['icon_url'] ?? '',
                                fit: BoxFit.cover,
                                width: 70.w,
                                height: 70.h,
                                placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                referral['name'] ?? "Reward Title",
                                style: fontStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                referral['value'] ?? "Reward description goes here.",
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
                            "${referral['required_referrals'].toString()} referral" ?? '',
                            style: fontStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                            ],
                          ),
                        )
                      );
                    }
                ),
              );
            }
          ),
        );
  }
}





