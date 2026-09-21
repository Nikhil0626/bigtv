import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/domain/models/location_model.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UpdateRegionsView extends StatefulWidget {
  const UpdateRegionsView({super.key});

  @override
  State<UpdateRegionsView> createState() => _UpdateRegionsViewState();
}

class _UpdateRegionsViewState extends State<UpdateRegionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().getAllLocations();
    });
  }

  Widget _buildFallbackStateImage(String stateName) {
    String? imagePath;
    final s = stateName.toLowerCase();
    if (s.contains('telangana') || s.contains('తెలంగాణ')) {
      imagePath = 'assets/images/Telangana logo.png';
    } else if (s.contains('andhra') || s.contains('ap') || s.contains('ఆంధ్రప్రదేశ్')) {
      imagePath = 'assets/images/AP logo.png';
    }

    if (imagePath != null) {
      return Image.asset(
        imagePath,
        height: 42.sp,
        width: 42.sp,
        fit: BoxFit.contain,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStateLogo(LocationModel? location, String stateName) {
    final hasApiImage = location?.imageUrl != null && location!.imageUrl!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Align(
        alignment: Alignment.centerRight,
        child: hasApiImage
            ? CachedNetworkImage(
                imageUrl: location.imageUrl!,
                height: 42.sp,
                width: 42.sp,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 16,
                  height: 16,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFED1C24),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackStateImage(stateName),
              )
            : _buildFallbackStateImage(stateName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthenticationProvider>(
      builder: (_, authenticationProvider, __) {
        final locations = authenticationProvider.getAllLocationList;
        final selectedLocations = authenticationProvider.selectedLocations;

        if (authenticationProvider.isLocationLoading) {
          return const Center(child: AppLoadingScreen());
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
                        'Districts to be selected',
                        style: newAppFont(
                          color: isDark ? Colors.white : const Color(0xFF1E2022),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Select up to 5 districts',
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
                      '${selectedLocations.length} selected',
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

              // State Cards List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 8.h),
                  children: [
                    if (locations.isNotEmpty)
                      ...locations.map((location) {
                        final stateName = location.stateName;
                        final isSelected = selectedLocations.contains(stateName);

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: GestureDetector(
                            onTap: () {
                              authenticationProvider.addToSelectedLocations(stateName);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 70.h,
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
                                  // Logo on Right
                                  _buildStateLogo(location, stateName),

                                  Padding(
                                    padding: EdgeInsets.only(left: 14.w, right: 62.w),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: isSelected
                                              ? const Color(0xFFED1C24)
                                              : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                          size: 19.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                stateName,
                                                style: newAppFont(
                                                  fontSize: 13.5.sp,
                                                  color: isDark ? Colors.white : const Color(0xFF1E2022),
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                "Local news, events and updates from $stateName",
                                                style: newAppFont(
                                                  fontSize: 10.sp,
                                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                    else if (authenticationProvider.states != null && authenticationProvider.states!.isNotEmpty)
                      ...authenticationProvider.states!.entries.map((entry) {
                        final stateName = entry.value;
                        final isSelected = selectedLocations.contains(stateName);

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: GestureDetector(
                            onTap: () {
                              authenticationProvider.addToSelectedLocations(stateName);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 70.h,
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
                                  _buildStateLogo(null, stateName),
                                  Padding(
                                    padding: EdgeInsets.only(left: 14.w, right: 62.w),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: isSelected
                                              ? const Color(0xFFED1C24)
                                              : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                          size: 19.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                stateName,
                                                style: newAppFont(
                                                  fontSize: 13.5.sp,
                                                  color: isDark ? Colors.white : const Color(0xFF1E2022),
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                "Local news, events and updates from $stateName",
                                                style: newAppFont(
                                                  fontSize: 10.sp,
                                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
