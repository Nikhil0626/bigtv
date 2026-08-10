
import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_loading_screen.dart';

class DistrictView extends StatefulWidget {
  const DistrictView({super.key});
  //Siva

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
        bool isDark = context.theme.brightness == Brightness.dark;
        final colorScheme = context.colors;
        final typography = context.typography;
        
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                // Header Section
                Image.asset(
                  "assets/images/BigTvPostLogo.png",
                  height: 48.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 24.h),
                Text(
                  'CHOOSE YOUR LOCATION',
                  style: typography.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Get news and updates from your preferred location',
                  textAlign: TextAlign.center,
                  style: typography.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                height(height: 24.h),
                
                Expanded(
                  child: authenticationProvider.isLocationLoading || authenticationProvider.getAllLocationList.isEmpty
                      ? Center(child: AppLoadingScreen())
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: authenticationProvider.getAllLocationList.length,
                          itemBuilder: (context, index) {
                            final location = authenticationProvider.getAllLocationList[index];
                            final stateName = location.stateName;
                            final isSelected = authenticationProvider.selectedLocations.contains(stateName);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: GestureDetector(
                                onTap: () {
                                  authenticationProvider.addToSelectedLocations(stateName);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: context.cardColor,
                                    border: Border.all(
                                      color: isSelected ? context.primaryColor : context.borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
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
                                              height: 100.sp,
                                              width: 100.sp,
                                              // fit: BoxFit.contain,
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
                          },
                        ),
                ),


                Container(
                  padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                  child: Column(
                    children: [
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
                                ? colorScheme.primary.withValues(alpha: 0.3) 
                                : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: authenticationProvider.selectedLocations.isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: authenticationProvider.isLocationSendingLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: typography.labelLarge?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Icon(Icons.arrow_forward, color: colorScheme.onPrimary, size: 20.sp),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                    
                      InkWell(
                        onTap: () {
                          authenticationProvider.updateLoginStatus(NewAppLoginStatus.category);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 16.sp, color: isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.lightTextPrimary),
                              SizedBox(width: 8.w),
                              Text(
                                'Back',
                                style: typography.bodyMedium?.copyWith(
                                  fontSize: 14.sp,
                                  color: isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.lightTextPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
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
