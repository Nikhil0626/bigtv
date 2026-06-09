import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_screen/banner_300x50_size.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';


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
    return Consumer2<AuthenticationProvider, SettingsProvider>(builder: (_, authenticationProvider, settingsProvider, __) {
      return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(25.w),
          child: InkWell(
            onTap: authenticationProvider.selectedLocations.isNotEmpty && authenticationProvider.selectedLocations.length <= 5
                ? () {
                    authenticationProvider
                        .sendLocationsToServer(
                      context,
                    )
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
                    CustomToast.showErrorToast(msg: "Please Select only 5 District ");
                  },
            child: Container(
              width: double.infinity,
              height: 35.h,
              decoration: BoxDecoration(
                color:
                    (authenticationProvider.selectedLocations.isNotEmpty && authenticationProvider.selectedLocations.length <= 5) ? AppColors.appButtonColor : AppColors.bodyTextColor.withValues(alpha: .2),
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
        body: authenticationProvider.isLocationLoading
            ? Center(
                child: AppLoadingScreen(),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    height(height: (settingsProvider.bannerAdsLoading == BannerAdsLoading.success || settingsProvider.bannerAdsLoading == BannerAdsLoading.loading) ? 10 : 0),
                    Banner300x50Size(),
                    height(height: 10),
                    Expanded(
                      child: ListView(
                        children: [
                          height(height: 12.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                text: "Districts to be selected ",
                                style: newAppFont(color: Colors.grey.shade500),
                                children: [
                                  if (authenticationProvider.selectedLocations.length > 5)
                                    TextSpan(text: "You Have Selected Maximum Number of Districts", style: newAppFont(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                          ),
                          height(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: authenticationProvider.states!.entries.map((entry) {
                              String stateName = entry.value;
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: isSelected ? AppColors.appButtonColor : Colors.grey.shade300,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.appButtonColor.withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Stack(
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            String? imagePath;
                                            if (stateName.toLowerCase().contains('telangana') || stateName.toLowerCase().contains('తెలంగాణ')) {
                                              imagePath = 'assets/images/Telangana logo.png';
                                            } else if (stateName.toLowerCase().contains('andhra') || stateName.toLowerCase().contains('ap') || stateName.toLowerCase().contains('ఆంధ్రప్రదేశ్')) {
                                              imagePath = 'assets/images/AP logo.png';
                                            }

                                            if (imagePath != null) {
                                              return Padding(
                                                padding: EdgeInsets.only(right: 16.w),
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Image.asset(
                                                    imagePath,
                                                    height: 60.sp,
                                                    width: 60.sp,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return const SizedBox();
                                            }
                                          }
                                        ),
                                        
                                        Padding(
                                          padding: EdgeInsets.only(left: 16.w, right: 90.w),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                                color: isSelected ? AppColors.appButtonColor : Colors.grey.shade400,
                                                size: 24.sp,
                                              ),
                                              SizedBox(width: 16.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      stateName,
                                                      style: newAppFont(
                                                        fontSize: 16.sp,
                                                        color: Colors.black87,
                                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      "Local news, events and updates from $stateName",
                                                      style: newAppFont(
                                                        fontSize: 11.sp,
                                                        color: Colors.black54,
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
