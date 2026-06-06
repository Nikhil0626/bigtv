import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_enums.dart';
import 'district_view.dart';
import 'categories_view.dart';
import 'unified_auth_view.dart';
import '../authentication_provider/authentication_provider.dart';

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

        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          height(height: 10.h),
          Image.asset(
            "assets/images/BigTvPostLogo.png",
            height: 40.h,
            fit: BoxFit.contain,
          ),
          height(height: 8.h),

          Text(
            'STAY UPDATED EVERY MINUTE',
            style: homeScreenFontStyle(
              fontSize: 20.sp,
              color: const Color(0xFFE50914),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          height(height: 4.h),
          Text(
            'మీకు నచ్చిన వార్తలు మీ చేతిలో',
            style: homeScreenFontStyle(
              fontSize: 15.sp,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Hero Image with Gradients
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/login_image.png",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Please add 'login_image.png' to assets/images",
                          style: newAppFont(color: Colors.grey, fontSize: 12.sp),
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
                          Colors.white.withOpacity(0.35), // Very subtle white at top
                          Colors.white.withOpacity(0.0), // Middle fade
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
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E).withOpacity(0.0)
                              : Colors.white.withOpacity(0.0),
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          height(height: 16.h),

          // The Authentication Form directly inline
          _getLoginContent(authenticationProvider.newAppLoginStatus),
        ],
      ),
    );
  }

  Widget _buildOtherLayout(BuildContext context, AuthenticationProvider authenticationProvider, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      height: screenHeight,
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
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