import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/domain/models/location_model.dart';
import 'package:chotanews/utils/app_loading_screen.dart';

class UpdateRegionsView extends StatefulWidget {
  const UpdateRegionsView({super.key});

  @override
  State<UpdateRegionsView> createState() => _UpdateRegionsViewState();
}

class _UpdateRegionsViewState extends State<UpdateRegionsView> {
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
      size: 30.sp,
      color: const Color(0xFFED1C24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthenticationProvider>(
      builder: (_, authProvider, __) {
        if (authProvider.isLocationLoading && authProvider.getAllLocationList.isEmpty) {
          return const Center(child: AppLoadingScreen());
        }

        final List<LocationModel> locations = authProvider.getAllLocationList;
        final bool useFallbacks = locations.isEmpty &&
            (authProvider.states == null || authProvider.states!.isEmpty);
        final int totalItems = useFallbacks ? _fallbackLocations.length : locations.length;
        final int selectedCount = authProvider.selectedLocations.length;

        return Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION BAR: "Districts to be selected" & "[ N selected ]"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Districts to be selected",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF181A20),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Select up to 5 districts",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5.sp,
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

              SizedBox(height: 10.h),

              // VERTICAL LOCATION LIST
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 8.h),
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
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: GestureDetector(
                        onTap: () {
                          authProvider.addToSelectedLocations(stateKey);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF2A1517) : const Color(0xFFFFF8F8))
                                : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                            borderRadius: BorderRadius.circular(14.r),
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
                                width: 56.w,
                                height: 56.w,
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF251A1C) : const Color(0xFFFFF6F6),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Center(
                                  child: _buildLocationImage(
                                    imageUrl: imageUrl,
                                    stateName: nativeName,
                                    fallbackAsset: fallbackAsset,
                                  ),
                                ),
                              ),

                              SizedBox(width: 12.w),

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
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF181A20),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      englishName,
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

                              // Checkbox Indicator
                              Container(
                                width: 20.w,
                                height: 20.w,
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
                                          size: 14.sp,
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
        );
      },
    );
  }
}
