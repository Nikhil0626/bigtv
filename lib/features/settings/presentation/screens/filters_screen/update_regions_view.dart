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
                              return CheckboxListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(stateName,
                                        style: newAppFont(
                                          fontWeight: FontWeight.w600,
                                        )),

                                  ],
                                ),
                                value: authenticationProvider.selectedLocations.contains(stateName),
                                activeColor: AppColors.appButtonColor,
                                onChanged: (bool? selected) {
                                  authenticationProvider.addToSelectedLocations(stateName);
                                },
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
