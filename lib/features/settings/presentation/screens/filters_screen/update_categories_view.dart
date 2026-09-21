import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/domain/models/categories_model.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UpdateCategoriesView extends StatefulWidget {
  const UpdateCategoriesView({super.key});

  @override
  State<UpdateCategoriesView> createState() => _UpdateCategoriesViewState();
}

class _UpdateCategoriesViewState extends State<UpdateCategoriesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().getAllCategories();
    });
  }

  String _getCategorySubtitle(String name) {
    final lower = name.trim().toLowerCase();
    if (lower.contains('business') || lower.contains('వ్యాపార') || lower.contains('వాణిజ్య')) return 'Business';
    if (lower.contains('sport') || lower.contains('క్రీడ')) return 'Sports';
    if (lower.contains('tech') || lower.contains('సాంకేతిక')) return 'Technology';
    if (lower.contains('entertain') || lower.contains('వినోద') || lower.contains('సినిమా') || lower.contains('movie')) return 'Entertainment';
    if (lower.contains('life') || lower.contains('జీవన')) return 'Lifestyle';
    if (lower.contains('educat') || lower.contains('విద్య') || lower.contains('చదువు')) return 'Education';
    if (lower.contains('politic') || lower.contains('రాజకీయ')) return 'Politics';
    if (lower.contains('scien') || lower.contains('విజ్ఞాన') || lower.contains('సైన్స్')) return 'Science';
    if (lower.contains('startup') || lower.contains('స్టార్టప్')) return 'Startup';
    if (lower.contains('nation') || lower.contains('జాతీయ')) return 'National';
    if (lower.contains('internation') || lower.contains('అంతర్జాతీయ') || lower.contains('world')) return 'International';
    if (lower.contains('crime') || lower.contains('క్రైమ్')) return 'Crime';
    if (lower.contains('health') || lower.contains('ఆరోగ్య')) return 'Health';
    if (lower.contains('spirit') || lower.contains('భక్తి') || lower.contains('ఆధ్యాత్మిక')) return 'Spiritual';
    if (lower.contains('auto') || lower.contains('ఆటో')) return 'Automobile';
    return '';
  }

  String _getFallbackImage(String categoryName, int index) {
    final name = categoryName.trim().toLowerCase();
    if (name.contains('business') || name.contains('వ్యాపారం')) return 'assets/images/business_icon.png';
    if (name.contains('sports') || name.contains('క్రీడలు')) return 'assets/images/sports_icon.png';
    if (name.contains('entertainment') || name.contains('వినోదం') || name.contains('cinema')) return 'assets/images/entertainment_icon.png';
    if (name.contains('politics') || name.contains('రాజకీయాలు')) return 'assets/images/politics_icon.png';
    if (name.contains('technology') || name.contains('సాంకేతికత') || name.contains('tech')) return 'assets/images/tech_icon.png';
    if (name.contains('lifestyle') || name.contains('జీవనశైలి')) return 'assets/images/lifestyle_icon.png';
    if (name.contains('science') || name.contains('సైన్స్') || name.contains('విజ్ఞాన')) return 'assets/images/science.jpg';
    if (name.contains('education') || name.contains('విద్య')) return 'assets/images/education_icon.png';
    if (name.contains('health') || name.contains('ఆరోగ్య')) return 'assets/images/health_icon.png';
    if (name.contains('auto') || name.contains('ఆటో')) return 'assets/images/auto_icon.png';

    final fallbacks = [
      'assets/images/business.jpg',
      'assets/images/sports.jpg',
      'assets/images/entertainment.jpg',
      'assets/images/politics.jpg',
      'assets/images/technology.jpg',
      'assets/images/lifestyle.jpg',
      'assets/images/science.jpg',
      'assets/images/startup.jpg',
      'assets/images/education.jpg'
    ];
    return fallbacks[index % fallbacks.length];
  }

  Widget _buildCategoryImage(CategoryModel category, int index) {
    final hasApiImage = category.imageUrl != null && category.imageUrl!.trim().isNotEmpty;
    final fallbackAsset = _getFallbackImage(category.categoryName ?? '', index);

    if (hasApiImage) {
      return CachedNetworkImage(
        imageUrl: category.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Color(0xFFED1C24),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          fallbackAsset,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Image.asset(
        fallbackAsset,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthenticationProvider>(
      builder: (context, authenticationProvider, _) {
        final categories = authenticationProvider.getAllCategoryList;
        final selectedCategories = authenticationProvider.selectedCategories;

        if (authenticationProvider.isCatLoading) {
          return const Center(child: AppLoadingScreen());
        }

        if (categories.isEmpty) {
          return const Center(child: AppNoData());
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          child: Column(
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose categories',
                        style: newAppFont(
                          color: isDark ? Colors.white : const Color(0xFF1E2022),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Select all that apply',
                        style: newAppFont(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2E1214) : const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${selectedCategories.length} selected',
                      style: newAppFont(
                        color: const Color(0xFFED1C24),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Categories Grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 8.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.10,
                    crossAxisSpacing: 9.w,
                    mainAxisSpacing: 9.h,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final categoryName = category.categoryName?.toString() ?? '';
                    final isSelected = selectedCategories.contains(categoryName);
                    final subtitle = _getCategorySubtitle(categoryName);

                    return GestureDetector(
                      onTap: () {
                        authenticationProvider.addToSelectedEngagements(categoryName);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B1E2B) : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFED1C24)
                                : (isDark ? const Color(0xFF2B2F42) : const Color(0xFFE2E4EA)),
                            width: isSelected ? 1.4 : 0.9,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFED1C24).withValues(alpha: 0.15),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Stack(
                          children: [
                            // Top & Center Image Area
                            Positioned.fill(
                              bottom: 36.h,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 2.h),
                                child: Center(
                                  child: _buildCategoryImage(category, index),
                                ),
                              ),
                            ),

                            // Top-Right Checkmark Indicator
                            Positioned(
                              top: 6.h,
                              right: 6.w,
                              child: Container(
                                width: 17.w,
                                height: 17.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFED1C24)
                                      : (isDark ? const Color(0xFF242838) : Colors.white),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: isDark ? const Color(0xFF454B64) : Colors.grey.shade400,
                                          width: 1.1,
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

                            // Bottom Category Titles
                            Positioned(
                              left: 8.w,
                              right: 8.w,
                              bottom: 5.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    categoryName,
                                    style: newAppFont(
                                      color: isDark ? Colors.white : const Color(0xFF1E2022),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (subtitle.isNotEmpty)
                                    Text(
                                      subtitle,
                                      style: newAppFont(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
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
        );
      },
    );
  }
}
