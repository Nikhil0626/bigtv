import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_enums.dart';
import '../../../../utils/app_fonts.dart';
import '../../../../utils/app_spaces.dart';
import '../../../../utils/app_toasts.dart';
import '../../../ad_manager_screen/banner_300x50_size.dart';
import '../../../auth_screens/authentication_model/location_model.dart';
import '../../../auth_screens/authentication_provider/authentication_provider.dart';
import '../../../home_screen/home_view.dart';
import '../../settings_provider/settings_provider.dart';

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



  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider,SettingsProvider>(builder: (_, authenticationProvider,settingsProvider, __) {
      return Scaffold(
        backgroundColor: Colors.white,
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
                color: (authenticationProvider.selectedLocations.length > 1 && authenticationProvider.selectedLocations.length <= 5) ?AppColors.appButtonColor : AppColors.bodyTextColor.withOpacity(.2),
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
        body:authenticationProvider.isLocationLoading?Center(child: AppLoadingScreen(),) : Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              height(height: (settingsProvider.bannerAdsLoading == BannerAdsLoading.success||settingsProvider.bannerAdsLoading == BannerAdsLoading.loading) ? 10 : 0),
              Banner300x50Size(),

              height(height: 10),
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
                          style: newAppFont(color: Colors.grey.shade500),
                          children: [
                            TextSpan(
                              text: "0${authenticationProvider.selectedLocations.length}",
                              style: newAppFont(color:AppColors.appButtonColor, fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: "/05\n",            style: newAppFont(color:Colors.grey.shade500, fontWeight: FontWeight.w600,),),
                            if(authenticationProvider.selectedLocations.length>5)
                              TextSpan(text: "You Have Selected Maximum Number of Districts",style: newAppFont(fontSize: 10,color: Colors.red,fontWeight: FontWeight.w400)),

                          ],
                        ),
                      ),
                    ),
                    height(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: authenticationProvider.states!.entries.map((entry) {
                        int stateId = entry.key;
                        String stateName = entry.value;

                        List<LocationModel> districts = authenticationProvider.getAllLocationList.where((loc) => loc.stateId.toString() == stateId.toString()).toList();

                        return ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(horizontal: 16),
                          collapsedBackgroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          childrenPadding: EdgeInsets.zero,
                          initiallyExpanded: false,
                           iconColor: AppColors.iconColors,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(stateName, style: newAppFont(fontWeight: FontWeight.w600,)),
                              width(width: 10),
                              Text("(${districts.length})", style: newAppFont(fontWeight: FontWeight.w300,color: AppColors.iconColors)),
                            ],
                          ),
                          children: districts.map((district) {
                            bool isSelected = authenticationProvider.selectedLocations.contains(district.districtName);
                            return CheckboxListTile(
                              title: Text(district.districtName, style: newAppFont(fontWeight: FontWeight.bold)),
                              value: isSelected,
                              activeColor: AppColors.appButtonColor,
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
