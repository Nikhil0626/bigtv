import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../aggricator_screens/chota_info_screens/privacy_policy.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../globel_keys/global_variables_data.dart';
import '../../../../services/base_urls.dart';
import '../../../../utils/app_toasts.dart';

class ShowAlertsWidget extends StatefulWidget {
  final Map<String, dynamic>? articleData;

  const ShowAlertsWidget({
    super.key,
    this.articleData,
  });

  @override
  State<ShowAlertsWidget> createState() => _ShowAlertsWidgetState();
}

class _ShowAlertsWidgetState extends State<ShowAlertsWidget> {
  int _selectedRemindOption = 0;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _agreeToTerms = true;
  bool _isSubmitted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.articleData?['email_address']?.toString() ??
        widget.articleData?['emailAddress']?.toString() ??
        widget.articleData?['email']?.toString() ??
        '';
    final initialPhone = widget.articleData?['number']?.toString() ??
        widget.articleData?['whatsappNumber']?.toString() ??
        widget.articleData?['phone']?.toString() ??
        '';

    _emailController = TextEditingController(text: initialEmail);
    _phoneController = TextEditingController(text: initialPhone.replaceAll('+91', '').trim());
    _agreeToTerms = (widget.articleData?['receive_alert'] as bool?) ??
        (widget.articleData?['receiveAlert'] as bool?) ??
        true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitAlerts() async {
    if (_isLoading) return;

    if (!_agreeToTerms) {
      CustomToast.showWarningToast(
        msg: "Please agree to receive alerts and terms.",
      );
      return;
    }

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty && phone.isEmpty) {
      CustomToast.showWarningToast(
        msg: "Please enter your email or WhatsApp number.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId') ?? GlobalVariables().deviceId ?? '12345';
      final userId = prefs.getString('userId') ?? prefs.getString('user_id') ?? 'string';

      final rawPostId = widget.articleData?['id'] ?? widget.articleData?['post_id'] ?? 0;
      final postId = int.tryParse(rawPostId.toString()) ?? 0;

      final showTitle = widget.articleData?['title']?.toString() ??
          widget.articleData?['notificationtitle']?.toString() ??
          widget.articleData?['show_title']?.toString() ??
          'DNA';

      final options = _getReminderOptions();
      final selectedOptionText = _selectedRemindOption < options.length
          ? options[_selectedRemindOption]
          : "15 min before";

      final bodyMap = {
        "post_id": postId,
        "show_title": showTitle,
        "email": email,
        "number": phone,
        "receive_alert": _agreeToTerms,
        "remind_timing": selectedOptionText,
        "user_id": userId.isEmpty ? "string" : userId,
        "device_id": deviceId.isEmpty ? "12345" : deviceId,
      };

      debugPrint("Subscribing to show alert API payload: ${jsonEncode(bodyMap)}");

      final response = await http.post(
        Uri.parse("${BaseUrls.baseUrlAwsDev}${BaseUrls.showAlertSubscribeApi}"),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      );

      debugPrint("Show alert API response code: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResp = jsonDecode(response.body);
        final msg = jsonResp['message']?.toString() ?? "Successfully subscribed to show alerts!";

        setState(() {
          _isSubmitted = true;
          _isLoading = false;
        });

        CustomToast.showSuccessToast(
          title: "Subscribed!",
          msg: msg,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        CustomToast.showErrorToast(
          msg: "Failed to subscribe (Code: ${response.statusCode}).",
        );
      }
    } catch (e) {
      debugPrint("Error subscribing to show alert: $e");
      setState(() {
        _isLoading = false;
      });
      CustomToast.showErrorToast(
        msg: "Error connecting to server. Please try again.",
      );
    }
  }

  Future<void> _openLiveVideo() async {
    final videoUrl = widget.articleData?['video_url']?.toString() ??
        widget.articleData?['videoUrl']?.toString() ??
        "https://www.youtube.com/@BigTVLive";

    final Uri uri = Uri.parse(videoUrl.isEmpty ? "https://www.youtube.com/@BigTVLive" : videoUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error opening video URL: $e");
    }
  }

  String _getImageUrl(dynamic raw) {
    if (raw == null) return '';
    if (raw is List) {
      if (raw.isEmpty) return '';
      return _getImageUrl(raw.first);
    }
    String url = raw.toString().trim();
    if (url.isEmpty || url == 'null' || url == '[]') return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return "https://migwp.chotanews.com$url";
    }
    return "https://migwp.chotanews.com/$url";
  }

  List<String> _getReminderOptions() {
    final rawOptions = widget.articleData?['reminder_options'] ?? widget.articleData?['reminderOptions'];
    if (rawOptions is List && rawOptions.isNotEmpty) {
      return rawOptions.map((e) => e.toString()).toList();
    }
    return ['15 min before', 'When it starts'];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryRed = AppColorTokens.primaryRed;

    final title = widget.articleData?['title']?.toString() ??
        widget.articleData?['notificationtitle']?.toString() ??
        'Start your day with Suprabhatam';
    final content = widget.articleData?['content']?.toString() ??
        widget.articleData?['description']?.toString() ??
        'Get a reminder and a direct link when the show starts.';
    final showTag = widget.articleData?['show_tag']?.toString() ??
        widget.articleData?['showTag']?.toString() ??
        'MORNING SHOW';
    final showTime = widget.articleData?['show_time']?.toString() ??
        widget.articleData?['showTime']?.toString() ??
        '7:00 AM IST';
    final showDay = widget.articleData?['show_day']?.toString() ??
        widget.articleData?['showDay']?.toString() ??
        widget.articleData?['showDays']?.toString() ??
        'Mon–Sat';
    final rawBanner = widget.articleData?['image_url'] ??
        widget.articleData?['imageUrl'] ??
        widget.articleData?['banner_url'] ??
        widget.articleData?['image'];
    final bannerImageUrl = _getImageUrl(rawBanner);
    final videoPlatform = widget.articleData?['video_platform']?.toString() ??
        widget.articleData?['videoPlatform']?.toString() ??
        'YouTube';

    final reminderOptions = _getReminderOptions();

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF121212) : Colors.white,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (isKeyboardOpen) {
                    // Prevent scroll notifications from bubbling up to parent PageView when keyboard is open
                    return true;
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: isKeyboardOpen
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. Banner Graphic
                            Container(
                              width: double.infinity,
                              height: 145.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.red.shade900.withValues(alpha: 0.4)
                                      : primaryRed.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (bannerImageUrl.isNotEmpty)
                                      CachedNetworkImage(
                                        imageUrl: bannerImageUrl,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => Container(
                                          color: isDark ? Colors.grey.shade900 : const Color(0xFFF1F5F9),
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Image.network(
                                          bannerImageUrl,
                                          fit: BoxFit.fill,
                                          errorBuilder: (_, __, ___) => Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isDark
                                                    ? [const Color(0xFF2C1E1E), const Color(0xFF1A1A1A)]
                                                    : [const Color(0xFFFFF0EA), const Color(0xFFFFFDFD)],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDark
                                                ? [const Color(0xFF2C1E1E), const Color(0xFF1A1A1A)]
                                                : [const Color(0xFFFFF0EA), const Color(0xFFFFFDFD)],
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  Colors.black.withValues(alpha: 0.85),
                                                  Colors.black.withValues(alpha: 0.5),
                                                  Colors.black.withValues(alpha: 0.1),
                                                ]
                                              : [
                                                  Colors.white.withValues(alpha: 0.9),
                                                  Colors.white.withValues(alpha: 0.55),
                                                  Colors.white.withValues(alpha: 0.1),
                                                ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (showTag.isNotEmpty) ...[
                                            Text(
                                              showTag.toUpperCase(),
                                              style: TextStyle(
                                                color: primaryRed,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                            SizedBox(height: 3.h),
                                          ],
                                          Text(
                                            title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w900,
                                              height: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                color: primaryRed,
                                                size: 13.w,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                showDay,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                                child: Text(
                                                  '|',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.access_time_rounded,
                                                color: primaryRed,
                                                size: 13.w,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                showTime,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                                              fontSize: 11.sp,
                                              height: 1.2,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // 2. Remind header
                            Text(
                              'When should we remind you?',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            // 3. Timing choice buttons
                            Row(
                              children: List.generate(reminderOptions.length, (idx) {
                                final opt = reminderOptions[idx];
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: idx < reminderOptions.length - 1 ? 10.w : 0),
                                    child: _buildTimingOption(
                                      title: opt,
                                      isSelected: _selectedRemindOption == idx,
                                      onTap: () => setState(() => _selectedRemindOption = idx),
                                      isDark: isDark,
                                      primaryRed: primaryRed,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 8.h),

                            // 4. Email address
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email address',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isDark ? Colors.grey.shade700 : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'you@example.com',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13.sp,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                        color: Colors.grey.shade500,
                                        size: 18.w,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // 5. WhatsApp number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WhatsApp number',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isDark ? Colors.grey.shade700 : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10.w),
                                      Container(
                                        padding: EdgeInsets.all(3.w),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF25D366),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.chat_bubble,
                                          color: Colors.white,
                                          size: 12.w,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '+91',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                                        height: 18.h,
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter mobile number',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 13.sp,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // 6. Checkbox & Terms
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    activeColor: primaryRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    onChanged: (val) {
                                      setState(() => _agreeToTerms = val ?? false);
                                    },
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _agreeToTerms = !_agreeToTerms);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Send me $title alerts by email and WhatsApp. I agree to the ',
                                        style: TextStyle(
                                          color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                                          fontSize: 11.sp,
                                          height: 1.2,
                                        ),
                                        children: [
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const PrivacyPolicy(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Privacy Notice',
                                                style: TextStyle(
                                                  color: isDark ? Colors.grey.shade300 : const Color(0xFF1E293B),
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // 7. Action buttons
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 42.h,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _submitAlerts,
                                    icon: _isLoading
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.w,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            _isSubmitted
                                                ? Icons.check_circle_outline
                                                : Icons.notifications_none_rounded,
                                            color: Colors.white,
                                            size: 18.w,
                                          ),
                                    label: Text(
                                      _isLoading
                                          ? 'Subscribing...'
                                          : (_isSubmitted ? 'Alerts Set!' : 'Get show alerts'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isSubmitted ? const Color(0xFF2E7D32) : primaryRed,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'You can unsubscribe anytime.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 42.h,
                                  child: OutlinedButton(
                                    onPressed: _openLiveVideo,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isDark ? const Color(0xFF2A1C1C) : const Color(0xFFFFF0F0),
                                      side: BorderSide(color: primaryRed, width: 1.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(3.r),
                                          ),
                                          child: Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 12.w,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Watch live on $videoPlatform',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimingOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryRed,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFDE8E8))
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? primaryRed
                : (isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.red.shade200 : primaryRed)
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 10.w,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
