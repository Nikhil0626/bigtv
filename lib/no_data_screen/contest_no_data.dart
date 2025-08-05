import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ContestNoData extends StatelessWidget {
  const ContestNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: SvgPicture.asset("assets/svg/no_data/no_data_contest.svg"));
  }
}
