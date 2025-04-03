
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_fonts.dart';
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 13,
                child: Container(
                  color: Colors.blue,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      height(height: 120.h),
                      SvgPicture.asset(
                        'assets/svg/logo_ChotaNews_black.svg',
                        height: 26.h,
                        width: 181.w,
                      ),
                      height(height: 20),
                      Text(
                        "Select Topics",
                        style: newAppFont(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      height(height: 20.h),
                      Text(
                        "Choose categories for personalized news  \n                updates and stories",
                        style: newAppFont(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              height: 484.h,
              width: 327.w,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  height(height: 250.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DistrictView()),
                      );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(279, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text("Next",style: newAppFont(color: Colors.white),),
                  ),
                  height(height: 20.h),
                  LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  height(height: 20.h),
                  Center(
                    child: Text(
                      "Step 1/2",
                      style: newAppFont(
                        color: Colors.blue,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
