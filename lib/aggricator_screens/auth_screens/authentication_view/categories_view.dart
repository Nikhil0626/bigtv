import 'dart:developer';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (_, authenticationProvider, __) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * .46,
          width: 326.w,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(height: 10),
              Expanded(
                child:authenticationProvider.isCatLoading?Center(child: AppLoadingScreen()): SingleChildScrollView(
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: authenticationProvider.getAllCategoryList.map((category) {
                      final isSelected = authenticationProvider.selectedCategories.contains(category.categoryName.toString()) ?? false;

                      return GestureDetector(
                        onTap: () => authenticationProvider.addToSelectedEngagements(category.categoryName.toString()),
                        child: Container(
                          // height: 40,

                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.appButtonColor : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            category.categoryName.toString(),
                            textAlign: TextAlign.center,
                            style: homeScreenFontStyle(
                              color: isSelected ? Colors.white : Colors.black87,
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
              InkWell(
                onTap: authenticationProvider.selectedCategories.isNotEmpty
                    ? () {
                        authenticationProvider.sendCategoriesToServer();
                      }
                    : null,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 36.h,
                    decoration: BoxDecoration(
                        color: authenticationProvider.selectedCategories.isEmpty ? AppColors.bodyTextColor.withOpacity(.2) : AppColors.loginBgColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.r))),
                    child: Center(child: Text('Next', style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500)))),
              ),
              height(height: 16.h),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: AppColors.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.appButtonColor),
              ),
              height(height: 8.h),
              Center(
                child: Text(
                  'Step 1/2',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appButtonColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    );
  }
}
