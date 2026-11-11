import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact, theme-aware WhatsApp quick-share and general share action buttons
/// reused across full-screen content cards such as Movie Reviews and Polls.
class ContentShareButtons extends StatelessWidget {
  final VoidCallback onShareWhatsApp;
  final VoidCallback onShareMore;
  final bool useDarkOverlay;
  final Key? whatsAppButtonKey;
  final Key? shareButtonKey;

  const ContentShareButtons({
    super.key,
    required this.onShareWhatsApp,
    required this.onShareMore,
    this.useDarkOverlay = true,
    this.whatsAppButtonKey,
    this.shareButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = useDarkOverlay || Theme.of(context).brightness == Brightness.dark;
    final Color surfaceColor = isDark
        ? AppColorTokens.cinematicSurface.withValues(alpha: 0.9)
        : AppColorTokens.lightSurface;
    final Color borderColor = isDark
        ? AppColorTokens.darkTextPrimary.withValues(alpha: 0.22)
        : AppColorTokens.lightBorder;
    final Color iconColor =
        isDark ? AppColorTokens.darkTextPrimary : AppColorTokens.primaryRed;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Share on WhatsApp',
          child: Semantics(
            button: true,
            label: 'Share on WhatsApp',
            child: InkWell(
              key: whatsAppButtonKey,
              onTap: onShareWhatsApp,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: 32.r,
                height: 32.r,
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Image.asset(
                  'assets/images/WhatsApp_icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColorTokens.success,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Tooltip(
          message: 'Share',
          child: Semantics(
            button: true,
            label: 'Share',
            child: InkWell(
              key: shareButtonKey,
              onTap: onShareMore,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: 32.r,
                height: 32.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: iconColor,
                  size: 17.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

