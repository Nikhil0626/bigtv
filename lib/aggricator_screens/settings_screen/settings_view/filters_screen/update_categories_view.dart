import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_enums.dart';
import '../../../../utils/app_fonts.dart';
import '../../../../utils/app_spaces.dart';


class UpdateCategoriesView extends StatefulWidget {
  const UpdateCategoriesView({super.key});

  @override
  State<UpdateCategoriesView> createState() => _UpdateCategoriesViewState();
}

class _UpdateCategoriesViewState extends State<UpdateCategoriesView> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationProvider>().getAllCategories();
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
    return Consumer2<AuthenticationProvider, SettingsProvider>(
      builder: (context, authenticationProvider, settingsProvider, __) {
        final categories = authenticationProvider.getAllCategoryList;
        final selectedCategories = authenticationProvider.selectedCategories;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text("Select Categories", style: TextStyle(color: Colors.black)),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                height(height: (settingsProvider.bannerAdsLoading == BannerAdsLoading.success || settingsProvider.bannerAdsLoading == BannerAdsLoading.loading) ? 10 : 0),

                height(height: 10),
                Expanded(
                  child: authenticationProvider.isCatLoading
                      ? AppLoadingScreen()
                      : authenticationProvider.getAllCategoryList.isEmpty
                          ? AppNoData()
                          : GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.3,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final categoryName = categories[index].categoryName.toString();
                                final isSelected = selectedCategories.contains(categoryName);
                                return GestureDetector(
                                  onTap: () {
                                    authenticationProvider.addToSelectedEngagements(categoryName);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: isSelected ? AppColors.appButtonColor : Colors.transparent,
                                        width: isSelected ? 2.0 : 0.0,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(_getCategoryImage(categoryName, index)),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.4),
                                          BlendMode.darken,
                                        ),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.appButtonColor.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                                            child: Text(
                                              categoryName,
                                              textAlign: TextAlign.center,
                                              style: homeScreenFontStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                              ).copyWith(
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
                                                color: AppColors.appButtonColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
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
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(25.w),
            child: InkWell(
              onTap: authenticationProvider.selectedCategories.isNotEmpty
                  ? () {
                      authenticationProvider.sendCategoriesToServer(isFilter: true).then(
                        (value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeView(),
                            ),
                            (route) => false,
                          );
                        },
                      );
                    }
                  : null,
              child: Container(
                width: double.infinity,
                height: 35.h,
                decoration: BoxDecoration(
                  color: authenticationProvider.selectedCategories.isEmpty ? AppColors.bodyTextColor.withValues(alpha: .2) : AppColors.appButtonColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: authenticationProvider.isCatSaveLoading
                    ? AppLoadingScreen()
                    : Center(
                        child: Text(
                          'Update',
                          style: newAppFont(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
