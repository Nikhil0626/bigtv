import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import '../../data/models/reporter_model.dart';

class ReporterDetailsScreen extends StatefulWidget {
  final ReporterModel reporter;

  const ReporterDetailsScreen({
    super.key,
    required this.reporter,
  });

  @override
  State<ReporterDetailsScreen> createState() => _ReporterDetailsScreenState();
}

class _ReporterDetailsScreenState extends State<ReporterDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isFollowing = false;
  AnimationController? _waveController;
  Animation<double>? _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initWaveAnimation();
    _loadFollowStatus();
  }

  void _initWaveAnimation() {
    if (_waveController == null) {
      _waveController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(reverse: true);
      _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_waveController!);
    }
  }

  @override
  void dispose() {
    _waveController?.dispose();
    super.dispose();
  }

  Future<void> _loadFollowStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isFollowing = prefs.getBool('reporter_following_${widget.reporter.id}') ?? false;
      });
    }
  }

  ReporterModel get reporter => widget.reporter;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch call: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri.parse("https://wa.me/$cleanNumber");
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _initWaveAnimation();
    HomeProvider? homeProvider;
    try {
      homeProvider = context.watch<HomeProvider>();
    } catch (_) {}
    final isMalayalam = homeProvider?.langCode == 'ml';
    final isTelugu = homeProvider != null &&
        (homeProvider.langCode == 'te' || (!isMalayalam && !homeProvider.isEnglishMode));

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = (screenHeight * 0.48).clamp(320.0, 430.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColorTokens.cinematicBackground,
        body: Stack(
          children: [
            // 1. Hero Image (properly sized and centered in the top hero area)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (reporter.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: reporter.imageUrl,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.0, -0.15),
                      placeholder: (context, url) => Container(
                        color: AppColorTokens.cinematicCard,
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColorTokens.cinemaRed,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.network(
                        reporter.imageUrl,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.0, -0.15),
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColorTokens.cinematicCard,
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white24,
                              size: 90.w,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColorTokens.cinematicCard,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white24,
                          size: 90.w,
                        ),
                      ),
                    ),

                  // Top gradient vignette for status bar and top bar legibility
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom smooth gradient transition into solid dark background
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 150.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColorTokens.cinematicBackground.withValues(alpha: 0.65),
                            AppColorTokens.cinematicBackground,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Top-Right Wave Ripple Art (from live_tv_screen.dart & polls)
            Positioned(
              top: 0,
              right: 0,
              width: screenWidth,
              height: 380.h,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: TopRightWavePainter(
                    isDark: true,
                    waveAnimation: _waveAnimation,
                  ),
                ),
              ),
            ),

            // 3. Foreground Content (Top Bar + Bottom Content Area)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Bar (Back button + Share button)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    padding: EdgeInsets.all(7.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    Share.share(
                                        'Connect with reporter ${reporter.name} (${reporter.title}) on BIG TV!');
                                    AnalyticsService.instance.track(
                                        AnalyticsEventName.reporterShare,
                                        properties: {
                                          'reporter_id': reporter.id,
                                        });
                                  },
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    padding: EdgeInsets.all(7.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.share_rounded,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Details Area (Floating directly over background, no outer card box)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Name, Title, Location & Follow button
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reporter.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black87,
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            reporter.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: const Color(0xFFD1D5DB),
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w500,
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black87,
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 13.sp,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: Text(
                                                  reporter.fullLocation,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12.sp,
                                                    shadows: const [
                                                      Shadow(
                                                        color: Colors.black87,
                                                        blurRadius: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    // Follow Button
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _isFollowing = !_isFollowing;
                                        });
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setBool('reporter_following_${reporter.id}', _isFollowing);
                                        if (_isFollowing) {
                                          AnalyticsService.instance.track(AnalyticsEventName.reporterFollow, properties: {
                                            'reporter_id': reporter.id,
                                          });
                                        } else {
                                          AnalyticsService.instance.track(AnalyticsEventName.reporterUnfollow, properties: {
                                            'reporter_id': reporter.id,
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: _isFollowing
                                              ? AppColorTokens.cinematicBackground
                                              : AppColorTokens.cinemaRed,
                                          borderRadius: BorderRadius.circular(16.r),
                                          border: Border.all(
                                            color: _isFollowing
                                                ? AppColorTokens.cinematicBorder
                                                : AppColorTokens.cinemaRed,
                                          ),
                                          boxShadow: [
                                            if (!_isFollowing)
                                              BoxShadow(
                                                color: AppColorTokens.cinemaRed.withValues(alpha: 0.35),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: Text(
                                          _isFollowing
                                              ? (isMalayalam ? 'ഫോളോ ചെയ്യുന്നു' : (isTelugu ? 'ఫాలోయింగ్' : 'Following'))
                                              : (isMalayalam ? 'ഫോളോ ചെയ്യുക' : (isTelugu ? 'ఫాలో' : 'Follow')),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8.h),

                                // Category Badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
                                  decoration: BoxDecoration(
                                    color: AppColorTokens.cinemaRed.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColorTokens.cinemaRed.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    reporter.category,
                                    style: TextStyle(
                                      color: const Color(0xFFFF6B6B),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                // 2. About section
                                if (reporter.about.trim().isNotEmpty) ...[
                                  SizedBox(height: 9.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
                                    decoration: BoxDecoration(
                                      color: AppColorTokens.cinematicSurface.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: AppColorTokens.cinematicBorder.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isMalayalam ? 'വിവരം' : (isTelugu ? 'గురించి' : 'About'),
                                          style: TextStyle(
                                            color: AppColorTokens.cinemaRed,
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          reporter.about,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: const Color(0xFFE5E7EB),
                                            fontSize: 12.sp,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                SizedBox(height: 9.h),

                                // 3. Contact Rows (Poll-option style tiles)
                                _buildCompactContactRow(
                                  icon: Icons.phone_outlined,
                                  label: isMalayalam ? 'ഫോൺ' : (isTelugu ? 'ఫోన్' : 'Phone'),
                                  value: reporter.phone,
                                  onTap: () => _makePhoneCall(reporter.phone),
                                ),
                                SizedBox(height: 6.h),
                                _buildCompactContactRow(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: reporter.email,
                                  onTap: null,
                                ),
                                SizedBox(height: 6.h),
                                _buildCompactContactRow(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: 'WhatsApp',
                                  value: reporter.whatsapp,
                                  onTap: () => _openWhatsApp(reporter.whatsapp),
                                ),

                                SizedBox(height: 12.h),

                                // 4. Action Buttons (Call Reporter & WhatsApp)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _makePhoneCall(reporter.phone),
                                        icon: Icon(Icons.phone, size: 16.w, color: Colors.white),
                                        label: Text(
                                          isMalayalam ? 'വിളിക്കുക' : (isTelugu ? 'కాల్ చేయండి' : 'Call reporter'),
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColorTokens.cinemaRed,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(vertical: 10.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openWhatsApp(reporter.whatsapp),
                                        icon: Icon(
                                          Icons.chat_outlined,
                                          size: 16.w,
                                          color: AppColorTokens.cinemaRed,
                                        ),
                                        label: Text(
                                          'WhatsApp',
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColorTokens.cinemaRed,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColorTokens.cinemaRed, width: 1.5),
                                          padding: EdgeInsets.symmetric(vertical: 10.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8.h),

                                // Subtext Note
                                Center(
                                  child: Text(
                                    isMalayalam
                                        ? 'വാർത്താ വിവരങ്ങൾക്കും അന്വേഷణങ്ങൾക്കും.'
                                        : (isTelugu ? 'వార్తల సమాచారం మరియు విచారణల కోసం.' : 'For news tips and story enquiries.'),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white54,
                                    ),
                                  ),
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
    );
  }

  Widget _buildCompactContactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColorTokens.cinematicSurface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColorTokens.cinematicBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15.sp, color: AppColorTokens.cinemaRed),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11.sp,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11.sp,
                color: Colors.white38,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
