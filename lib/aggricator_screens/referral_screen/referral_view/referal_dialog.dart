import 'dart:developer';

import 'package:chotanews/aggricator_screens/referral_screen/referral_provider/referral_provider.dart';
import 'package:chotanews/aggricator_screens/referral_screen/referral_view/refer_earn.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralDialog extends StatefulWidget {
  const ReferralDialog({super.key});

  @override
  State<ReferralDialog> createState() => _ReferralDialogState();
}

class _ReferralDialogState extends State<ReferralDialog> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (_, referralProvider, __) {
        return Center(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(12),
                constraints: BoxConstraints(minWidth: 330),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.referEarnColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text('Refer and Earn',
                        style: fontStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 12,
                    ),
                    Center(
                      child: Image.asset(
                        "assets/svg/gift.png",
                        height: 65,
                        width: 65,
                        color: Colors.yellow,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'రివార్డ్‌లను సంపాదించడానికి చోటాన్యూస్ యాప్‌ను మీ స్నేహితులు మరియు కుటుంబ సభ్యులతో షేర్ చేయండి!',
                      style: fontStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_1,
                          size: 8,
                          color: AppColors.wColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text: '10 ',
                                style: fontStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(
                                      text: 'Referrals',
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      )),
                                  TextSpan(
                                      text: ' 150 ',
                                      style: fontStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500)),
                                  TextSpan(
                                      text: 'Cash Voucher',
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      )),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    height(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_1,
                          size: 8,
                          color: AppColors.wColor,
                        ),
                        width(width: 4),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text: '30 ',
                                style: fontStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(
                                      text: 'Referrals',
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      )),
                                  TextSpan(
                                      text: ' 500 ',
                                      style: fontStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500)),
                                  TextSpan(
                                      text: 'Cash Voucher',
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      )),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    height(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_1,
                          size: 8,
                          color: AppColors.wColor,
                        ),
                        width(
                          width: 8,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text: '50 ',
                                style: fontStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(
                                      text: 'Referrals',
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      )),
                                  TextSpan(
                                      text: ' 1000 ',
                                      style: fontStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500)),
                                  TextSpan(
                                      text: 'Cash Voucher',
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      )),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    height(
                      height: 16,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () async {


                          SharedPreferences sp = await SharedPreferences.getInstance();
                          bool isNotificationsEnabled =
                          sp.getString("loginType") == "login" ? true : false;
                          if (!isNotificationsEnabled) {
                            CustomToast.showErrorToast(
                                msg:
                                "Your currently using your application in guest mode please login and join your Refer & Earn contest",
                                timeDuration: 3);
                          } else {
                            Navigator.pop(mainNavigatorKey.currentContext!);

                            String myReferralLink = referralProvider.referralData['referral_link'] ?? "N/A";
                            String myReferralCode = referralProvider.referralData['referral_code'] ?? "N/A";
                            log("hai1");
                            // if(myReferralLink == "N/A"){
                            //   referralProvider.getReferralStats(mainNavigatorKey.currentContext);
                            // }
                            // else if(myReferralLink == null) {
                            //   log("hai2");
                            //   referralProvider.getReferralStats(mainNavigatorKey.currentContext!).then((val)async{
                            //     ShareResult result = await Share.share(myReferralLink);
                            //     if (result.status == ShareResultStatus.success) {
                            //
                            //       context.read<ReferralProvider>().postProcessReferral(context);
                            //       Navigator.push(
                            //         mainNavigatorKey.currentContext!,
                            //         MaterialPageRoute(builder: (context) => ReferEarn()),
                            //       );
                            //     }
                            //   });
                            // }
                            if (myReferralLink == "N/A" || myReferralLink == "Null" || myReferralLink == null || myReferralLink.isEmpty) {
                              log("hai2");
                              referralProvider.getReferralStats(mainNavigatorKey.currentContext!,isHome:true);
                            } else {
                              log("hai3");
                              ShareResult result = await Share.share(myReferralLink);
                              if (result.status == ShareResultStatus.success) {

                                  context.read<ReferralProvider>().postProcessReferral(context);
                                  Navigator.push(
                                    mainNavigatorKey.currentContext!,
                                    MaterialPageRoute(builder: (context) => ReferEarn()),
                                  );
                              }
                            }
                          }

                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Color(0xff00A8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/wa-icon.png',width: 24,height: 24,),
                              SizedBox(width: 12.w),
                              Text(
                                "మిత్రులని ఆహ్వానించండి",
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
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 1,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
