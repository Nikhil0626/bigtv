import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/models/reporter_model.dart';
import '../providers/reporters_provider.dart';
import 'reporter_details_screen.dart';

class ReportersScreen extends StatefulWidget {
  const ReportersScreen({super.key});

  @override
  State<ReportersScreen> createState() => _ReportersScreenState();
}

class _ReportersScreenState extends State<ReportersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: Consumer<ReportersProvider>(
              builder: (context, provider, child) {
                final reporters = provider.filteredReporters;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR: Back button + Pill Badge [ 👥 REPORTERS ]
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
                                      Icons.badge_outlined,
                                      size: 13.sp,
                                      color: const Color(0xFFED1C24),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      "REPORTERS",
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFED1C24),
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            "Reporters",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF181A20),
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Meet our dedicated journalists & field correspondents",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.grey.shade400 : const Color(0xFF6C727F),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Search Bar Section
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? context.cardColor
                        : const Color(0xFFF2F2F4),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => provider.setSearchQuery(value),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.typography.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search name or location',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20.w,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                                size: 18.w,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  children: provider.availableFilters.map((filter) {
                    final isSelected = provider.selectedStateFilter == filter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => provider.setStateFilter(filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? context.cardColor
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? context.borderColor
                                      : const Color(0xFFCCCCCC)),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF333333)),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 8.h),

              // Reporters List
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : reporters.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48.w,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'No reporters found',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                            itemCount: reporters.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              indent: 84.w,
                              endIndent: 16.w,
                              color: context.borderColor.withValues(alpha: 0.3),
                            ),
                            itemBuilder: (context, index) {
                              final reporter = reporters[index];
                              return _buildReporterListItem(context, reporter);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    ),
  ],
),
);
}

  Widget _buildReporterListItem(BuildContext context, ReporterModel reporter) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReporterDetailsScreen(reporter: reporter),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Reporter Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: reporter.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: reporter.imageUrl,
                      width: 56.w,
                      height: 56.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 56.w,
                        height: 56.w,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.network(
                        reporter.imageUrl,
                        width: 56.w,
                        height: 56.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56.w,
                          height: 56.w,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade600,
                            size: 28.sp,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 56.w,
                      height: 56.w,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade600,
                        size: 28.sp,
                      ),
                    ),
            ),
            SizedBox(width: 14.w),

            // Reporter Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reporter.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.typography.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    reporter.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    reporter.location,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Forward Arrow Chevron
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 22.w,
            ),
          ],
        ),
      ),
    );
  }
}
