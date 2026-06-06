import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../authentication_provider/authentication_provider.dart';

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
      builder: (_, authenticationProvider, __) {
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                height(height: 20.h),
                // Header Section
                Image.asset(
                  "assets/images/BigTvPostLogo.png",
                  height: 48.h,
                  fit: BoxFit.contain,
                ),
                height(height: 24.h),
                Text(
                  'CHOOSE YOUR INTERESTS',
                  style: newAppFont(
                    fontSize: 18.sp,
                    color: const Color(0xFFE50914),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                height(height: 4.h),
                Text(
                  'Select the categories you want to see in your feed',
                  textAlign: TextAlign.center,
                  style: newAppFont(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                height(height: 24.h),

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
                                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFE50914) : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFE50914).withOpacity(0.1),
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
                                              color: isSelected ? const Color(0xFFE50914).withOpacity(0.1) : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              _getCategoryIcon(category.categoryName.toString()),
                                              color: isSelected ? const Color(0xFFE50914) : (isDark ? Colors.white70 : Colors.black87),
                                              height: 20.sp,
                                              width: 20.sp,
                                            ),
                                          ),
                                          height(height: 6.h),
                                          Text(
                                            category.categoryName.toString(),
                                            textAlign: TextAlign.center,
                                            style: newAppFont(
                                              color: isDark ? Colors.white : Colors.black87,
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
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFE50914),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 14.sp,
                                              ),
                                            )
                                          : Container(
                                              width: 14.sp,
                                              height: 14.sp,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE50914),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                            width(width: 12.w),
                            Expanded(
                              child: Text(
                                "You can change these preferences later in settings",
                                style: newAppFont(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      height(height: 16.h),
                      
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
                                ? (isDark ? Colors.grey.shade800 : Colors.red.shade200) 
                                : const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: authenticationProvider.selectedCategories.isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFE50914).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: authenticationProvider.isCatSaveLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: newAppFont(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      width(width: 8.w),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      
                      height(height: 24.h),
                      
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE50914),
                              shape: BoxShape.circle,
                            ),
                          ),
                          width(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          width(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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

