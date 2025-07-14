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
    return Center(
      child: SvgPicture.asset(
        'assets/images/no_claimed_reward.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}
