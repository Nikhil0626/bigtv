import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/domain/models/location_model.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DistrictView extends StatefulWidget {
  const DistrictView({super.key});

  @override
  State<DistrictView> createState() => _DistrictViewState();
}

class _DistrictViewState extends State<DistrictView> {
  // Default fallback locations with Telugu & English names
  final List<Map<String, dynamic>> _fallbackLocations = [
    {
      'id': 1,
      'nativeName': 'తెలంగాణ',
      'englishName': 'Telangana',
      'asset': 'assets/images/Telangana logo.png',
    },
    {
      'id': 2,
      'nativeName': 'ఆంధ్రప్రదేశ్',
      'englishName': 'Andhra Pradesh',
      'asset': 'assets/images/AP logo.png',
    },
    {
      'id': 3,
      'nativeName': 'కేరళ',
      'englishName': 'Kerala',
      'asset': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().getAllLocations();
    });
  }

  Widget _buildLocationHeroGraphic(bool isDark) {
    return Container(
      width: 78.w,
      height: 78.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E1214) : const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFED1C24).withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Folded map outline
            CustomPaint(
              size: Size(44.w, 36.h),
              painter: _MapOutlinePainter(),
            ),
            // Pin marker
            Positioned(
              top: 14.h,
              child: Icon(
                Icons.location_on,
                color: const Color(0xFFED1C24),
                size: 26.sp,
              ),
            ),
            // Pin center dot
            Positioned(
              top: 20.5.h,
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationImage({
    required String? imageUrl,
    required String stateName,
    String? fallbackAsset,
  }) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      final cleanUrl = imageUrl.trim();
      if (cleanUrl.toLowerCase().endsWith('.svg') || cleanUrl.toLowerCase().contains('.svg')) {
        return SvgPicture.network(
          cleanUrl,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(color: Color(0xFFED1C24), strokeWidth: 1.8),
            ),
          ),
        );
      }
      return CachedNetworkImage(
        imageUrl: cleanUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(color: Color(0xFFED1C24), strokeWidth: 1.8),
          ),
        ),
        errorWidget: (_, __, ___) => _buildFallbackStateWidget(stateName, fallbackAsset),
      );
    }

    return _buildFallbackStateWidget(stateName, fallbackAsset);
  }

  Widget _buildFallbackStateWidget(String stateName, String? fallbackAsset) {
    if (fallbackAsset != null && fallbackAsset.isNotEmpty) {
      return Image.asset(
        fallbackAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildStateIcon(stateName),
      );
    }

    final lower = stateName.toLowerCase();
    if (lower.contains('telangana') || lower.contains('తెలంగాణ')) {
      return Image.asset(
        'assets/images/Telangana logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildStateIcon(stateName),
      );
    }
    if (lower.contains('andhra') || lower.contains('ఆంధ్రప్రదేశ్')) {
      return Image.asset(
        'assets/images/AP logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildStateIcon(stateName),
      );
    }

    return _buildStateIcon(stateName);
  }

  Widget _buildStateIcon(String stateName) {
    return Icon(
      Icons.account_balance_rounded,
      size: 34.sp,
      color: const Color(0xFFED1C24).withValues(alpha: 0.85),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, __) {
        if (authProvider.isLocationLoading && authProvider.getAllLocationList.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFFBFBFC),
            body: Center(child: AppLoadingScreen()),
          );
        }

        final List<LocationModel> locations = authProvider.getAllLocationList;
        final bool useFallbacks = locations.isEmpty;
        final int selectedCount = authProvider.selectedLocations.length;
        final int totalItems = useFallbacks ? _fallbackLocations.length : locations.length;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
          body: Stack(
            children: [
              // Background top right wave design
              Positioned(
                top: 0,
                right: 0,
                width: MediaQuery.of(context).size.width,
                height: 350.h,
                child: CustomPaint(
                  painter: TopRightWavePainter(isDark: isDark),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP ROW: Back button & Pill badge [📍 LOCATION]
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                authProvider.updateLoginStatus(NewAppLoginStatus.category);
                              }
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              padding: EdgeInsets.all(7.5.w),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2026) : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.35)
                                        : Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 15.sp,
                                color: isDark ? Colors.white : const Color(0xFF181A20),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2E1214) : const Color(0xFFFFECEC),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 13.sp,
                                  color: const Color(0xFFED1C24),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "LOCATION",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFFED1C24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // HERO SECTION: "News closer to you." + Map Graphic
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: "News closer\n",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 27.sp,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF181A20),
                                      height: 1.1,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: "to you.",
                                        style: TextStyle(
                                          color: Color(0xFFED1C24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "Get local news from the places\nyou choose.",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6C7278),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          _buildLocationHeroGraphic(isDark),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      // SECTION BAR: "Choose locations" & "[ N selected ]"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Choose locations",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF181A20),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "Select all that apply",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6C7278),
                                ),
                              ),
                            ],
                          ),
                          if (selectedCount > 0)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E1214) : const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Text(
                                "$selectedCount selected",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFED1C24),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // VERTICAL LOCATION LIST
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: totalItems,
                          itemBuilder: (context, index) {
                            final String stateKey;
                            final String nativeName;
                            final String englishName;
                            final String? imageUrl;
                            final String? fallbackAsset;

                            if (useFallbacks) {
                              final item = _fallbackLocations[index];
                              nativeName = item['nativeName'] as String;
                              englishName = item['englishName'] as String;
                              stateKey = nativeName;
                              imageUrl = null;
                              fallbackAsset = item['asset'] as String?;
                            } else {
                              final loc = locations[index];
                              stateKey = loc.stateName;
                              nativeName = loc.getNativeName();
                              englishName = loc.getEnglishName();
                              imageUrl = loc.imageUrl;
                              fallbackAsset = null;
                            }

                            final bool isSelected = authProvider.selectedLocations.contains(stateKey);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: GestureDetector(
                                onTap: () {
                                  authProvider.addToSelectedLocations(stateKey);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF2A1517) : const Color(0xFFFFF8F8))
                                        : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFED1C24)
                                          : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E4EA)),
                                      width: isSelected ? 1.4 : 0.9,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(0xFFED1C24).withValues(alpha: isDark ? 0.18 : 0.08)
                                            : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02)),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // State Artwork / Sketch Container
                                      Container(
                                        width: 64.w,
                                        height: 64.w,
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF251A1C) : const Color(0xFFFFF6F6),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Center(
                                          child: _buildLocationImage(
                                            imageUrl: imageUrl,
                                            stateName: nativeName,
                                            fallbackAsset: fallbackAsset,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 14.w),

                                      // State Names (Native & English)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              nativeName,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF181A20),
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              englishName,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6C7278),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Checkbox Indicator
                                      Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFED1C24) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.r),
                                          border: isSelected
                                              ? null
                                              : Border.all(
                                                  color: isDark ? const Color(0xFF5E5E5E) : const Color(0xFFD0D4DC),
                                                  width: 1.4,
                                                ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 15.sp,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM NAVIGATION BAR: Sticky "Continue ->" BUTTON (Compact Height: 42.h)
          bottomNavigationBar: SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: authProvider.selectedLocations.isNotEmpty && !authProvider.isLocationSendingLoading
                    ? () {
                        authProvider.sendLocationsToServer(context).then((_) {
                          if (context.mounted && authProvider.newAppLoginStatus == NewAppLoginStatus.home) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeView(),
                              ),
                              (route) => false,
                            );
                          }
                        });
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: authProvider.selectedLocations.isEmpty
                        ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E4EA))
                        : const Color(0xFFED1C24),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: authProvider.selectedLocations.isEmpty
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFFED1C24).withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: authProvider.isLocationSendingLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Continue",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ],
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

/// Custom painter for the folded map illustration in the hero section
class _MapOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFED1C24).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // 3-fold map bottom lines
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.05, h * 0.35);
    path.lineTo(w * 0.35, h * 0.25);
    path.lineTo(w * 0.65, h * 0.35);
    path.lineTo(w * 0.95, h * 0.25);

    path.lineTo(w * 0.95, h * 0.85);
    path.lineTo(w * 0.65, h * 0.95);
    path.lineTo(w * 0.35, h * 0.85);
    path.lineTo(w * 0.05, h * 0.95);
    path.close();

    // Fold vertical dividers
    path.moveTo(w * 0.35, h * 0.25);
    path.lineTo(w * 0.35, h * 0.85);

    path.moveTo(w * 0.65, h * 0.35);
    path.lineTo(w * 0.65, h * 0.95);

    canvas.drawPath(path, paint);

    // Radiating action lines around marker
    final rayPaint = Paint()
      ..color = const Color(0xFFED1C24).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Top left ray
    canvas.drawLine(Offset(w * 0.25, h * 0.1), Offset(w * 0.18, h * 0.03), rayPaint);
    // Top right ray
    canvas.drawLine(Offset(w * 0.75, h * 0.1), Offset(w * 0.82, h * 0.03), rayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
