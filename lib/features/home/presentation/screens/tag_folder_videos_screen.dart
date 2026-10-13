import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/home/presentation/screens/tag_video_player_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

class TagFolderVideosScreen extends StatefulWidget {
  final String tagTitle;
  final String folderName;
  final String displayFolderName;
  final List videos;
  final String? tagThumbnailUrl;

  const TagFolderVideosScreen({
    super.key,
    required this.tagTitle,
    required this.folderName,
    required this.displayFolderName,
    required this.videos,
    this.tagThumbnailUrl,
  });

  @override
  State<TagFolderVideosScreen> createState() => _TagFolderVideosScreenState();
}

class _TagFolderVideosScreenState extends State<TagFolderVideosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String get tagTitle => widget.tagTitle;
  String get folderName => widget.folderName;
  String get displayFolderName => widget.displayFolderName;
  List get videos => widget.videos;
  String? get tagThumbnailUrl => widget.tagThumbnailUrl;

  String _cleanFileName(String name) {
    if (name.isEmpty) return "Video Show";
    return name.replaceAll(RegExp(r'\.(mp4|mov|mkv|avi|webm)$', caseSensitive: false), '').trim();
  }

  String _getThumbnailUrl(Map<String, dynamic> item) {
    final rawThumbnail = item['thumbnailUrl'] ??
        item['thumbnail_url'] ??
        item['thumbnail'] ??
        item['thumb'] ??
        item['posterUrl'] ??
        item['poster_url'] ??
        item['poster'] ??
        item['imageUrl'] ??
        item['image_url'] ??
        item['image'] ??
        item['coverUrl'] ??
        item['cover'];

    if (rawThumbnail != null && rawThumbnail.toString().trim().isNotEmpty) {
      return rawThumbnail.toString().trim();
    }

    final videoUrl = (item['url'] ?? item['videoUrl'] ?? item['video_url'] ?? '').toString().trim();
    if (videoUrl.isNotEmpty) {
      try {
        final ytId = YoutubePlayer.convertUrlToId(videoUrl);
        if (ytId != null && ytId.isNotEmpty) {
          return "https://img.youtube.com/vi/$ytId/hqdefault.jpg";
        }
      } catch (_) {}
    }

    if (tagThumbnailUrl != null && tagThumbnailUrl!.trim().isNotEmpty) {
      return tagThumbnailUrl!.trim();
    }

    return "";
  }

  int _getViewCount(Map<String, dynamic>? item) {
    if (item == null) return 0;
    final raw = item['viewCount'] ??
        item['view_count'] ??
        item['viewsCount'] ??
        item['views_count'] ??
        item['views'] ??
        item['view_cnt'] ??
        0;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return "$count";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF181A20);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F12) : const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: AppColorTokens.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tagTitle,
          style: TextStyle(
            fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF180A0D),
                          const Color(0xFF0F0F12),
                          const Color(0xFF13090B),
                        ]
                      : [
                          const Color(0xFFFFF2F4),
                          const Color(0xFFFBFBFC),
                          const Color(0xFFFFF6F7),
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Self-moving wave ripple animation
          Positioned(
            top: 0,
            right: 0,
            width: MediaQuery.of(context).size.width,
            height: 480.h,
            child: CustomPaint(
              painter: TopRightWavePainter(
                isDark: isDark,
                maxRadius: 460.0,
                waveAnimation: _waveController,
              ),
            ),
          ),
          videos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppNoData(),
                      const SizedBox(height: 12),
                      Text(
                        "No videos found in $displayFolderName",
                        style: TextStyle(fontSize: 14.sp, color: subTextColor),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Top Banner Section (Redesigned, sleek & balanced)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(18.w, 10.h, 12.w, 8.h),
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Content Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Red mini capsule tag
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: AppColorTokens.primaryRed.withValues(alpha: isDark ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColorTokens.primaryRed.withValues(alpha: 0.3),
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
                                          shape: BoxShape.circle,
                                          color: Color(0xFFED1C24),
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        "PLAYLIST",
                                        style: TextStyle(
                                          color: const Color(0xFFED1C24),
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.h),

                                // Headline - Telugu & Folder Name
                                Text(
                                  tagTitle,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (displayFolderName.isNotEmpty && displayFolderName != tagTitle) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    displayFolderName,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFED1C24),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                SizedBox(height: 6.h),

                                // Stats Chip
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.video_library_rounded, size: 12.sp, color: subTextColor),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "${videos.length} ${videos.length == 1 ? 'Video' : 'Videos'}",
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: subTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Right side Animated 3D Illustration
                          AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              final progress = _waveController.value * 2 * math.pi;
                              final floatY = -5.0 * math.sin(progress);
                              final tiltAngle = 0.035 * math.cos(progress);
                              final scale = 1.0 + 0.025 * math.sin(progress);
                              final shadowSpread = 1.0 - 0.2 * ((math.sin(progress) + 1) / 2);

                              return SizedBox(
                                width: 100.w,
                                height: 90.h,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Soft Dynamic Floor Shadow
                                    Positioned(
                                      bottom: 4.h,
                                      child: Container(
                                        width: 60.w * shadowSpread,
                                        height: 8.h * shadowSpread,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? (0.35 * shadowSpread) : (0.12 * shadowSpread),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.elliptical(30.w * shadowSpread, 4.h * shadowSpread),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: isDark ? (0.3 * shadowSpread) : (0.1 * shadowSpread),
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Floating & Tilting 3D Icon
                                    Transform.translate(
                                      offset: Offset(0, floatY),
                                      child: Transform.rotate(
                                        angle: tiltAngle,
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Image.asset(
                                            'assets/images/video_playlist_3d_icon.png',
                                            width: 95.w,
                                            height: 85.h,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.play_circle_fill_rounded,
                                              size: 60.sp,
                                              color: AppColorTokens.primaryRed.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Divider below static card
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 8.h),
                      child: Container(
                        height: 1.2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFFED1C24).withValues(alpha: 0.6),
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ]
                                : [
                                    const Color(0xFFED1C24).withValues(alpha: 0.45),
                                    Colors.black.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Scrollable Video List Only
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(14.w, 2.h, 14.w, 16.h),
                        itemCount: videos.length,
                        separatorBuilder: (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final isTop = index == 0;
                          final videoItem = videos[index];
                          final videoMap = videoItem is Map ? Map<String, dynamic>.from(videoItem) : <String, dynamic>{};
                          final rawName = (videoMap['fileName'] ?? '').toString();
                          final title = _cleanFileName(rawName);
                          final date = videoMap['createdAt'] != null
                              ? videoMap['createdAt'].toString().split('T').first
                              : "";
                          final String imageUrl = _getThumbnailUrl(videoMap);
                          final bool hasImage = imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
                          final int views = _getViewCount(videoMap);

                          final cardBg = isTop
                              ? (isDark ? const Color(0xFF1E1416) : const Color(0xFFFFF7F8))
                              : (isDark ? const Color(0xFF1E1E22) : Colors.white);

                          final borderColor = isTop
                              ? (isDark ? const Color(0xFF5C1D24) : const Color(0xFFFFCDD2))
                              : (isDark ? const Color(0xFF2C2C32) : const Color(0xFFECECF2));

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TagVideoPlayerScreen(
                                    videos: videos,
                                    initialIndex: index,
                                    tagTitle: "$tagTitle - $displayFolderName",
                                    tagThumbnailUrl: tagThumbnailUrl,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: borderColor,
                                  width: isTop ? 1.4 : 1.0,
                                ),
                                boxShadow: isTop
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFED1C24).withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                              ),
                              child: Stack(
                                children: [
                                  if (isTop)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 3.5.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFED1C24),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.r),
                                            bottomLeft: Radius.circular(12.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(isTop ? 12.w : 8.w, 7.h, 10.w, 7.h),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Video Thumbnail
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.r),
                                          child: Container(
                                            width: 92.w,
                                            height: 56.h,
                                            color: Colors.black87,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                if (hasImage)
                                                  Positioned.fill(
                                                    child: CachedNetworkImage(
                                                      imageUrl: imageUrl,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => Container(color: Colors.grey.shade900),
                                                      errorWidget: (context, url, error) => Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [AppColorTokens.primaryRed.withValues(alpha: 0.8), Colors.black87],
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [AppColorTokens.primaryRed.withValues(alpha: 0.8), Colors.black87],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                    ),
                                                  ),
                                                Container(
                                                  padding: EdgeInsets.all(4.5.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.55),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.white,
                                                    size: 16.sp,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 3,
                                                  right: 3,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.75),
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                    child: Text(
                                                      "#${index + 1}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8.5.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),

                                        // Video Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(
                                                  fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: textColor,
                                                  height: 1.25,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4.h),
                                              Row(
                                                children: [
                                                  if (date.isNotEmpty) ...[
                                                    Icon(Icons.calendar_today_outlined, size: 10.sp, color: subTextColor),
                                                    SizedBox(width: 3.w),
                                                    Text(
                                                      date,
                                                      style: TextStyle(
                                                        fontSize: 10.5.sp,
                                                        color: subTextColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                  if (context.watch<HomeProvider>().liveTvCountEnable) ...[
                                                    SizedBox(width: 8.w),
                                                    Icon(Icons.remove_red_eye_outlined, size: 11.sp, color: subTextColor),
                                                    SizedBox(width: 3.w),
                                                    Text(
                                                      _formatViewCount(views),
                                                      style: TextStyle(
                                                        fontSize: 10.5.sp,
                                                        color: subTextColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ],
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
