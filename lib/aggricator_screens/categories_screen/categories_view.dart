// import 'package:chotanews/utils/app_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../utils/app_spaces.dart';
// import '../district_screens/district_view.dart';
//
// class CategoriesView extends StatefulWidget {
//   const CategoriesView({super.key});
//
//   @override
//   State<CategoriesView> createState() => _CategoriesViewState();
// }
//
// class _CategoriesViewState extends State<CategoriesView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
//           onPressed: () {},
//         ),
//       ),
//       body: Padding(
//         padding:  EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SvgPicture.asset(
//               'assets/svg/Chota_news_logo.svg',
//               height: 30.h,
//               width: 180.w,
//               alignment: Alignment.centerLeft,
//             ),
//             height(height: 40.h),
//             Text("Let's personalise", style: newAppFont(fontSize: 32.sp, color: Colors.blue, fontWeight: FontWeight.w400)),
//             Text("your experience", style: newAppFont(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
//             height(height: 16.h),
//             Text("Choose Topics",
//                 style: newAppFont(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w600,
//                 )),
//             height(height: 4.h),
//             Text("Choose categories for personalised news \n updates and stories.",
//                 style: newAppFont(fontSize: 12.sp, color: Colors.black,fontWeight: FontWeight.w400)),
//             height(height: 330),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RegionSelectionScreen()),
//                   );
//                 },
//                 child: Text("Skip", style: newAppFont(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
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
                flex: 13, // 65% blue section
                child: Container(
                  color: Colors.blue,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      height(height: 120), // Moves content slightly upward
                      SvgPicture.asset(
                        'assets/svg/logo_ChotaNews_black.svg',
                        height: 26,
                        width: 181,
                      ),
                      height(height: 20),
                      Text(
                        "Select Topics",
                        style: newAppFont(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      height(height: 20),
                      Text(
                        "Choose categories for personalized news  \n                updates and stories",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7, // 35% white section
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
              height: 484,
              width: 327,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  height(height: 250),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Next",style: newAppFont(color: Colors.white),),
                  ),
                  height(height: 20), // Space between button and progress bar
                  LinearProgressIndicator(
                    value: 0.5, // Half filled with blue
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  height(height: 20), // Space between progress bar and step text
                  Center(
                    child: Text(
                      "Step 1/2",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
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
