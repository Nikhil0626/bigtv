// import 'package:chotanews/utils/app_spaces.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
//
// class RegionSelectionScreen extends StatefulWidget {
//   @override
//   _RegionSelectionScreenState createState() => _RegionSelectionScreenState();
// }
//
// class _RegionSelectionScreenState extends State<RegionSelectionScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
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
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SvgPicture.asset(
//               'assets/svg/Chota_news_logo.svg',
//               height: 30,
//               width: 180,
//               alignment: Alignment.centerLeft,
//             ),
//             height(height: 40.h),
//             Text("Let's personalise", style: TextStyle(fontSize: 32, color: Colors.blue, fontWeight: FontWeight.w400)),
//             Text("your experience", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
//             SizedBox(height: 16),
//             Text("Choose Regions",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 )),
//             SizedBox(height: 4),
//             Text("Select your districts to receive hyperlocal news and relevant local information tailored to your area.",
//                 style: TextStyle(fontSize: 12, color: Colors.black)),
//             SizedBox(height: 16),
//             TabBar(
//               controller: _tabController,
//               labelColor: Colors.blue,
//               unselectedLabelColor: Colors.black,
//               indicator: UnderlineTabIndicator(
//                 borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
//               ),
//               labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               tabs: [
//                 Tab(text: "Andhra Pradesh"),
//                 Tab(text: "Telangana"),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [],
//               ),
//             ),
//             height(height: 16),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () {},
//                 child: Text("Skip", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
import '../settings_screen/settings_view.dart';

class DistrictView extends StatefulWidget {
  const DistrictView({super.key});

  @override
  State<DistrictView> createState() => _DistrictViewState();
}

class _DistrictViewState extends State<DistrictView> {
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
                  Column(
                    children: [
                      Container(
                        height: 40,  // Height remains the same
                        width: double.infinity,  // Adjust width to take up the available space
                        padding: EdgeInsets.symmetric(horizontal: 5),  // Add some padding inside the container
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade300,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.blue),
                            SizedBox(width: 8),  // Space between icon and text
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  border: InputBorder.none,  // Remove the default underline
                                ),
                              ),
                            ),
                            // New blue container with white icon inside the search bar
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      height(height: 16),  // Space between the two containers

                    ],
                  ),
                  height(height: 200), // Space between search bar and next button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsView()),
                      );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(279, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Next", style: newAppFont(color: Colors.white)),
                  ),
                  height(height: 50), // Space between button and progress bar
                  LinearProgressIndicator(
                    value: 0.5, // Half filled with blue
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  height(height: 20), // Space between progress bar and step text
                  Center(
                    child: Text(
                      "Step 2/2",
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
