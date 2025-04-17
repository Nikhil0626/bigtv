import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';

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
    return Consumer<AuthenticationProvider>(
      builder: (context, authenticationProvider, _) {
        final categories = authenticationProvider.getAllCategoryList;
        final selectedCategories = authenticationProvider.selectedCategories;

        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              child:authenticationProvider.isCatLoading?AppLoadingScreen():authenticationProvider.getAllCategoryList.isEmpty?AppNoData(): Wrap(
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
                        color: isSelected ? AppColors.loginBgColor : Colors.grey.shade200,
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
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(25.w),

            child: InkWell(
              onTap: authenticationProvider.selectedCategories.isNotEmpty
                  ? () {
                authenticationProvider.sendCategoriesToServer(
                  isFilter: true
                ).then((value) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeView(),), (route) => false,);
                },);

              }
                  : null,
              child: Container(
                width: double.infinity,
                height: 35.h,
                decoration: BoxDecoration(
                  color: authenticationProvider.selectedCategories.isEmpty
                      ? AppColors.bodyTextColor.withOpacity(.2)
                      : AppColors.loginBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: authenticationProvider.isCatSaveLoading?AppLoadingScreen():Center(
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
