import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/theme/spacing.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().getAllCategories();
    super.initState();
  }

  String _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'business':
        return 'assets/images/business_icon.png';
      case 'sports':
        return 'assets/images/sports_icon.png';
      case 'entertainment':
        return 'assets/images/entertainment_icon.png';
      case 'cinema':
        return 'assets/images/cinema_icon.png';
      case 'politics':
        return 'assets/images/politics_icon.png';
      case 'health':
        return 'assets/images/health_icon.png';
      case 'technology':
      case 'tech':
        return 'assets/images/tech_icon.png';
      case 'world':
      case 'international':
        return 'assets/images/world_icon.png';
      case 'auto':
        return 'assets/images/auto_icon.png';
      case 'education':
        return 'assets/images/education_icon.png';
      case 'lifestyle':
        return 'assets/images/lifestyle_icon.png';
      case 'weather':
        return 'assets/images/weather_icon.png';
      default:
        // Fallback or generic placeholder, we will use a generic one if missing
        return 'assets/images/business_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authenticationProvider, __) {
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
                  'CHOOSE YOUR INTERESTS',
                  style: typography.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Select the categories you want to see in your feed',
                  textAlign: TextAlign.center,
                  style: typography.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 24.h),

                // Categories Grid
                Expanded(
                  child: authenticationProvider.isCatLoading
                      ? Center(child: AppLoadingScreen())
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                          ),
                          itemCount: authenticationProvider.getAllCategoryList.length,
                          itemBuilder: (context, index) {
                            final category = authenticationProvider.getAllCategoryList[index];
                            final isSelected = authenticationProvider.selectedCategories.contains(category.categoryName.toString());

                            return GestureDetector(
                              onTap: () => authenticationProvider.addToSelectedEngagements(category.categoryName.toString()),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColorTokens.darkSurface : AppColorTokens.lightSurface,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? colorScheme.primary : colorScheme.outline,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.1),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.w),
                                            decoration: BoxDecoration(
                                              color: isSelected ? colorScheme.primary.withOpacity(0.1) : (isDark ? AppColorTokens.darkCard : AppColorTokens.lightCard),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              _getCategoryIcon(category.categoryName.toString()),
                                              color: isSelected ? colorScheme.primary : (isDark ? AppColorTokens.darkIcon : AppColorTokens.lightIcon),
                                              height: 20.sp,
                                              width: 20.sp,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            category.categoryName.toString(),
                                            textAlign: TextAlign.center,
                                            style: typography.bodySmall?.copyWith(
                                              color: isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.lightTextPrimary,
                                              fontSize: 12.sp,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: isSelected
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: colorScheme.onPrimary,
                                                size: 14.sp,
                                              ),
                                            )
                                          : Container(
                                              width: 14.sp,
                                              height: 14.sp,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: colorScheme.outline,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
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
                      // Info Text
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColorTokens.darkSurface : AppColorTokens.lightCard,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: colorScheme.onPrimary,
                                size: 12.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                "You can change these preferences later in settings",
                                style: typography.bodySmall?.copyWith(
                                  fontSize: 12.sp,
                                  color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // Continue Button
                      InkWell(
                        onTap: authenticationProvider.selectedCategories.isNotEmpty
                            ? () {
                                authenticationProvider.sendCategoriesToServer();
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: authenticationProvider.selectedCategories.isEmpty 
                                ? colorScheme.primary.withOpacity(0.3) 
                                : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: authenticationProvider.selectedCategories.isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: authenticationProvider.isCatSaveLoading
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
                      
                      SizedBox(height: 24.h),
                      
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
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
                              color: colorScheme.outline,
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

