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
import 'package:chotanews/aggricator_screens/home_screen/home_view/main_screen_card.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../../home_screen/home_view/home_view.dart';
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
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          // height: MediaQuery.of(context).size.height * .46,
          height:561,
          width: 326.w,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.grey[200],
                //     borderRadius: BorderRadius.circular(6),
                //   ),
                //   child: TextField(
                //     decoration: InputDecoration(
                //       icon: Icon(Icons.search, color: Colors.grey),
                //       hintText: 'Search',
                //       border: InputBorder.none,
                //     ),
                //     onChanged: (value) {
                //       // setState(() => searchQuery = value);
                //     },
                //   ),
                // ),
                // height(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: "You have selected ",
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text:
                              "0${authenticationProvider.selectedLocations.length}",
                          style: homeScreenFontStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "/05\n"),
                        if (authenticationProvider.selectedLocations.length > 5)
                          TextSpan(
                              text:
                                  "You Have Selected Maximum Number of Districts",
                              style: newAppFont(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
                height(height: 8),
                Container(
                  height: 190,
                  // Or remove if you want it to expand naturally
                  alignment: Alignment.topCenter,
                  child: authenticationProvider.isLocationLoading
                      ? Center(child: AppLoadingScreen())
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: authenticationProvider.states!.entries.map((entry) {
                              int stateId = entry.key;
                              String stateName = entry.value;

                              List<LocationModel> districts =
                                  authenticationProvider
                                      .getAllLocationList
                                      .where((loc) =>
                                          loc.stateId.toString() ==
                                          stateId.toString())
                                      .toList();

                              return ExpansionTile(
                                tilePadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                collapsedBackgroundColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                childrenPadding: EdgeInsets.zero,
                                initiallyExpanded: false,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(stateName,
                                        style: homeScreenFontStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("(${districts.length})",
                                        style: homeScreenFontStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                children: districts.map((district) {
                                  bool isSelected = authenticationProvider
                                      .selectedLocations
                                      .contains(district.districtName);
                                  return CheckboxListTile(
                                    title: Text(district.districtName,
                                        style: homeScreenFontStyle(
                                            fontWeight: FontWeight.bold)),
                                    value: isSelected,
                                    onChanged: (bool? selected) {
                                      authenticationProvider
                                          .addToSelectedLocations(
                                              district.districtName);
                                    },
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                ),

                InkWell(
                  onTap: authenticationProvider.selectedLocations.length > 1 &&
                          authenticationProvider.selectedLocations.length <= 5
                      ? () {
                          authenticationProvider
                              .sendLocationsToServer(context)
                              .then(
                            (value) {
                              if (context.mounted) {
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
                      : () {
                          CustomToast.showErrorToast(
                              msg: "Please select at least 2 district ");
                        },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 36.h,
                      decoration: BoxDecoration(
                          color:
                              (authenticationProvider.selectedLocations.length >
                                          1 &&
                                      authenticationProvider
                                              .selectedLocations.length <=
                                          5)
                                  ? AppColors.loginBgColor
                                  : AppColors.bodyTextColor.withOpacity(.2),
                          borderRadius: BorderRadius.all(Radius.circular(8.r))),
                      child: Center(
                          child: authenticationProvider.isLocationSendingLoading
                              ? AppLoadingScreen(
                                  loadingColor: Colors.white,
                                )
                              : Text('Next',
                                  style: newAppFont(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)))),
                ),

                height(height: 6.h),
                LinearProgressIndicator(
                  value: 1,
                  backgroundColor: AppColors.borderColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appButtonColor),
                ),
                height(height: 8.h),
                Center(
                  child: Text(
                    'Step 2/2',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.appButtonColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
