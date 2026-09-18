import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/features/home/presentation/screens/tag_video_player_screen.dart';

class TagVideoGridViewWidget extends StatelessWidget {
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

  String _cleanFileName(String name) {
    if (name.isEmpty) return "Video Show";
    return name.replaceAll(RegExp(r'\.(mp4|mov|mkv|avi)$', caseSensitive: false), '');
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
      color: isDark ? Colors.black : Colors.grey.shade100,
      child: SafeArea(
        top: false,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(12),
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
    final bgColor = isDark ? Colors.black : Colors.grey.shade100;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (isLoading) {
      return _buildShimmerGrid(context, isDark);
    }

    if (videos.isEmpty) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppNoData(),
              const SizedBox(height: 12),
              Text(
                "No videos available for $tagTitle",
                style: TextStyle(
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

    return Container(
      color: bgColor,
      child: SafeArea(
        top: false,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final videoMap = video is Map ? Map<String, dynamic>.from(video) : <String, dynamic>{};
                  final rawName = (videoMap['fileName'] ?? '').toString();
                  final title = _cleanFileName(rawName);
                  final date = videoMap['createdAt'] != null
                      ? videoMap['createdAt'].toString().split('T').first
                      : "";

                  final String imageUrl = _getThumbnailUrl(videoMap, tagThumbnailUrl: tagThumbnailUrl);
                  final bool hasImage = imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TagVideoPlayerScreen(
                            videos: videos,
                            initialIndex: index,
                            tagTitle: tagTitle,
                            tagThumbnailUrl: tagThumbnailUrl,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail Preview Box
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [Colors.grey.shade800, Colors.black87]
                                      : [Colors.red.shade700, Colors.black87],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (hasImage)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                                    ),
                                  Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 48.r,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.video_collection, size: 10, color: Colors.white),
                                          const SizedBox(width: 3),
                                          Text(
                                            "Video",
                                            style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Details section
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (date.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 11.r, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        date,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey,
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
              ),
      ),
    );
  }
}
