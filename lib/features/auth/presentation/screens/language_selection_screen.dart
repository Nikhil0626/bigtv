import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/domain/models/language_model.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Default fallback languages if API is loading or returns empty
  final List<Map<String, dynamic>> _fallbackLanguages = [
    {'id': 1, 'code': 'te', 'native': 'తెలుగు', 'english': 'Telugu'},
    {'id': 2, 'code': 'en', 'native': 'English', 'english': 'English'},
    {'id': 3, 'code': 'hi', 'native': 'हिन्दी', 'english': 'Hindi'},
    {'id': 4, 'code': 'ta', 'native': 'தமிழ்', 'english': 'Tamil'},
    {'id': 5, 'code': 'kn', 'native': 'ಕನ್ನಡ', 'english': 'Kannada'},
    {'id': 6, 'code': 'ml', 'native': 'മലയാളം', 'english': 'Malayalam'},
    {'id': 7, 'code': 'mr', 'native': 'मराठी', 'english': 'Marathi'},
    {'id': 8, 'code': 'bn', 'native': 'বাংলা', 'english': 'Bengali'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthenticationProvider>();
      authProvider.getAllLanguages().then((_) {
        // Default to Telugu if none selected
        if (authProvider.selectedLanguageId == null && authProvider.getAllLanguageList.isNotEmpty) {
          final teLang = authProvider.getAllLanguageList.firstWhere(
            (l) => l.code == 'te',
            orElse: () => authProvider.getAllLanguageList.first,
          );
          authProvider.setSelectedLanguageId(teLang.id);
        } else if (authProvider.selectedLanguageId == null) {
          authProvider.setSelectedLanguageId(1);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthenticationProvider>(
      builder: (context, provider, child) {
        if (provider.isLanguageLoading && provider.getAllLanguageList.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFFBFBFC),
            body: Center(child: AppLoadingScreen()),
          );
        }

        final List<LanguageModel> languages = provider.getAllLanguageList;
        final bool useFallbacks = languages.isEmpty;

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
                      // TOP ROW: Back button & Pill badge [🌐 LANGUAGE]
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                provider.updateLoginStatus(NewAppLoginStatus.otp);
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
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFFED1C24),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "LANGUAGE",
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
                                        text: "Your language.",
                                        style: TextStyle(
                                          color: Color(0xFFED1C24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  "Select your preferred language for news.",
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
                          // Right graphic badge with globe & chat speech bubbles
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.language_rounded,
                                    size: 34.sp,
                                    color: const Color(0xFFED1C24),
                                  ),
                                  Positioned(
                                    right: 6.w,
                                    bottom: 6.h,
                                    child: Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 15.sp,
                                      color: const Color(0xFFED1C24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // SECTION HEADER: "Choose language" / "Select one"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "Choose language",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF181A20),
                            ),
                          ),
                          Text(
                            "Select one",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w400,
                              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF7A7E85),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // 2-COLUMN LANGUAGE GRID
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: useFallbacks ? _fallbackLanguages.length : languages.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 2.15,
                          ),
                          itemBuilder: (context, index) {
                            final int langId = useFallbacks
                                ? _fallbackLanguages[index]['id'] as int
                                : languages[index].id;
                            final String nativeName = useFallbacks
                                ? _fallbackLanguages[index]['native'] as String
                                : languages[index].getNativeName();
                            final String englishName = useFallbacks
                                ? _fallbackLanguages[index]['english'] as String
                                : languages[index].getEnglishName();

                            final bool isSelected = provider.selectedLanguageId == langId;

                            return GestureDetector(
                              onTap: () {
                                provider.setSelectedLanguageId(langId);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF2A1517) : const Color(0xFFFFF7F7))
                                      : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                                  borderRadius: BorderRadius.circular(12.r),
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
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nativeName,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF181A20),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            englishName,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11.5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF7A7E85),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    // Custom Radio Button Indicator
                                    Container(
                                      width: 19.w,
                                      height: 19.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFED1C24)
                                              : (isDark ? const Color(0xFF5E5E5E) : const Color(0xFF9EA3AE)),
                                          width: isSelected ? 5.5.w : 1.5,
                                        ),
                                        color: isSelected ? (isDark ? const Color(0xFF1A1A1A) : Colors.white) : Colors.transparent,
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
                onTap: provider.selectedLanguageId == null
                    ? null
                    : () {
                        provider.saveLanguageAndProceed(
                          context,
                          provider.selectedLanguageId!,
                        );
                      },
                child: Container(
                  width: double.infinity,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: provider.selectedLanguageId == null
                        ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E4EA))
                        : const Color(0xFFED1C24),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: provider.selectedLanguageId == null
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
                    child: Row(
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
