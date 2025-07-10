import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
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
                      final referral = referralProvider.referralRewardsList[index];
                      return Card(
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: referral['icon_url'] ?? '',
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  placeholder: (context, url) => SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: AppLoadingScreen(),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  referral['name'] ?? "Reward Title",
                                  textAlign: TextAlign.center,
                                  style: fontStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  referral['value'] ?? "Reward description goes here.",
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "${referral['required_referrals'].toString()} referral" ?? '',
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ));
                    }
                ),
              );
            }
          ),
        );
  }
}





