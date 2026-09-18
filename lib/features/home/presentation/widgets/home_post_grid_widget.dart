import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:chotanews/utils/translated_text.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePostGridWidget extends StatelessWidget {
  final List posts;

  const HomePostGridWidget({
    super.key,
    required this.posts,
  });

  String _getImageUrl(dynamic post) {
    dynamic imageUrl = post['image_url'] ?? post['image'] ?? post['imageUrl'];
    if (imageUrl == null || imageUrl.toString().trim().isEmpty) {
      return "";
    }
    String url = imageUrl.toString().trim();
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }
    if (url.startsWith('https://')) return url;
    if (url.startsWith('/')) return "https://migwp.chotanews.com$url";
    return "https://migwp.chotanews.com/$url";
  }

  void _openPost(BuildContext context, dynamic post) {
    if (post == null || post['id'] == null) return;
    final Map<String, dynamic> articleMap = post is Map<String, dynamic>
        ? post
        : Map<String, dynamic>.from(post as Map);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualPostView1(
          postId: post['id'].toString(),
          isComeFrom: true,
          initialArticle: articleMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    final postTop = posts[0];
    final postLeft = posts.length > 1 ? posts[1] : null;
    final postRight = posts.length > 2 ? posts[2] : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Container(
      color: bgColor,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // Top large card (One above)
            Expanded(
              flex: 60,
              child: _buildTopCard(context, postTop, textColor, subTextColor),
            ),

            Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),

            // Bottom 2 cards (Two below)
            Expanded(
              flex: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: postLeft != null
                        ? _buildBottomCard(context, postLeft, textColor, subTextColor)
                        : const SizedBox.shrink(),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: postRight != null
                        ? _buildBottomCard(context, postRight, textColor, subTextColor)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(
    BuildContext context,
    dynamic post,
    Color textColor,
    Color subTextColor,
  ) {
    final title = post['title'] ?? post['notificationtitle'] ?? '';
    final imageUrl = _getImageUrl(post);
    final created = post['created']?.toString() ?? post['createdAt']?.toString() ?? '';
    final isVideo = post['type'] == 'Video' || (post['video_url'] != null && post['video_url'].toString().isNotEmpty);

    return InkWell(
      onTap: () => _openPost(context, post),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/bigtv_default_post.png",
                fit: BoxFit.cover,
              ),
            )
          else
            Image.asset(
              "assets/images/bigtv_default_post.png",
              fit: BoxFit.cover,
            ),

          // Gradient overlay for text readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Play icon overlay if video
          if (isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

          // Title and info overlay at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TranslatedText(
                  title.toString(),
                  translate: context.watch<HomeProvider>().isEnglishMode,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    shadows: const [
                      Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "BIG TV",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (created.isNotEmpty) ...[
                      Text(
                        " • ",
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                      Expanded(
                        child: Text(
                          formatTimeDifference(created),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
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
    );
  }

  Widget _buildBottomCard(
    BuildContext context,
    dynamic post,
    Color textColor,
    Color subTextColor,
  ) {
    final title = post['title'] ?? post['notificationtitle'] ?? '';
    final imageUrl = _getImageUrl(post);
    final isVideo = post['type'] == 'Video' || (post['video_url'] != null && post['video_url'].toString().isNotEmpty);

    return InkWell(
      onTap: () => _openPost(context, post),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/bigtv_default_post.png",
                fit: BoxFit.cover,
              ),
            )
          else
            Image.asset(
              "assets/images/bigtv_default_post.png",
              fit: BoxFit.cover,
            ),

          // Gradient overlay for text readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Play icon overlay if video
          if (isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

          // Title overlay at bottom
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: TranslatedText(
              title.toString(),
              translate: context.watch<HomeProvider>().isEnglishMode,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                height: 1.25,
                shadows: const [
                  Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
