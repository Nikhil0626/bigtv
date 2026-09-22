import 'dart:developer';

import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/webengage_event_tracks.dart';
import '../../utils/app_spaces.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Future<void> launchSingleEmail(String email) async {
    contactViaMail();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      log('Error launching email: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    contactViaCall();
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        log('Could not launch phone: $phone');
      }
    } catch (e) {
      log('Error launching phone: $e');
    }
  }

  @override
  void initState() {
    context.read<AuthenticationProvider>().sendEvent("ContactPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFC),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: TopRightWavePainter(isDark: isDark),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  buildSettingsPageHeader(context, "Contact Us"),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Container(
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E4EA),
                            width: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Bigtv News",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 3,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFED1C24),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            height(height: 20),
                            Text(
                              "Contact Details",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            height(height: 16),
                            Text(
                              "Address",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF475569),
                              ),
                            ),
                            height(height: 6),
                            Text(
                              "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF64748B),
                              ),
                            ),
                            height(height: 16),
                            InkWell(
                              onTap: () => _launchPhone("+91 81210 31061"),
                              child: Row(
                                children: [
                                  Icon(Icons.phone_outlined, size: 18.sp, color: const Color(0xFFED1C24)),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Phone: ",
                                          style: TextStyle(fontSize: 14.sp, color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF334155)),
                                        ),
                                        TextSpan(
                                          text: "+91 81210 31061",
                                          style: TextStyle(fontSize: 14.sp, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            height(height: 16),
                            Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF475569),
                              ),
                            ),
                            height(height: 6),
                            InkWell(
                              onTap: () => launchSingleEmail("Info@bigtvlive.com"),
                              child: Row(
                                children: [
                                  Icon(Icons.email_outlined, size: 18.sp, color: const Color(0xFFED1C24)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Info@bigtvlive.com",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
    );
  }
}
