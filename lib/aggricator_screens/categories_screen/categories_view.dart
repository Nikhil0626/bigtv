import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/app_spaces.dart';
import '../district_screens/district_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/svg/Chota_news_logo.svg',
              height: 30.h,
              width: 180.w,
              alignment: Alignment.centerLeft,
            ),
            height(height: 40.h),
            Text("Let's personalise", style: newAppFont(fontSize: 32.sp, color: Colors.blue, fontWeight: FontWeight.w400)),
            Text("your experience", style: newAppFont(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
            height(height: 16.h),
            Text("Choose Topics",
                style: newAppFont(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                )),
            height(height: 4.h),
            Text("Choose categories for personalised news \n updates and stories.",
                style: newAppFont(fontSize: 12.sp, color: Colors.black,fontWeight: FontWeight.w400)),
            height(height: 330),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegionSelectionScreen()),
                  );
                },
                child: Text("Skip", style: newAppFont(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
