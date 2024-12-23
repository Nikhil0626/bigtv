
import 'package:flutter/material.dart';

import 'app_fonts.dart';

class AppNoData extends StatelessWidget {
  const AppNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No Data Found...",style: fontStyle(
          fontSize: 14,color: const Color(0xff111928), fontWeight: FontWeight.bold),),
    );
  }
}
