import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_spaces.dart';

class AdvertiseWithUs extends StatefulWidget {
  const AdvertiseWithUs({super.key});

  @override
  State<AdvertiseWithUs> createState() => _AdvertiseWithUsState();
}

class _AdvertiseWithUsState extends State<AdvertiseWithUs> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().sendEvent("AdvertisePage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: TopRightWavePainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  buildSettingsPageHeader(context, "Advertise With Us"),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Container(
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
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
                                      color: const Color(0xFF1E293B),
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
                            height(height: 16),
                            Text(
                              "Bigtv News is a first of its kind unique mobile media company in the country. We produce & distribute “Made for Mobile Content” to Indian local language audience. Like TV media & Print media, we are building a technology-based mobile media company with short news and other rich content in local languages.",
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: const Color(0xFF334155),
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            height(height: 24),
                            Text(
                              "Get In Touch",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            height(height: 12),
                            Text(
                              "For Advertising / partnership enquiries, please write to:",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            height(height: 6),
                            InkWell(
                              onTap: () => _launchEmail("Poojithaagoor@bigtvlive.com"),
                              child: Row(
                                children: [
                                  Icon(Icons.email_outlined, size: 18.sp, color: const Color(0xFFED1C24)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Poojithaagoor@bigtvlive.com",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF0284C7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            height(height: 20),
                            Text(
                              "Address",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            height(height: 6),
                            Text(
                              "Pravasa Media LLP\nDwaraka Trident, 4th Floor\nKavuri Hills, JubileeHills, Hyderabad,\nTelangana 500033",
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            height(height: 14),
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
                                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF334155)),
                                        ),
                                        TextSpan(
                                          text: "+91 81210 31061",
                                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0284C7), fontWeight: FontWeight.w600),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
