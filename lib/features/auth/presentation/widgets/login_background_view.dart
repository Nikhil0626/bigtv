import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../screens/district_view.dart';
import '../screens/categories_view.dart';
import '../screens/unified_auth_view.dart';

class LoginBackgroundView extends StatelessWidget {
  const LoginBackgroundView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Consumer<AuthenticationProvider>(
      builder: (_, authenticationProvider, __) {
        bool isAuthScreen = authenticationProvider.newAppLoginStatus == NewAppLoginStatus.login ||
            authenticationProvider.newAppLoginStatus == NewAppLoginStatus.none ||
            authenticationProvider.newAppLoginStatus == NewAppLoginStatus.otp;
        bool isDark = context.theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColorTokens.darkBackground : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom,
                child: isAuthScreen ? _buildAuthLayout(context, authenticationProvider) : _buildOtherLayout(context, authenticationProvider, screenWidth, screenHeight),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthLayout(BuildContext context, AuthenticationProvider authenticationProvider) {
    bool isDark = context.theme.brightness == Brightness.dark;
    final colorScheme = context.colors;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          Image.asset(
            "assets/images/BigTvPostLogo.png",
            height: 40.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 8.h),

          Text(
            'WITHOUT FEAR OR FAVOR',
            style: typography.titleLarge?.copyWith(
              fontSize: 20.sp,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'మీకు నచ్చిన వార్తలు మీ చేతిలో',
            style: typography.bodyMedium?.copyWith(
              fontSize: 15.sp,
              color: isDark ? AppColorTokens.darkTextSecondary : AppColorTokens.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Hero Image with Gradients
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/login_image.jpg",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Please add 'login_image.jpg' to assets/images",
                          style: typography.bodySmall?.copyWith(color: Colors.grey, fontSize: 12.sp),
                        ),
                      );
                    },
                  ),
                ),

                // Top white gradient (very subtle)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120.h, // Height of the top gradient
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDark ? AppColorTokens.darkBackground : Colors.white).withValues(alpha: 0.35), // Very subtle white at top
                          (isDark ? AppColorTokens.darkBackground : Colors.white).withValues(alpha: 0.0), // Middle fade
                          Colors.transparent, // Completely transparent at bottom
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Bottom gradient (existing fade)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDark ? AppColorTokens.darkBackground : Colors.white).withValues(alpha: 0.0),
                          isDark ? AppColorTokens.darkBackground : Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          _getLoginContent(authenticationProvider.newAppLoginStatus),
        ],
      ),
    );
  }

  Widget _buildOtherLayout(BuildContext context, AuthenticationProvider authenticationProvider, double screenWidth, double screenHeight) {
    bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: isDark ? AppColorTokens.darkBackground : Colors.white,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Container(
          key: ValueKey(authenticationProvider.newAppLoginStatus),
          child: _getLoginContent(authenticationProvider.newAppLoginStatus),
        ),
      ),
    );
  }

  Widget _getLoginContent(NewAppLoginStatus status) {
    switch (status) {
      case NewAppLoginStatus.location:
        return const DistrictView(key: ValueKey('location'));
      case NewAppLoginStatus.category:
        return CategoriesView(key: ValueKey('category'));
      case NewAppLoginStatus.otp:
      case NewAppLoginStatus.login:
      case NewAppLoginStatus.none:
      default:
        return const UnifiedAuthView(key: ValueKey('unified_auth'));
    }
  }
}