import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class _TopRightWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.95, -size.height * 0.05);

    // Rich background radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFBDBD).withValues(alpha: 0.95),
          const Color(0xFFFFDEDE).withValues(alpha: 0.75),
          const Color(0xFFFFF0F0).withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 340));
    canvas.drawCircle(center, 340, glowPaint);

    // Prominent concentric wave ripple lines
    final radii = [50.0, 85.0, 120.0, 160.0, 205.0, 255.0, 310.0, 370.0];
    final opacities = [0.45, 0.38, 0.30, 0.24, 0.18, 0.13, 0.08, 0.04];

    for (int i = 0; i < radii.length; i++) {
      final linePaint = Paint()
        ..color = const Color(0xFFED1C24).withValues(alpha: opacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      canvas.drawCircle(center, radii[i], linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  FeedbackFormState createState() => FeedbackFormState();
}

class FeedbackFormState extends State<FeedbackForm> {
  int _selectedRating = 4;
  final TextEditingController _feedbackTextController = TextEditingController();
  final Set<String> _selectedOptions = {'UI & navigation', 'Content quality'};

  final List<Map<String, dynamic>> _defaultOptions = [
    {'title': 'Local news', 'icon': Icons.location_on_outlined},
    {'title': 'News categories', 'icon': Icons.grid_view_rounded},
    {'title': 'News coverage', 'icon': Icons.language_rounded},
    {'title': 'UI & navigation', 'icon': Icons.explore_outlined},
    {'title': 'Videos & media', 'icon': Icons.videocam_outlined},
    {'title': 'Content quality', 'icon': Icons.description_outlined},
    {'title': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return '1 out of 5 · Poor';
      case 2:
        return '2 out of 5 · Fair';
      case 3:
        return '3 out of 5 · Average';
      case 4:
        return '4 out of 5 · Good';
      case 5:
        return '5 out of 5 · Excellent';
      default:
        return 'Tap a star to rate';
    }
  }

  IconData _getIconForOption(String title) {
    final t = title.toLowerCase();
    if (t.contains('local')) return Icons.location_on_outlined;
    if (t.contains('categor')) return Icons.grid_view_rounded;
    if (t.contains('coverage') || t.contains('national') || t.contains('global')) return Icons.language_rounded;
    if (t.contains('ui') || t.contains('navigation') || t.contains('design')) return Icons.explore_outlined;
    if (t.contains('video') || t.contains('media') || t.contains('audio')) return Icons.videocam_outlined;
    if (t.contains('content') || t.contains('quality') || t.contains('article')) return Icons.description_outlined;
    if (t.contains('other')) return Icons.more_horiz_rounded;
    return Icons.chat_bubble_outline_rounded;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      settings.feedbackList = [];
      settings.selectedFeedbackList.clear();
      settings.selectedFeedbackList.addAll(_selectedOptions);
      settings.getFeedBack().then((_) {
        if (mounted && settings.feedbackList.isNotEmpty) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _feedbackTextController.dispose();
    super.dispose();
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
    final settings = context.read<SettingsProvider>();
    settings.selectedFeedbackList = _selectedOptions.toList();
  }

  void _submitFeedback() {
    if (_selectedRating <= 0) {
      CustomToast.showErrorToast(msg: "Please rate your experience with stars");
      return;
    }

    final settings = context.read<SettingsProvider>();
    settings.feedbackController.text = _feedbackTextController.text.trim();
    settings.selectedFeedbackList = _selectedOptions.toList();

    settings.postFeedBack(_selectedRating).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    List<Map<String, dynamic>> optionsToDisplay = [];
    if (settingsProvider.feedbackList.isNotEmpty) {
      for (var item in settingsProvider.feedbackList) {
        final text = item['optionText']?.toString() ?? '';
        optionsToDisplay.add({
          'title': text,
          'icon': _getIconForOption(text),
          'id': item['optionId'],
        });
      }
    } else {
      optionsToDisplay = _defaultOptions;
    }

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
            child: CustomPaint(
              painter: _TopRightWavePainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Compact Top App Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0F0F3),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 24,
                              color: Color(0xFF1E2022),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Feedback",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191C1F),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 34.w),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HERO SECTION
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: "Your voice\n",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF181A20),
                                        height: 1.15,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: "matters.",
                                          style: TextStyle(
                                            color: Color(0xFFED1C24),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Help us make BIGTV better.",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6C7278),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Compact badge with heart chat bubble
                            Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 38,
                                      color: Color(0xFFED1C24),
                                    ),
                                    Positioned(
                                      top: 11,
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        size: 15,
                                        color: Color(0xFFED1C24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // CARD 1: "How was your experience?" + Stars
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFEFEFF4), width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "How was your experience?",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF181A20),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "Rate your experience with BIGTV",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF7A7E85),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  final starIndex = index + 1;
                                  final isFilled = starIndex <= _selectedRating;
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _selectedRating = starIndex;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      child: Icon(
                                        isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                        color: isFilled ? const Color(0xFFED1C24) : const Color(0xFF9EA3AE),
                                        size: 32.sp,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                _getRatingLabel(_selectedRating),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF555B66),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // SECTION 2: "What can we improve?" + Chips Grid
                        Text(
                          "What can we improve?",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF181A20),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Select all that apply",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7A7E85),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // 2-Column Grid for options (Compact)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: optionsToDisplay.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 8.h,
                            childAspectRatio: 3.1,
                          ),
                          itemBuilder: (context, index) {
                            final option = optionsToDisplay[index];
                            final title = option['title'] as String;
                            final icon = option['icon'] as IconData;
                            final isSelected = _selectedOptions.contains(title);

                            return GestureDetector(
                              onTap: () => _toggleOption(title),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFFF7F7) : Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFED1C24) : const Color(0xFFE2E4EA),
                                    width: isSelected ? 1.3 : 0.9,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 17.sp,
                                      color: isSelected ? const Color(0xFFED1C24) : const Color(0xFF2A2D34),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? const Color(0xFFED1C24) : const Color(0xFF1E2022),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      SizedBox(width: 3.w),
                                      Container(
                                        width: 15.w,
                                        height: 15.w,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFED1C24),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 9.5.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 16.h),

                        // SECTION 3: "Anything else? (optional)" + Input
                        RichText(
                          text: TextSpan(
                            text: "Anything else? ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF181A20),
                            ),
                            children: [
                              TextSpan(
                                text: "(optional)",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF7A7E85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE2E4EA), width: 0.9),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextField(
                                controller: _feedbackTextController,
                                maxLength: 500,
                                maxLines: 2,
                                minLines: 2,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.sp,
                                  color: const Color(0xFF1E2022),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: "Tell us a little more...",
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.sp,
                                    color: const Color(0xFF9EA3AE),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  counterText: "",
                                ),
                              ),
                              Text(
                                "${_feedbackTextController.text.length}/500",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.sp,
                                  color: const Color(0xFF9EA3AE),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.h),

                        // SECTION 4: Submit Button & Footer
                        GestureDetector(
                          onTap: settingsProvider.isFeedbackLoading ? null : _submitFeedback,
                          child: Container(
                            width: double.infinity,
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFED1C24),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFED1C24).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: settingsProvider.isFeedbackLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Submit feedback",
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
                                          size: 17.sp,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            "Thanks for helping us improve.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7A7E85),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
