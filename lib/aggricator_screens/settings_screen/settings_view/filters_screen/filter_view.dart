import 'package:chotanews/aggricator_screens/settings_screen/settings_view/filters_screen/update_categories_view.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/filters_screen/update_regions_view.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class _TopRightWavePainter extends CustomPainter {
  final bool isDark;
  _TopRightWavePainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.95, -size.height * 0.05);

    // Rich background radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFF420D11).withValues(alpha: 0.85),
                const Color(0xFF2B090C).withValues(alpha: 0.55),
                const Color(0xFF190608).withValues(alpha: 0.25),
                Colors.transparent,
              ]
            : [
                const Color(0xFFFFBDBD).withValues(alpha: 0.95),
                const Color(0xFFFFDEDE).withValues(alpha: 0.75),
                const Color(0xFFFFF0F0).withValues(alpha: 0.40),
                Colors.white.withValues(alpha: 0.0),
              ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 300));
    canvas.drawCircle(center, 300, glowPaint);

    // Prominent concentric wave ripple lines
    final radii = [45.0, 75.0, 110.0, 150.0, 195.0, 245.0, 300.0];
    final opacities = [0.45, 0.38, 0.30, 0.24, 0.18, 0.12, 0.06];

    for (int i = 0; i < radii.length; i++) {
      final linePaint = Paint()
        ..color = const Color(0xFFED1C24).withValues(alpha: isDark ? opacities[i] * 0.7 : opacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, radii[i], linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopRightWavePainter oldDelegate) => oldDelegate.isDark != isDark;
}

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  FilterViewState createState() => FilterViewState();
}

class FilterViewState extends State<FilterView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authenticationProvider, _) {
        final isTopicsTab = _selectedTabIndex == 0;
        final selectedCategories = authenticationProvider.selectedCategories;
        final selectedLocations = authenticationProvider.selectedLocations;

        final canUpdate = isTopicsTab
            ? selectedCategories.isNotEmpty
            : (selectedLocations.isNotEmpty && selectedLocations.length <= 5);

        final isLoading = isTopicsTab
            ? authenticationProvider.isCatSaveLoading
            : authenticationProvider.isLocationSendingLoading;

        return Container(
          color: isDark ? const Color(0xFF10121A) : Colors.white,
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: canUpdate
                    ? () {
                        if (isTopicsTab) {
                          authenticationProvider.sendCategoriesToServer(isFilter: true).then(
                            (value) {
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeView(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          );
                        } else {
                          authenticationProvider.sendLocationsToServer(context, isFilter: true).then(
                            (value) {
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeView(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          );
                        }
                      }
                    : () {
                        if (!isTopicsTab && selectedLocations.length > 5) {
                          CustomToast.showErrorToast(msg: "Please Select up to 5 Districts");
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: canUpdate
                        ? const Color(0xFFED1C24)
                        : (isDark ? Colors.white12 : AppColors.bodyTextColor.withValues(alpha: .2)),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: canUpdate
                        ? [
                            BoxShadow(
                              color: const Color(0xFFED1C24).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: isLoading
                      ? const AppLoadingScreen()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Update preferences',
                              style: newAppFont(
                                color: Colors.white,
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Your feed, tailored to you.',
                style: newAppFont(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10121A) : Colors.white,
      body: SizedBox.expand(
        child: CustomPaint(
          painter: _TopRightWavePainter(isDark: isDark),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(18.r),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2230) : const Color(0xFFF2F4F7),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14.sp,
                              color: isDark ? Colors.white : const Color(0xFF1E2022),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Filter',
                            style: newAppFont(
                              color: isDark ? Colors.white : const Color(0xFF1E2022),
                              fontSize: 16.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 32.w), // Balance back button
                    ],
                  ),
                ),

                // "Your interests." Hero Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Your ",
                              style: newAppFont(
                                color: isDark ? Colors.white : const Color(0xFF1E2022),
                                fontSize: 21.sp,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                TextSpan(
                                  text: "interests.",
                                  style: newAppFont(
                                    color: const Color(0xFFED1C24),
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Choose what matters to you.",
                            style: newAppFont(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      // Tune / sliders badge
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E1214) : const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.tune_rounded,
                            color: const Color(0xFFED1C24),
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 6.h),

                // Pill Segmented Tab Control
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B1E2B) : const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _tabController.animateTo(0);
                              setState(() => _selectedTabIndex = 0);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 6.5.h),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0 ? const Color(0xFFED1C24) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: _selectedTabIndex == 0
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFED1C24).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 15.sp,
                                    color: _selectedTabIndex == 0
                                        ? Colors.white
                                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Topics',
                                    style: newAppFont(
                                      color: _selectedTabIndex == 0
                                          ? Colors.white
                                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                      fontSize: 12.5.sp,
                                      fontWeight: _selectedTabIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _tabController.animateTo(1);
                              setState(() => _selectedTabIndex = 1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 6.5.h),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1 ? const Color(0xFFED1C24) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: _selectedTabIndex == 1
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFED1C24).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 15.sp,
                                    color: _selectedTabIndex == 1
                                        ? Colors.white
                                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Regions',
                                    style: newAppFont(
                                      color: _selectedTabIndex == 1
                                          ? Colors.white
                                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                      fontSize: 12.5.sp,
                                      fontWeight: _selectedTabIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Tab View Body
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      UpdateCategoriesView(),
                      UpdateRegionsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }
}
