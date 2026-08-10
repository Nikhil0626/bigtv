import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().getAllLanguages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthenticationProvider>(
          builder: (context, provider, child) {
            if (provider.isLanguageLoading) {
              return const Center(child: AppLoadingScreen());
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Language",
                    style: context.typography.headlineMedium?.copyWith(
                      color: context.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  height(height: 8.h),
                  Text(
                    "Select your preferred language for news.",
                    style: context.typography.bodyLarge?.copyWith(
                      color: context.subtitleColor,
                    ),
                  ),
                  height(height: 24.h),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: provider.getAllLanguageList.length,
                      itemBuilder: (context, index) {
                        final language = provider.getAllLanguageList[index];
                        final isSelected = provider.selectedLanguageId == language.id;
                        
                        return GestureDetector(
                          onTap: () {
                            provider.setSelectedLanguageId(language.id!);
                          },
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
                                if (language.symbol.isNotEmpty)
                                  Positioned(
                                    right: -10.w,
                                    bottom: -15.h,
                                    child: Text(
                                      language.symbol,
                                      style: context.typography.displayLarge?.copyWith(
                                        fontSize: 60.sp,
                                        color: isSelected 
                                            ? context.primaryColor.withValues(alpha: 0.2) 
                                            : context.textColor.withValues(alpha: 0.05),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Center(
                                  child: Text(
                                    language.getDisplayName(),
                                    style: context.typography.titleMedium?.copyWith(
                                      color: isSelected ? context.primaryColor : context.textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: provider.selectedLanguageId == null
                          ? null
                          : () {
                              provider.saveLanguageAndProceed(provider.selectedLanguageId!);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        disabledBackgroundColor: context.borderColor,
                      ),
                      child: Text(
                        "Continue",
                        style: context.typography.titleMedium?.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  InkWell(
                    onTap: () {
                      // provider.updateLoginStatus(NewAppLoginStatus.phone);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, size: 16.sp, color: context.textColor),
                          SizedBox(width: 8.w),
                          Text(
                            'Back',
                            style: context.typography.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: context.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: context.colors.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: context.colors.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
