import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';
import 'package:chotanews/features/home/presentation/screens/tag_video_player_screen.dart';
import 'package:chotanews/features/home/presentation/screens/tag_folder_videos_screen.dart';

class TagVideoGridViewWidget extends StatefulWidget {
  final List videos;
  final bool isLoading;
  final String tagTitle;
  final String? tagThumbnailUrl;

  const TagVideoGridViewWidget({
    super.key,
    required this.videos,
    this.isLoading = false,
    this.tagTitle = "Videos",
    this.tagThumbnailUrl,
  });

  @override
  State<TagVideoGridViewWidget> createState() => _TagVideoGridViewWidgetState();
}

class _TagVideoGridViewWidgetState extends State<TagVideoGridViewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  List get videos => widget.videos;
  bool get isLoading => widget.isLoading;
  String get tagTitle => widget.tagTitle;
  String? get tagThumbnailUrl => widget.tagThumbnailUrl;

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

  String _cleanFileName(String name) {
    if (name.isEmpty) return "Video Show";
    return name.replaceAll(RegExp(r'\.(mp4|mov|mkv|avi|webm)$', caseSensitive: false), '').trim();
  }

  String _formatFolderName(String folder) {
    final trimmed = folder.trim().toLowerCase();
    if (trimmed == 'root' || trimmed.isEmpty) {
      return 'Featured';
    }
    final dayMatch = RegExp(r'^day\s*(\d+)$', caseSensitive: false).firstMatch(folder.trim());
    if (dayMatch != null) {
      return 'Day ${dayMatch.group(1)}';
    }
    return folder.trim().split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  int _folderSortKey(String folder) {
    final trimmed = folder.trim().toLowerCase();
    if (trimmed == 'root' || trimmed.isEmpty) return 0;
    final dayMatch = RegExp(r'^day\s*(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (dayMatch != null) {
      return int.tryParse(dayMatch.group(1) ?? '999') ?? 999;
    }
    return 9999;
  }

  Map<String, List<Map<String, dynamic>>> _groupVideosByFolder(List list) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in list) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      String folder = (map['folder'] ?? '').toString().trim();
      if (folder.isEmpty) folder = 'root';
      grouped.putIfAbsent(folder, () => []).add(map);
    }
    return grouped;
  }

  String _getThumbnailUrl(Map<String, dynamic> item, {String? tagThumbnailUrl}) {
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

    if (tagThumbnailUrl != null && tagThumbnailUrl.trim().isNotEmpty) {
      return tagThumbnailUrl.trim();
    }

    return "";
  }

  Widget _buildShimmerGrid(BuildContext context, bool isDark) {
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFFBFBFC),
      child: SafeArea(
        top: false,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.92,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF181A20);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (isLoading) {
      return _buildShimmerGrid(context, isDark);
    }

    if (videos.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFFBFBFC),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppNoData(),
              const SizedBox(height: 12),
              Text(
                "No videos available for $tagTitle",
                style: TextStyle(
                  fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group videos by folder (day1, day2, root, etc.)
    final groupedFolders = _groupVideosByFolder(videos);

    // If only root exists and no other day folders, render simple direct video grid
    final bool hasSubFolders = groupedFolders.keys.any((k) => k.toLowerCase() != 'root');

    if (!hasSubFolders) {
      return _buildDirectVideoGrid(context, videos, isDark, textColor, subTextColor);
    }

    // Sort folders: root first (or last), followed by Day 1, Day 2, Day 3...
    final sortedFolderKeys = groupedFolders.keys.toList()
      ..sort((a, b) {
        final aKey = _folderSortKey(a);
        final bKey = _folderSortKey(b);
        if (aKey != bKey) {
          return aKey.compareTo(bKey);
        }
        return a.compareTo(b);
      });

    return Container(
      color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFFBFBFC),
      child: Stack(
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

          SafeArea(
            top: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Redesigned Top Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Capsule tag
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                                decoration: BoxDecoration(
                                  color: AppColorTokens.primaryRed.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColorTokens.primaryRed.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 4.5.w,
                                      height: 4.5.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFED1C24),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "EPISODES BY DAY",
                                      style: TextStyle(
                                        color: const Color(0xFFED1C24),
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // Subtitle Collections & Videos count
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_outlined, size: 12.sp, color: subTextColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "${sortedFolderKeys.length} Collections • ${videos.length} Videos",
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Animated Play All Pill Button
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            final pulse = (math.sin(_waveController.value * 2 * math.pi) + 1) / 2;
                            final scale = 1.0 + 0.03 * pulse;
                            final glowAlpha = 0.25 + 0.25 * pulse;

                            return Transform.scale(
                              scale: scale,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TagVideoPlayerScreen(
                                        videos: videos,
                                        initialIndex: 0,
                                        tagTitle: tagTitle,
                                        tagThumbnailUrl: tagThumbnailUrl,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(8.w, 5.h, 12.w, 5.h),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF2A32), Color(0xFFC61118)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFED1C24).withValues(alpha: glowAlpha),
                                        blurRadius: 10 + 4 * pulse,
                                        spreadRadius: 1.0 * pulse,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Animated Play Badge
                                      Container(
                                        padding: EdgeInsets.all(3.5.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(alpha: 0.4 + 0.3 * pulse),
                                              blurRadius: 4 + 3 * pulse,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: const Color(0xFFED1C24),
                                          size: 13.sp,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        "Play All",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      // Mini Live Equalizer Bars
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 2.w,
                                            height: 4.h + ((math.sin(_waveController.value * 2 * math.pi * 1.8) + 1) / 2) * 6.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              borderRadius: BorderRadius.circular(1.r),
                                            ),
                                          ),
                                          SizedBox(width: 1.5.w),
                                          Container(
                                            width: 2.w,
                                            height: 5.h + ((math.cos(_waveController.value * 2 * math.pi * 2.2) + 1) / 2) * 7.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.95),
                                              borderRadius: BorderRadius.circular(1.r),
                                            ),
                                          ),
                                          SizedBox(width: 1.5.w),
                                          Container(
                                            width: 2.w,
                                            height: 3.h + ((math.sin(_waveController.value * 2 * math.pi * 2.6) + 1) / 2) * 8.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              borderRadius: BorderRadius.circular(1.r),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider line
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                    child: Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFFED1C24).withValues(alpha: 0.5),
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ]
                              : [
                                  const Color(0xFFED1C24).withValues(alpha: 0.4),
                                  Colors.black.withValues(alpha: 0.06),
                                  Colors.transparent,
                                ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Grid of Folder/Day Cards
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.94,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final isFirst = index == 0;
                        final folderKey = sortedFolderKeys[index];
                        final folderVideos = groupedFolders[folderKey] ?? [];
                        final displayTitle = _formatFolderName(folderKey);

                        // Get thumbnail from the first video in this folder
                        final firstVideo = folderVideos.isNotEmpty ? folderVideos.first : <String, dynamic>{};
                        final imageUrl = _getThumbnailUrl(firstVideo, tagThumbnailUrl: tagThumbnailUrl);
                        final bool hasImage = imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

                        // Get creation date of first/latest video
                        final date = firstVideo['createdAt'] != null
                            ? firstVideo['createdAt'].toString().split('T').first
                            : "";

                        final cardBg = isFirst
                            ? (isDark ? const Color(0xFF1E1416) : const Color(0xFFFFF7F8))
                            : (isDark ? const Color(0xFF1E1E22) : Colors.white);

                        final borderColor = isFirst
                            ? (isDark ? const Color(0xFF5C1D24) : const Color(0xFFFFCDD2))
                            : (isDark ? const Color(0xFF2C2C32) : const Color(0xFFECECF2));

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TagFolderVideosScreen(
                                  tagTitle: tagTitle,
                                  folderName: folderKey,
                                  displayFolderName: displayTitle,
                                  videos: folderVideos,
                                  tagThumbnailUrl: tagThumbnailUrl,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: borderColor,
                                width: isFirst ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Folder Graphic / Thumbnail Box
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(13.r)),
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.black87,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (hasImage)
                                            CachedNetworkImage(
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

                                          // Subtle dark gradient vignette
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withValues(alpha: 0.1),
                                                  Colors.black.withValues(alpha: 0.65),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),

                                          // Centered Folder Icon badge
                                          Center(
                                            child: Container(
                                              padding: EdgeInsets.all(7.w),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.55),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white30, width: 1),
                                              ),
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),

                                          // Count chip
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: AppColorTokens.primaryRed,
                                                borderRadius: BorderRadius.circular(12.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.3),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                "${folderVideos.length} ${folderVideos.length == 1 ? 'Vid' : 'Vids'}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Folder Details Row
                                Padding(
                                  padding: EdgeInsets.fromLTRB(9.w, 7.h, 9.w, 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayTitle,
                                              style: TextStyle(
                                                fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                                                fontSize: 13.5.sp,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (date.isNotEmpty) ...[
                                              SizedBox(height: 2.h),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today_outlined, size: 9.sp, color: subTextColor),
                                                  SizedBox(width: 3.w),
                                                  Text(
                                                    date,
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: subTextColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(3.5.w),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 9.sp,
                                          color: isDark ? Colors.white70 : Colors.grey.shade600,
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
                      childCount: sortedFolderKeys.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectVideoGrid(
    BuildContext context,
    List videoList,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFFBFBFC),
      child: Stack(
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

          SafeArea(
            top: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Top Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Capsule tag
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                                decoration: BoxDecoration(
                                  color: AppColorTokens.primaryRed.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColorTokens.primaryRed.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 4.5.w,
                                      height: 4.5.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFED1C24),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "ALL VIDEOS",
                                      style: TextStyle(
                                        color: const Color(0xFFED1C24),
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // Subtitle
                              Row(
                                children: [
                                  Icon(Icons.video_library_outlined, size: 12.sp, color: subTextColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "${videoList.length} ${videoList.length == 1 ? 'Video' : 'Videos'}",
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Animated Play All Button
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            final pulse = (math.sin(_waveController.value * 2 * math.pi) + 1) / 2;
                            final scale = 1.0 + 0.03 * pulse;
                            final glowAlpha = 0.25 + 0.25 * pulse;

                            return Transform.scale(
                              scale: scale,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TagVideoPlayerScreen(
                                        videos: videoList,
                                        initialIndex: 0,
                                        tagTitle: tagTitle,
                                        tagThumbnailUrl: tagThumbnailUrl,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(8.w, 5.h, 12.w, 5.h),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF2A32), Color(0xFFC61118)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFED1C24).withValues(alpha: glowAlpha),
                                        blurRadius: 10 + 4 * pulse,
                                        spreadRadius: 1.0 * pulse,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(3.5.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(alpha: 0.4 + 0.3 * pulse),
                                              blurRadius: 4 + 3 * pulse,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: const Color(0xFFED1C24),
                                          size: 13.sp,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        "Play All",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider line
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                    child: Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFFED1C24).withValues(alpha: 0.5),
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ]
                              : [
                                  const Color(0xFFED1C24).withValues(alpha: 0.4),
                                  Colors.black.withValues(alpha: 0.06),
                                  Colors.transparent,
                                ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Grid of Videos
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.94,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final isFirst = index == 0;
                        final video = videoList[index];
                        final videoMap = video is Map ? Map<String, dynamic>.from(video) : <String, dynamic>{};
                        final rawName = (videoMap['fileName'] ?? '').toString();
                        final title = _cleanFileName(rawName);
                        final date = videoMap['createdAt'] != null
                            ? videoMap['createdAt'].toString().split('T').first
                            : "";

                        final String imageUrl = _getThumbnailUrl(videoMap, tagThumbnailUrl: tagThumbnailUrl);
                        final bool hasImage = imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

                        final cardBg = isFirst
                            ? (isDark ? const Color(0xFF1E1416) : const Color(0xFFFFF7F8))
                            : (isDark ? const Color(0xFF1E1E22) : Colors.white);

                        final borderColor = isFirst
                            ? (isDark ? const Color(0xFF5C1D24) : const Color(0xFFFFCDD2))
                            : (isDark ? const Color(0xFF2C2C32) : const Color(0xFFECECF2));

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TagVideoPlayerScreen(
                                  videos: videoList,
                                  initialIndex: index,
                                  tagTitle: tagTitle,
                                  tagThumbnailUrl: tagThumbnailUrl,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: borderColor,
                                width: isFirst ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(13.r)),
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.black87,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (hasImage)
                                            Positioned.fill(
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                                ),
                                                errorWidget: (context, url, error) => const SizedBox.shrink(),
                                              ),
                                            ),
                                          Container(
                                            padding: EdgeInsets.all(7.w),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.55),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white30, width: 1),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(9.w, 7.h, 9.w, 8.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontFamily: GoogleFonts.notoSerifTelugu().fontFamily,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (date.isNotEmpty) ...[
                                        SizedBox(height: 2.h),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined, size: 9.sp, color: subTextColor),
                                            SizedBox(width: 3.w),
                                            Text(
                                              date,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: subTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: videoList.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
