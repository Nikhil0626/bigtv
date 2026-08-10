
import 'package:chotanews/core/theme/theme_extensions.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

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
      bool isDark = context.theme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(25.w),
          child: InkWell(
            onTap: authenticationProvider.selectedLocations.isNotEmpty && authenticationProvider.selectedLocations.length <= 5
                ? () {
                    authenticationProvider.sendLocationsToServer(context).then(
                      (value) {
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeView()), (route) => false);
                        }
                      },
                    );
                  }
                : () {
                    CustomToast.showErrorToast(msg: "Please Select only 5 District ");
                  },
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: (authenticationProvider.selectedLocations.isNotEmpty && authenticationProvider.selectedLocations.length <= 5) ? context.primaryColor : context.colors.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              child: Center(
                child: Text(
                  'Update',
                  style: context.typography.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.sp),
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
                                style: context.typography.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                                children: [
                                  if (authenticationProvider.selectedLocations.length > 5)
                                    TextSpan(text: "\nYou Have Selected Maximum Number of Districts", style: context.typography.bodySmall?.copyWith(color: Colors.red, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                          ),
                          height(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: authenticationProvider.getAllLocationList.map((location) {
                              String stateName = location.stateName;
                              final isSelected = authenticationProvider.selectedLocations.contains(stateName);
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: GestureDetector(
                                  onTap: () {
                                    authenticationProvider.addToSelectedLocations(stateName);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.cardColor,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: isSelected ? context.primaryColor : context.borderColor,
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        if (location.imageUrl != null && location.imageUrl!.isNotEmpty)
                                          Positioned(
                                            right: 16.w,
                                            bottom: 0,
                                            top: 0,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: CachedNetworkImage(
                                                imageUrl: location.imageUrl!,
                                                height: 60.sp,
                                                width: 60.sp,
                                                fit: BoxFit.contain,
                                                errorWidget: (context, url, error) => const SizedBox(),
                                              ),
                                            ),
                                          ),
                                        
                                        Padding(
                                          padding: EdgeInsets.only(left: 16.w, right: 90.w, top: 20.h, bottom: 20.h),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                                color: isSelected ? context.primaryColor : context.colors.outline,
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
                                                      style: context.typography.titleMedium?.copyWith(
                                                        color: context.textColor,
                                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      "Local news, events and updates from $stateName",
                                                      style: context.typography.bodySmall?.copyWith(
                                                        color: context.colors.onSurfaceVariant,
                                                        fontSize: 11.sp,
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
