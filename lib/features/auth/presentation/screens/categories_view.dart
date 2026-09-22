import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/domain/models/categories_model.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  // Default fallback categories with Telugu names & icons
  final List<Map<String, dynamic>> _fallbackCategories = [
    {'name': 'బిజినెస్', 'icon': Icons.trending_up_rounded},
    {'name': 'స్పోర్ట్స్', 'icon': Icons.directions_run_rounded},
    {'name': 'టెక్నాలజీ', 'icon': Icons.devices_rounded},
    {'name': 'సినిమా', 'icon': Icons.movie_creation_outlined},
    {'name': 'లైఫ్ స్టైల్', 'icon': Icons.self_improvement_rounded},
    {'name': 'ఎడ్యుకేషన్', 'icon': Icons.school_outlined},
    {'name': 'రాజకీయాలు', 'icon': Icons.account_balance_outlined},
    {'name': 'హెల్త్', 'icon': Icons.favorite_outline_rounded},
    {'name': 'జనరల్', 'icon': Icons.newspaper_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().getAllCategories();
    });
  }

  IconData _getCategoryFallbackIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('బిజినెస్') || lower.contains('business')) return Icons.trending_up_rounded;
    if (lower.contains('స్పోర్ట్స్') || lower.contains('sport')) return Icons.directions_run_rounded;
    if (lower.contains('టెక్నాలజీ') || lower.contains('tech')) return Icons.devices_rounded;
    if (lower.contains('సినిమా') || lower.contains('cinema') || lower.contains('movie')) return Icons.movie_creation_outlined;
    if (lower.contains('లైఫ్') || lower.contains('life')) return Icons.self_improvement_rounded;
    if (lower.contains('ఎడ్యుకేషన్') || lower.contains('education')) return Icons.school_outlined;
    if (lower.contains('రాజకీయాలు') || lower.contains('politics')) return Icons.account_balance_outlined;
    if (lower.contains('హెల్త్') || lower.contains('health')) return Icons.favorite_outline_rounded;
    if (lower.contains('జనరల్') || lower.contains('general')) return Icons.newspaper_rounded;
    return Icons.grid_view_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: Stack(
        children: [
          // Background top right wave design
          Positioned(
            top: 0,
            right: 0,
            width: MediaQuery.of(context).size.width,
            height: 350.h,
            child: const CustomPaint(
              painter: TopRightWavePainter(),
            ),
          ),

          SafeArea(
            child: Consumer<AuthenticationProvider>(
              builder: (context, authProvider, __) {
                if (authProvider.isCatLoading && authProvider.getAllCategoryList.isEmpty) {
                  return const Center(child: AppLoadingScreen());
                }

                final List<CategoryModel> categories = authProvider.getAllCategoryList;
                final bool useFallbacks = categories.isEmpty;
                final int selectedCount = authProvider.selectedCategories.length;

                return Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),

                            // HERO SECTION: Telugu Title & Subtitle
                            RichText(
                              text: TextSpan(
                                text: "మీ ఆసక్తులను\n",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF181A20),
                                  height: 1.15,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "ఎంచుకోండి",
                                    style: TextStyle(
                                      color: Color(0xFFED1C24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "మీకు నచ్చిన అంశాలను ఎంచుకోండి",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6C7278),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // SUBHEADER: "మీ కోసం వార్తలు" & "[ 3 selected ]"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "మీ కోసం వార్తలు",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF181A20),
                                  ),
                                ),
                                if (selectedCount > 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFECEC),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Text(
                                      "$selectedCount selected",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFED1C24),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            // 3-COLUMN CATEGORY GRID
                            Expanded(
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: useFallbacks ? _fallbackCategories.length : categories.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 10.h,
                                  childAspectRatio: 0.84,
                                ),
                                itemBuilder: (context, index) {
                                  final String categoryName = useFallbacks
                                      ? _fallbackCategories[index]['name'] as String
                                      : (categories[index].categoryName ?? '');
                                  final String? imageUrl = useFallbacks
                                      ? null
                                      : categories[index].imageUrl;

                                  final bool isSelected = authProvider.selectedCategories.contains(categoryName);

                                  return GestureDetector(
                                    onTap: () {
                                      authProvider.addToSelectedEngagements(categoryName);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFFFF7F7) : Colors.white,
                                        borderRadius: BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFED1C24)
                                              : const Color(0xFFE2E4EA),
                                          width: isSelected ? 1.3 : 0.9,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? const Color(0xFFED1C24).withValues(alpha: 0.08)
                                                : Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Top right selection indicator
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              width: 17.w,
                                              height: 17.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected ? const Color(0xFFED1C24) : Colors.transparent,
                                                border: isSelected
                                                    ? null
                                                    : Border.all(
                                                        color: const Color(0xFF9EA3AE),
                                                        width: 1.3,
                                                      ),
                                              ),
                                              child: isSelected
                                                  ? Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 11.sp,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),

                                          // Main card content: Icon / Image + Title
                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 4.h),
                                                // Category Illustration / Icon
                                                if (imageUrl != null && imageUrl.isNotEmpty)
                                                  CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    height: 42.h,
                                                    width: 42.h,
                                                    fit: BoxFit.contain,
                                                    color: const Color(0xFFED1C24),
                                                    errorWidget: (_, __, ___) => Icon(
                                                      _getCategoryFallbackIcon(categoryName),
                                                      size: 34.sp,
                                                      color: const Color(0xFFED1C24),
                                                    ),
                                                  )
                                                else
                                                  Icon(
                                                    _getCategoryFallbackIcon(categoryName),
                                                    size: 36.sp,
                                                    color: const Color(0xFFED1C24),
                                                  ),

                                                SizedBox(height: 8.h),

                                                // Category Name
                                                Text(
                                                  categoryName,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF181A20),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
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
                    ),

                    // STICKY BOTTOM "Continue ->" BUTTON (Compact Height: 42.h)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBFC),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: authProvider.selectedCategories.isNotEmpty && !authProvider.isCatSaveLoading
                            ? () {
                                authProvider.sendCategoriesToServer();
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: authProvider.selectedCategories.isEmpty
                                ? const Color(0xFFE2E4EA)
                                : const Color(0xFFED1C24),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: authProvider.selectedCategories.isEmpty
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
                            child: authProvider.isCatSaveLoading
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

