import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
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

  String _getCategoryImage(String categoryName, int index) {
    final name = categoryName.trim().toLowerCase();
    if (name.contains('business')) return 'assets/images/business.jpg';
    if (name.contains('sports')) return 'assets/images/sports.jpg';
    if (name.contains('entertainment') || name.contains('cinema')) return 'assets/images/entertainment.jpg';
    if (name.contains('politics')) return 'assets/images/politics.jpg';
    if (name.contains('technology') || name.contains('tech')) return 'assets/images/technology.jpg';
    if (name.contains('lifestyle')) return 'assets/images/lifestyle.jpg';
    if (name.contains('science')) return 'assets/images/science.jpg';
    if (name.contains('startup')) return 'assets/images/startup.jpg';
    if (name.contains('education')) return 'assets/images/education.jpg';
    
    // If the API returns categories in another language or unmapped names, 
    // provide a varied fallback based on the index so they don't all look identical.
    final fallbacks = [
      'assets/images/business.jpg',
      'assets/images/sports.jpg',
      'assets/images/entertainment.jpg',
      'assets/images/politics.jpg',
      'assets/images/technology.jpg',
      'assets/images/lifestyle.jpg',
      'assets/images/science.jpg',
      'assets/images/startup.jpg',
      'assets/images/education.jpg'
    ];
    return fallbacks[index % fallbacks.length];
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
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 8.h,
                          ),
                          itemCount: authenticationProvider.getAllCategoryList.length,
                          itemBuilder: (context, index) {
                            final category = authenticationProvider.getAllCategoryList[index];
                            final isSelected = authenticationProvider.selectedCategories.contains(category.categoryName.toString());

                            return GestureDetector(
                              onTap: () => authenticationProvider.addToSelectedEngagements(category.categoryName.toString()),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: colorScheme.primary.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.asset(
                                        _getCategoryImage(category.categoryName.toString(), index),
                                        fit: BoxFit.cover,
                                        color: Colors.black.withValues(alpha: 0.4),
                                        colorBlendMode: BlendMode.darken,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: colorScheme.primary,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      child: Text(
                                        category.categoryName.toString(),
                                        textAlign: TextAlign.center,
                                        style: typography.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              offset: const Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 6.h,
                                      right: 6.w,
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: colorScheme.onPrimary,
                                          size: 14.sp,
                                        ),
                                      ),
                                    ),
                                ],
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

