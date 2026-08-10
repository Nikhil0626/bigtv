import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                SizedBox(height: 10.h),
                Text(
                  'మీ ఆసక్తులని ఎంచుకోండి',
                  style: typography.titleMedium?.copyWith(
                    fontSize: 24.sp,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                // Text(
                //   'Select the categories you want to see in your feed',
                //   textAlign: TextAlign.center,
                //   style: typography.bodySmall?.copyWith(
                //     fontSize: 13.sp,
                //     color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
                SizedBox(height: 10.h),

                // Categories Grid
                Expanded(
                  child: authenticationProvider.isCatLoading
                      ? Center(child: AppLoadingScreen())
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: authenticationProvider.getAllCategoryList.length,
                          itemBuilder: (context, index) {
                            final category = authenticationProvider.getAllCategoryList[index];
                            final isSelected = authenticationProvider.selectedCategories.contains(category.categoryName.toString());

                            return GestureDetector(
                              onTap: () => authenticationProvider.addToSelectedEngagements(category.categoryName.toString()),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  border: Border.all(
                                    color: isSelected ? context.primaryColor : context.borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: context.primaryColor.withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          category.categoryName.toString(),
                                          style: context.typography.titleMedium?.copyWith(
                                            color: isSelected ? context.primaryColor : context.textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                      if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                                        Positioned(
                                          right: -10.w,
                                          bottom: -20.h,
                                          child: CachedNetworkImage(
                                            imageUrl: category.imageUrl!,
                                            height: 100.sp,
                                            width: 100.sp,
                                            errorWidget: (context, url, error) => const SizedBox(),
                                          ),
                                        ),
                                    if (isSelected)
                                      Positioned(
                                        top: 8.h,
                                        right: 8.w,
                                        child: Container(
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            color: context.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: context.colors.onPrimary,
                                            size: 14.sp,
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
                                ? colorScheme.primary.withValues(alpha: 0.3) 
                                : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: authenticationProvider.selectedCategories.isNotEmpty
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
                      
                      SizedBox(height: 4.h),
                      
                      InkWell(
                        onTap: () {
                          // authenticationProvider.updateLoginStatus(NewAppLoginStatus.language);
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
                      
                      SizedBox(height: 24.h),
                      
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

