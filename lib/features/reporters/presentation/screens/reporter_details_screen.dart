import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/models/reporter_model.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';

class ReporterDetailsScreen extends StatefulWidget {
  final ReporterModel reporter;

  const ReporterDetailsScreen({
    super.key,
    required this.reporter,
  });

  @override
  State<ReporterDetailsScreen> createState() => _ReporterDetailsScreenState();
}

class _ReporterDetailsScreenState extends State<ReporterDetailsScreen> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
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
    final primaryColor = context.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeProvider = context.watch<HomeProvider>();
    final isMalayalam = homeProvider.langCode == 'ml';
    final isTelugu = homeProvider.langCode == 'te' || (!isMalayalam && !homeProvider.isEnglishMode);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 20),
            onPressed: () {
              Share.share('Connect with reporter ${reporter.name} (${reporter.title}) on BIG TV!');
              AnalyticsService.instance.track(AnalyticsEventName.reporterShare, properties: {
                'reporter_id': reporter.id,
              });
            },
          ),
        ],
        title: Text(
          isMalayalam ? 'റിപ്പോർട്ടർ വിവരങ്ങൾ' : (isTelugu ? 'రిపోర్టర్ వివరాలు' : 'Reporter details'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Card 1: Header / Profile Summary
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? context.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? context.borderColor : const Color(0xFFEEEEEE),
                  width: 1,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: reporter.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: reporter.imageUrl,
                            width: 90.w,
                            height: 90.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 90.w,
                              height: 90.w,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.network(
                              reporter.imageUrl,
                              width: 90.w,
                              height: 90.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 90.w,
                                height: 90.w,
                                color: Colors.grey.shade300,
                                child: Icon(Icons.person, color: Colors.grey.shade600, size: 40.w),
                              ),
                            ),
                          )
                        : Container(
                            width: 90.w,
                            height: 90.w,
                            color: Colors.grey.shade300,
                            child: Icon(Icons.person, color: Colors.grey.shade600, size: 40.w),
                          ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporter.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: context.typography.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          reporter.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          reporter.fullLocation,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Text(
                                reporter.category,
                                style: TextStyle(
                                  color: const Color(0xFFD32F2F),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
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
                              borderRadius: BorderRadius.circular(14.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: _isFollowing ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300) : primaryColor,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Text(
                                  _isFollowing
                                      ? (isMalayalam ? 'ഫോളോ ചെയ്യുന്നു' : (isTelugu ? 'ఫాలోయింగ్' : 'Following'))
                                      : (isMalayalam ? 'ഫോളോ ചെയ്യുക' : (isTelugu ? 'ఫాలో' : 'Follow')),
                                  style: TextStyle(
                                    color: _isFollowing ? (isDark ? Colors.white70 : Colors.black87) : Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Card 2: About
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? context.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? context.borderColor : const Color(0xFFEEEEEE),
                  width: 1,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMalayalam ? 'വിവരം' : (isTelugu ? 'గురించి' : 'About'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.typography.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    reporter.about,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: isDark ? Colors.grey.shade300 : const Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Card 3: Contact Details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? context.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? context.borderColor : const Color(0xFFEEEEEE),
                  width: 1,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMalayalam ? 'ബന്ധപ്പെടാനുള്ള വിവരങ്ങൾ' : (isTelugu ? 'సంప్రదింపు వివరాలు' : 'Contact details'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.typography.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Phone Row
                  _buildContactRow(
                    context,
                    icon: Icons.phone_outlined,
                    label: isMalayalam ? 'ഫോൺ' : (isTelugu ? 'ఫోన్' : 'Phone'),
                    value: reporter.phone,
                  ),
                  SizedBox(height: 14.h),

                  // Email Row
                  _buildContactRow(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: reporter.email,
                  ),
                  SizedBox(height: 14.h),

                  // WhatsApp Row
                  _buildContactRow(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'WhatsApp',
                    value: reporter.whatsapp,
                  ),

                  SizedBox(height: 20.h),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Call Reporter Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(reporter.phone),
                          icon: Icon(Icons.phone, size: 18.w, color: Colors.white),
                          label: Text(
                            isMalayalam ? 'വിളിക്കുക' : (isTelugu ? 'కాల్ చేయండి' : 'Call reporter'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // WhatsApp Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openWhatsApp(reporter.whatsapp),
                          icon: Icon(
                            Icons.chat_outlined,
                            size: 18.w,
                            color: primaryColor,
                          ),
                          label: Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Subtext Note
                  Center(
                    child: Text(
                      isMalayalam
                          ? 'വാർത്താ വിവരങ്ങൾക്കും അന്വേഷണങ്ങൾക്കും.'
                          : (isTelugu ? 'వార్తల సమాచారం మరియు విచారణల కోసం.' : 'For news tips and story enquiries.'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
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
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20.w,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
        SizedBox(width: 16.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF4A4A4A),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.typography.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}
