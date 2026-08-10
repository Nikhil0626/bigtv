
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
                                childAspectRatio: 1.8,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
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
                                      color: Theme.of(context).cardColor,
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
                                                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (categories[index].imageUrl != null && categories[index].imageUrl!.isNotEmpty)
                                          Positioned(
                                            right: -10.w,
                                            bottom: -10.h,
                                            child: CachedNetworkImage(
                                              imageUrl: categories[index].imageUrl!,
                                              height: 90.sp,
                                              width: 90.sp,
                                              errorWidget: (context, url, error) => const SizedBox(),
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
                  color: authenticationProvider.selectedCategories.isEmpty ? AppColors.bodyTextColor.withAlpha(2) : AppColors.appButtonColor,
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
