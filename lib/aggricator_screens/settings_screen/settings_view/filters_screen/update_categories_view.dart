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
import '../../../ad_manager_screen/ad_screen/banner_300x50_size.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, SettingsProvider>(
      builder: (context, authenticationProvider, settingsProvider, __) {
        final categories = authenticationProvider.getAllCategoryList;
        final selectedCategories = authenticationProvider.selectedCategories;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                height(height: (settingsProvider.bannerAdsLoading == BannerAdsLoading.success || settingsProvider.bannerAdsLoading == BannerAdsLoading.loading) ? 10 : 0),
                Banner300x50Size(),
                height(height: 10),
                SingleChildScrollView(
                  child: authenticationProvider.isCatLoading
                      ? AppLoadingScreen()
                      : authenticationProvider.getAllCategoryList.isEmpty
                          ? AppNoData()
                          : Wrap(
                              spacing: 10.w,
                              runSpacing: 10.h,
                              children: categories.map((category) {
                                final categoryName = category.categoryName.toString();
                                final isSelected = selectedCategories.contains(categoryName);
                                return GestureDetector(
                                  onTap: () {
                                    authenticationProvider.addToSelectedEngagements(categoryName);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.appButtonColor : AppColors.cardBackgroundColor,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      categoryName,
                                      textAlign: TextAlign.center,
                                      style: homeScreenFontStyle(
                                        color: isSelected ? Colors.white : Colors.black54,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
