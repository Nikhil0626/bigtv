import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'update_categories_view.dart';
import 'update_regions_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        final isTopicsTab = _selectedTabIndex == 0;
        final selectedCategories = authProvider.selectedCategories;
        final selectedLocations = authProvider.selectedLocations;

        final canUpdate = isTopicsTab
            ? selectedCategories.isNotEmpty
            : (selectedLocations.isNotEmpty && selectedLocations.length <= 5);

        final isLoading = isTopicsTab
            ? authProvider.isCatSaveLoading
            : authProvider.isLocationSendingLoading;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
          body: Stack(
            children: [
              // Top Right Wave Ripple Art
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR: Back button + Pill Badge [ 🎯 FILTER ]
                    Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
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
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 13.sp,
                                      color: const Color(0xFFED1C24),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      "FILTER",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFED1C24),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          // HERO SECTION: Title + Subtitle + Right Graphic Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: "Your news.\n",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : const Color(0xFF181A20),
                                          height: 1.15,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: "Your preferences.",
                                            style: TextStyle(
                                              color: Color(0xFFED1C24),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      "Choose what matters to you.",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6C7278),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Right graphic badge
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2E1214) : const Color(0xFFFFECEC),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFED1C24).withValues(alpha: isDark ? 0.12 : 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.tune_rounded,
                                    size: 30.sp,
                                    color: const Color(0xFFED1C24),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.h),

                          // Pill Segmented Tab Switcher (Topics / Regions)
                          Container(
                            padding: EdgeInsets.all(3.5.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F2F5),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E4EA),
                                width: 0.8,
                              ),
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
                                      duration: const Duration(milliseconds: 180),
                                      padding: EdgeInsets.symmetric(vertical: 7.h),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 0 ? const Color(0xFFED1C24) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9.r),
                                        boxShadow: _selectedTabIndex == 0
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFED1C24).withValues(alpha: 0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.grid_view_rounded,
                                            size: 14.sp,
                                            color: _selectedTabIndex == 0
                                                ? Colors.white
                                                : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6C7278)),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Topics',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: _selectedTabIndex == 0
                                                  ? Colors.white
                                                  : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF4A4E5A)),
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
                                      duration: const Duration(milliseconds: 180),
                                      padding: EdgeInsets.symmetric(vertical: 7.h),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 1 ? const Color(0xFFED1C24) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9.r),
                                        boxShadow: _selectedTabIndex == 1
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFED1C24).withValues(alpha: 0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            size: 14.sp,
                                            color: _selectedTabIndex == 1
                                                ? Colors.white
                                                : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6C7278)),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Regions',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: _selectedTabIndex == 1
                                                  ? Colors.white
                                                  : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF4A4E5A)),
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
                        ],
                      ),
                    ),

                    // TAB VIEW BODY (SCROLLABLE ONLY)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          UpdateCategoriesView(),
                          UpdateRegionsView(),
                        ],
                      ),
                    ),

                    // FIXED PINNED BOTTOM BUTTON (NOT IN SCROLL)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 12.h),
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
                        onTap: canUpdate
                            ? () {
                                if (isTopicsTab) {
                                  authProvider.sendCategoriesToServer(isFilter: true).then(
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
                                  authProvider.sendLocationsToServer(context, isFilter: true).then(
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
                                : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E4EA)),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: canUpdate
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFED1C24).withValues(alpha: 0.22),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: isLoading
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
                                        "Update preferences",
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
