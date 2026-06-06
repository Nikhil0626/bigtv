
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_fonts.dart';
import '../referral_provider/referral_provider.dart';
import 'all_rewards.dart';
import 'claimed_rewards.dart';

class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  @override
  void initState() {
    super.initState();
    context.read<ReferralProvider>().getReferralStats(context);
    context.read<ReferralProvider>().getAvailableRewards();
  }

  // String? myReferralCode;
  // String? myReferralLink;
  // String? userId;



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
          "రిఫర్ & ఏర్న్",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Consumer<ReferralProvider>(builder: (_, referralProvider, __) {
          return referralProvider.isDataLoading
              ? AppLoadingScreen()
              : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)), // rounded corners
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF00A8FF), // End color
                          Color(0xFF1371A2), // Start color
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "రిఫర్ & ఏర్న్",
                          style: fontStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        height(height: 10),
                        Text(
                          "మీ మిత్రులకు ఆప్ ని షేర్ చెయ్యండి బహుమతులు పొందండి!",
                          style: fontStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        height(height: 15),
                        Text(
                          "మీ రిఫెరల్ కోడ్",
                          style: fontStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        height(height: 10),
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${referralProvider.referralData['referral_code']}",
                            style: fontStyle(
                              color: Colors.lightBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        height(height: 16),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: InkWell(
                            onTap: () {
                              context.read<ReferralProvider>().postProcessReferral(context);
                              // EventRepo().addEvent({
                              //   "shareApp": Platform.isIOS ? "iOS" : "Android",
                              //   "userId": referralProvider.userId ?? "0",
                              //   'referrerUrl': referralProvider.myReferralLink,
                              //   'clickTimestamp': DateTime.now().toString(),
                              //   'installTimestamp': "",
                              //   "createAt": DateTime.now().toString(),
                              //   "error": "",
                              //   "isSharedUser": true
                              // }, "referral");
                              Share.share(
                                "Click link and get bonus: ${referralProvider.referralData['referral_link']}",
                              );
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
                                  Icon(Icons.share_outlined, color: Colors.white, size: 20),
                                  width(width: 12.w),
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
                      ],
                    ),
                  ),
                  height(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InvitedCardScreen(
                            count: referralProvider.referralData['invited']?.toString() ?? "0",
                            image: 'assets/images/users.svg',
                            name: "ఇన్వైటెడ్",
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InvitedCardScreen(
                            count: referralProvider.referralData['downloads']?.toString() ?? "0",
                            image: 'assets/images/download.svg',
                            name: "డౌన్లోడ్స్",
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InvitedCardScreen(
                            count: referralProvider.referralData['pending']?.toString() ?? "0",
                            image: 'assets/images/pending.svg',
                            name: "పెండింగ్",
                          ),
                        ),
                      ],
                    ),
                  ),
                  height(height: 10),
                  Container(
                    height: 135,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Card(
                      elevation: 2,
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
                                  "మీ తర్వాతి బహుమతి",
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue,
                                  child: Image.asset(
                                    "assets/svg/gift.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                              ],
                            ),
                            height(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${referralProvider.referralData['balance_points'] == null ? "0" : referralProvider.referralData['balance_points']} మిత్రులని ఆహ్వానించారు",
                                  style: fontStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  " ${referralProvider.totalRewards == null ? "0" : referralProvider.totalRewards} కావలను",
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            height(height: 8),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 7,
                                  width: MediaQuery.of(context).size.width - 60,
                                  color: Colors.grey.shade300,
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: referralProvider.progress ?? 0.0,
                                    child: Container(
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            height(height: 6),
                            Text(
                              "మీరు తర్వాత బహుమతికీ ${referralProvider.referralData['needed'] ?? 0} మిత్రులకి దూరం గా వున్నారు!",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: fontStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  height(height: 20),
                  referralProvider.referralData['next_reward'] != null && referralProvider.referralData['next_reward'].isNotEmpty
                      ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 120,
                    child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: PageController(viewportFraction: 1.0),
                        itemCount: referralProvider.referralData['next_reward'].length,
                        itemBuilder: (context, index) {
                          final reward = referralProvider.referralData['next_reward'][index];
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/svg/icons_bg1.png'),
                                fit: BoxFit.cover, //
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${reward['reward_type'] == null ? "Test" : reward['reward_type'] ?? ""}",
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    height(height: 6),
                                    Text(
                                      "Coupon Value : ${reward['coupon_value'] == null ? "Test card" : reward['coupon_value'] ?? ""}",
                                      style: fontStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    height(height: 10),
                                    InkWell(
                                      onTap: () async {
                                        context.read<ReferralProvider>().allProvidersRechargeList = [];
                                        context.read<ReferralProvider>().allProvidersOttList = [];
                                        context.read<ReferralProvider>().selectedOperator = "";
                                        context.read<ReferralProvider>().getAllProvidersNames().then(
                                              (value) {
                                            if (reward['reward_type'] == "Mobile Recharge") {
                                              showRechargeOperatorBottomSheet(context, reward, true);
                                            } else if (reward['reward_type'] == "OTT Subscription") {
                                              showRechargeOperatorBottomSheet(context, reward, false);
                                            } else {
                                              context.read<ReferralProvider>().postClaimedRewards(reward, reward['coupon_value'] == "Gift Card" ? "-1" : "-2", isRecharge: true);
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.lightBlue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Claim",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  "assets/svg/gift.png",
                                  height: 80,
                                  width: 80,
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                      : SizedBox.shrink(),
                  if (referralProvider.referralRewardsList.isNotEmpty) height(height: 6),
                  if (referralProvider.referralRewardsList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ప్రముఖ బహుమతులు",
                            style: fontStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          referralProvider.referralRewardsList.length > 4?
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllRewards(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Text(
                                "మరిన్ని",
                                style: fontStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.lightBlue),
                              ),
                            ),
                          )
                          : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  if (referralProvider.referralRewardsList.isNotEmpty) height(height: 20),
                  if (referralProvider.referralRewardsList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: referralProvider.referralRewardsList.length > 2 ? 340 : 170,
                        child: GridView.builder(
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: referralProvider.referralRewardsList.length > 3 ? 4 : referralProvider.referralRewardsList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.1,
                            ),
                            itemBuilder: (context, index) {
                              final reward = referralProvider.referralRewardsList[index];
                              return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
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
                                            fontSize: 12,
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
                            }),
                      ),
                    ),
                  height(height: 16),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClaimedRewards(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/progress_reward.svg',
                                    color: Colors.white,
                                    fit: BoxFit.contain,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              width(width: 10),
                              Expanded(
                                child: Text(
                                  "అందుకోబడిన బహుమతులు",
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ));
        }),
      ),
    );
  }

  void showRechargeOperatorBottomSheet(BuildContext context, dynamic reward, bool isRecharge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final provider = context.watch<ReferralProvider>();
              final optNames = isRecharge
                  ? provider.allProvidersRechargeList
                  : provider.allProvidersOttList;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 100,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const Text(
                          'Select Operator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: provider.selectedOperator.isNotEmpty
                              ? provider.selectedOperator
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Select Operator',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: optNames.map((operator) {
                            return DropdownMenuItem<String>(
                              value: operator.id.toString(),
                              child: Text(operator.name.toString()),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            provider.updateProvider(value ?? '');
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: provider.selectedOperator.isEmpty
                              ? null
                              : () async {
                            await provider.postClaimedRewards(reward, "");

                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 10,
                    child: InkWell(
                      onTap: () => Navigator.of(bottomSheetContext).pop(),
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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
      padding: EdgeInsets.all(4.0),
      child: Card(
        elevation: 2,
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
                radius: 25,
                backgroundColor: name == "Downloads"
                    ? Colors.green.shade100
                    : name == "Pending"
                    ? Colors.orange.shade100
                    : Colors.blue.shade100,
                child: SvgPicture.asset(
                  image ?? "",
                  fit: BoxFit.contain,
                  width: 24,
                  height: 24,
                ),
              ),
              height(height: 8),
              Text(
                count??"0",
                style: fontStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              height(height: 4),
              Text(
                name ?? "",
                style: fontStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
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