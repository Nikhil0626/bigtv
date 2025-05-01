import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_fonts.dart';
import '../../../../utils/app_spaces.dart';
import '../../../../utils/app_toasts.dart';
import '../../../auth_screens/authentication_model/location_model.dart';
import '../../../auth_screens/authentication_provider/authentication_provider.dart';
import '../../../home_screen/home_view.dart';

class UpdateRegionsView extends StatefulWidget {
  const UpdateRegionsView({super.key});

  @override
  State<UpdateRegionsView> createState() => _UpdateRegionsViewState();
}

class _UpdateRegionsViewState extends State<UpdateRegionsView> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().getAllLocations();
    super.initState();
  }

  final Map<int, String> states = {
    21: 'Andhra Pradesh',
    19: 'Telangana',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (_, authenticationProvider, __) {
      return Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(25.w),
          child: InkWell(
            onTap: authenticationProvider.selectedLocations.length > 1 && authenticationProvider.selectedLocations.length <= 5
                ? () {
                    authenticationProvider.sendLocationsToServer(context,).then((value) {
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeView(),
                          ),
                              (route) => false,
                        );
                      }
                    },);
                  }
                : () {
                    CustomToast.showErrorToast(msg: "Please Select only 5 District ");
                  },
            child: Container(
              width: double.infinity,
              height: 35.h,
              decoration: BoxDecoration(
                color: (authenticationProvider.selectedLocations.length > 1 && authenticationProvider.selectedLocations.length <= 5) ? AppColors.loginBgColor : AppColors.bodyTextColor.withOpacity(.2),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              child: Center(
                child: Text(
                  'Update',
                  style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 20),
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 10),
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey[200],
                    //       borderRadius: BorderRadius.circular(6),
                    //     ),
                    //     child: TextField(
                    //       decoration: InputDecoration(
                    //         icon: Icon(Icons.search, color: Colors.grey),
                    //         hintText: 'Search',
                    //         border: InputBorder.none,
                    //       ),
                    //       onChanged: (value) {
                    //         // Implement search functionality if needed
                    //       },
                    //     ),
                    //   ),
                    // ),
                    height(height: 12.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text: "You have selected ",
                          style: TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(
                              text: "0${authenticationProvider.selectedLocations.length}",
                              style: homeScreenFontStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "/05\n"),
                            if(authenticationProvider.selectedLocations.length>5)
                              TextSpan(text: "You Have Selected Maximum Number of Districts",style: newAppFont(fontSize: 10,color: Colors.red,fontWeight: FontWeight.w400)),

                          ],
                        ),
                      ),
                    ),
                    height(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: states.entries.map((entry) {
                        int stateId = entry.key;
                        String stateName = entry.value;

                        List<LocationModel> districts = authenticationProvider.getAllLocationList.where((loc) => loc.stateId.toString() == stateId.toString()).toList();

                        return ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(horizontal: 16),
                          collapsedBackgroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          childrenPadding: EdgeInsets.zero,
                          initiallyExpanded: false,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(stateName, style: homeScreenFontStyle(fontWeight: FontWeight.bold)),
                              Text("(${districts.length})", style: homeScreenFontStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          children: districts.map((district) {
                            bool isSelected = authenticationProvider.selectedLocations.contains(district.districtName);
                            return CheckboxListTile(
                              title: Text(district.districtName, style: homeScreenFontStyle(fontWeight: FontWeight.bold)),
                              value: isSelected,
                              onChanged: (bool? selected) {
                                authenticationProvider.addToSelectedLocations(district.districtName);
                              },
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                    height(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
