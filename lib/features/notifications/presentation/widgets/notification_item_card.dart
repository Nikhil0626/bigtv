import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/app_notification_model.dart';

class NotificationItemCard extends StatelessWidget {
  final AppNotificationModel notification;
  final bool isTelugu;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.isTelugu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final contentColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final timeColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final String imageUrl = notification.displayImageUrl;
    final bool hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Top Header Row: Brand Pill & Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: const Color(0xFFFECACA),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.w,
                            height: 5.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            (notification.brandName?.isNotEmpty ?? false)
                                ? notification.brandName!
                                : "BIG TV",
                            style: TextStyle(
                              color: const Color(0xFFDC2626),
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timestamp
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11.sp,
                          color: timeColor,
                        ),
                        SizedBox(width: 3.5.w),
                        Text(
                          notification.getTimeAgo(isTelugu: isTelugu),
                          style: TextStyle(
                            color: timeColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 9.h),

                // 2. Middle Row: Text info & Image thumbnail
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Column (Title & Excerpt)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              letterSpacing: -0.1,
                            ),
                          ),
                          if (notification.content.isNotEmpty) ...[
                            SizedBox(height: 5.h),
                            Text(
                              notification.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: contentColor,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Image Thumbnail
                    if (hasImage) ...[
                      SizedBox(width: 10.w),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          color: const Color(0xFFF1F5F9),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: const Color(0xFFE2E8F0),
                              highlightColor: const Color(0xFFF8FAFC),
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: Center(
                                child: Icon(
                                  Icons.newspaper_rounded,
                                  color: const Color(0xFF94A3B8),
                                  size: 26.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 10.h),

                // 3. Footer: Post ID Badge & Read Full Story CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (notification.postId != null && notification.postId != 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: borderColor,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          "#${notification.postId}",
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTelugu ? "పూర్తి వార్త చదవండి" : "പൂർണ്ണ വാർത്ത വായിക്കുക",
                          style: TextStyle(
                            color: AppColorTokens.primaryRed,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13.sp,
                          color: AppColorTokens.primaryRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
