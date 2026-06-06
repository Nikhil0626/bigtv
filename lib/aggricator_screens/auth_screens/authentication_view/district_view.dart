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

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view/home_view.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../authentication_model/location_model.dart';

class DistrictView extends StatefulWidget {
  const DistrictView({super.key});

  @override
  State<DistrictView> createState() => _DistrictViewState();
}

class _DistrictViewState extends State<DistrictView> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().getAllLocations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (_, authenticationProvider, __) {
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                height(height: 20.h),
                // Header Section
                Image.asset(
                  "assets/images/BigTvPostLogo.png",
                  height: 48.h,
                  fit: BoxFit.contain,
                ),
                height(height: 24.h),
                Text(
                  'CHOOSE YOUR LOCATION',
                  style: newAppFont(
                    fontSize: 22.sp,
                    color: const Color(0xFFE50914),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                height(height: 8.h),
                Text(
                  'Get news and updates from\nyour preferred location',
                  textAlign: TextAlign.center,
                  style: newAppFont(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                height(height: 24.h),

                // Location List
                Expanded(
                  child: authenticationProvider.isLocationLoading || authenticationProvider.states == null
                      ? Center(child: AppLoadingScreen())
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: authenticationProvider.states!.entries.length,
                          itemBuilder: (context, index) {
                            final entry = authenticationProvider.states!.entries.elementAt(index);
                            final stateName = entry.value;
                            final isSelected = authenticationProvider.selectedLocations.contains(stateName);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: GestureDetector(
                                onTap: () {
                                  authenticationProvider.addToSelectedLocations(stateName);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFE50914) : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFE50914).withOpacity(0.1),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Faded right side indicator/gradient
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        width: 120.w,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8.r),
                                              bottomRight: Radius.circular(8.r),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                (isDark ? const Color(0xFF2C2C2C) : Colors.white).withOpacity(0.0),
                                                isSelected 
                                                    ? const Color(0xFFE50914).withOpacity(0.05) 
                                                    : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02)),
                                              ],
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (context) {
                                              String? imagePath;
                                              if (stateName.toLowerCase().contains('telangana')) {
                                                imagePath = 'assets/images/telangana.png';
                                              } else if (stateName.toLowerCase().contains('andhra') || stateName.toLowerCase().contains('ap')) {
                                                imagePath = 'assets/images/ap.png';
                                              }

                                              if (imagePath != null) {
                                                return ShaderMask(
                                                  shaderCallback: (rect) {
                                                    return LinearGradient(
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.white.withOpacity(isDark ? 0.4 : 0.8),
                                                      ],
                                                    ).createShader(rect);
                                                  },
                                                  blendMode: BlendMode.dstIn,
                                                  child: Image.asset(
                                                    imagePath,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.centerRight,
                                                    color: isDark ? Colors.white : null,
                                                    colorBlendMode: isDark ? BlendMode.difference : null,
                                                  ),
                                                );
                                              } else {
                                                return Icon(
                                                  Icons.location_city,
                                                  size: 80.sp,
                                                  color: isSelected 
                                                      ? const Color(0xFFE50914).withOpacity(0.1) 
                                                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                                                );
                                              }
                                            }
                                          ),
                                        ),
                                      ),
                                      
                                      // Content
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                              color: isSelected ? const Color(0xFFE50914) : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                              size: 24.sp,
                                            ),
                                            width(width: 16.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    stateName,
                                                    style: newAppFont(
                                                      fontSize: 16.sp,
                                                      color: isDark ? Colors.white : Colors.black87,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                    ),
                                                  ),
                                                  height(height: 4.h),
                                                  Text(
                                                    "Local news, events and\nupdates from $stateName",
                                                    style: newAppFont(
                                                      fontSize: 12.sp,
                                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Bottom Section
                Container(
                  padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                  child: Column(
                    children: [
                      // Location Info Text
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFFE50914),
                              size: 20.sp,
                            ),
                            width(width: 12.w),
                            Expanded(
                              child: Text(
                                "We will use your location to show relevant news and updates",
                                style: newAppFont(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      height(height: 16.h),
                      
                      // Continue Button
                      InkWell(
                        onTap: authenticationProvider.selectedLocations.isNotEmpty
                            ? () {
                                authenticationProvider.sendLocationsToServer(context).then(
                                  (value) {
                                    if (context.mounted && authenticationProvider.newAppLoginStatus == NewAppLoginStatus.home) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeView(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
                                );
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: authenticationProvider.selectedLocations.isEmpty 
                                ? (isDark ? Colors.grey.shade800 : Colors.red.shade200) 
                                : const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: authenticationProvider.selectedLocations.isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFE50914).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: authenticationProvider.isLocationSendingLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: newAppFont(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      width(width: 8.w),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      
                      height(height: 16.h),
                      
                      // Back Button
                      InkWell(
                        onTap: () {
                          authenticationProvider.newAppLoginStatus = NewAppLoginStatus.category;
                          authenticationProvider.notifyListeners();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 16.sp, color: isDark ? Colors.white : Colors.black87),
                              width(width: 8.w),
                              Text(
                                'Back',
                                style: newAppFont(
                                  fontSize: 14.sp,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      height(height: 16.h),
                      
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          width(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE50914),
                              shape: BoxShape.circle,
                            ),
                          ),
                          width(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
