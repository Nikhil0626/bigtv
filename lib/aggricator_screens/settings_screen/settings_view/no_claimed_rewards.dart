import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utils/app_fonts.dart';
class NoClaimedRewards extends StatefulWidget {
  const NoClaimedRewards({super.key});

  @override
  State<NoClaimedRewards> createState() => _NoClaimedRewardsState();
}

class _NoClaimedRewardsState extends State<NoClaimedRewards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.black, size: 25),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Claimed Rewards",
          style: fontStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Center(
             child: SvgPicture.asset(
              'assets/images/no_claimed_reward.svg',
              fit: BoxFit.contain,
             ),
           ),
        ],
      ),
    );
  }
}
