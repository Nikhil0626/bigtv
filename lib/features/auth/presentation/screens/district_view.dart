
import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:chotanews/utils/app_loading_screen.dart';

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
                                    color: isDark ? AppColorTokens.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isSelected ? colorScheme.primary : (isDark ? AppColorTokens.darkBorder : AppColorTokens.lightBorder),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary.withValues(alpha: 0.1),
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
                                                (isDark ? AppColorTokens.darkSurface : Colors.white).withValues(alpha: 0.0),
                                                isSelected 
                                                    ? colorScheme.primary.withValues(alpha: 0.05) 
                                                    : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02)),
                                              ],
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (context) {
                                              String? imagePath;
                                              if (stateName.toLowerCase().contains('తెలంగాణ')) {
                                                imagePath = 'assets/images/Telangana logo.png';
                                              } else if (stateName.toLowerCase().contains('ఆంధ్రప్రదేశ్') || stateName.toLowerCase().contains('ap')) {
                                                imagePath = 'assets/images/AP logo.png';
                                              }

                                              if (imagePath != null) {
                                                return Padding(
                                                  padding: EdgeInsets.only(right: 2.w),
                                                  child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Image.asset(
                                                      imagePath,
                                                      height: 120.sp,
                                                      width: 120.sp,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const SizedBox();
                                              }
                                            }
                                          ),
                                        ),
                                      ),
                                      
                                      // Content
                                      Padding(
                                        padding: EdgeInsets.only(left: 16.w, right: 90.w),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                              color: isSelected ? colorScheme.primary : (isDark ? AppColorTokens.darkIcon : AppColorTokens.lightIcon),
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
                                                    style: typography.titleSmall?.copyWith(
                                                      fontSize: 16.sp,
                                                      color: isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.lightTextPrimary,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    "Local news, events and updates from $stateName",
                                                    style: typography.bodySmall?.copyWith(
                                                      fontSize: 11.sp,
                                                      color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
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
