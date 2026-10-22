import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

class InFocusBarWidget extends StatelessWidget {
  const InFocusBarWidget({super.key});

  // Bluish grey background for the bar and safe area
  static const Color barBackgroundColor = Color(0xFF1E293B);
  static const Color cardBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        if (!homeProvider.showTopNavTags) {
          return const SizedBox.shrink();
        }

        // Show shimmer placeholder while loading initial tags
        if (homeProvider.isAiTagsLoading && homeProvider.getAllAiTagsList.isEmpty) {
          return _buildShimmer(context);
        }

        if (homeProvider.getAllAiTagsList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 68.h,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          color: barBackgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left "INFOCUS" Vertical Badge stuck completely to the left
              _buildInFocusBadge(context, homeProvider),

              // Horizontal Scrollable Cards
              Expanded(
                child: ListView.separated(
                  controller: homeProvider.aiTagScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(right: 8.w),
                  itemCount: homeProvider.getAllAiTagsList.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    if (!homeProvider.aiTagKeys.containsKey(index)) {
                      homeProvider.aiTagKeys[index] = GlobalKey();
                    }

                    final tag = homeProvider.getAllAiTagsList[index];
                    final tagId = tag['aitagid'] ?? tag['id'] ?? tag['slug'] ?? tag['aitagname'];
                    final selectedId = homeProvider.selectedTagId;

                    final bool isSelected = homeProvider.isAiTagDataLoaded &&
                        selectedId != null &&
                        selectedId != 0 &&
                        selectedId != "0" &&
                        (selectedId.toString() == tagId?.toString() ||
                            (tag['aitagid'] != null && selectedId.toString() == tag['aitagid'].toString()) ||
                            (tag['slug'] != null && selectedId.toString() == tag['slug'].toString()) ||
                            (tag['aitagname'] != null && selectedId.toString() == tag['aitagname'].toString()));

                    final String title = (tag['description'] != null &&
                            tag['description'].toString().trim().isNotEmpty)
                        ? tag['description'].toString().trim()
                        : ((tag['title'] != null && tag['title'].toString().trim().isNotEmpty)
                            ? tag['title'].toString().trim()
                            : ((tag['aitagname'] != null && tag['aitagname'].toString().trim().isNotEmpty)
                                ? tag['aitagname'].toString().trim()
                                : (tag['name'] ?? tag['slug'] ?? '').toString().trim()));

                    final String imageUrl = (tag['thumbnailUrl'] ??
                            tag['thumbnail_url'] ??
                            tag['imageUrl'] ??
                            tag['image_url'] ??
                            tag['thumbnail'] ??
                            tag['image'] ??
                            '')
                        .toString()
                        .trim();

                    return _buildInFocusCard(
                      context,
                      homeProvider,
                      index: index,
                      tag: tag,
                      tagId: tagId,
                      isSelected: isSelected,
                      title: title,
                      imageUrl: imageUrl,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInFocusBadge(
    BuildContext context,
    HomeProvider homeProvider,
  ) {
    return GestureDetector(
      onTap: () {
        if (homeProvider.isAiTagDataLoaded) {
          homeProvider.setSelectedTagId(0);
          homeProvider.aiTagDataLoaded(false);
          homeProvider.getAllPost(postIds: "0");
        }
      },
      child: Container(
        width: 33.w,
        margin: EdgeInsets.only(left: 0, right: 6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(
            top: 1.2,
            bottom: 1.2,
            right: 1.2,
            left: 0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(6.8.r),
              bottomRight: Radius.circular(6.8.r),
            ),
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                "INFOCUS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInFocusCard(
    BuildContext context,
    HomeProvider homeProvider, {
    required int index,
    required dynamic tag,
    required dynamic tagId,
    required bool isSelected,
    required String title,
    required String imageUrl,
  }) {
    return InkWell(
      key: homeProvider.aiTagKeys[index],
      borderRadius: BorderRadius.circular(8.r),
      onTap: () async {
        if (isSelected && homeProvider.isAiTagDataLoaded) {
          homeProvider.setSelectedTagId(0);
          homeProvider.aiTagDataLoaded(false);
          homeProvider.getAllPost(postIds: "0");
          return;
        }

        final tagSlug = tag['slug'] ?? tag['name'] ?? tag['aitagname'] ?? tagId;
        final displayTitle = tag['aitagname'] ?? tag['name'] ?? tagSlug;
        final tagThumbnail = tag['thumbnailUrl'] ?? tag['thumbnail_url'] ?? tag['thumbnail'] ?? tag['imageUrl'];
        final chosenId = tagId ?? tagSlug;

        homeProvider.setSelectedTagId(chosenId);
        if (homeProvider.liveTvVideosEnable) {
          homeProvider.fetchVideosByTagSlug(
            tagSlug.toString(),
            displayTitle: displayTitle.toString(),
            thumbnailUrl: tagThumbnail?.toString(),
          );
        } else {
          homeProvider.getAllPostsByAiId(tag['aitagid'] ?? chosenId);
        }
        homeProvider.aiTagDataLoaded(true);
        homeProvider.pageChange(isValue: true);
        try {
          context.read<VideoProvider>().pauseVideo();
        } catch (_) {}
        homeProvider.aiTagsScrollToCenter(index);
        EventRepo().addEvent({
          "aiTagName": (tag['aitagname'] ?? displayTitle ?? "").toString(),
          "aiTagId": (tag['aitagid'] ?? chosenId ?? "").toString(),
          "createAt": DateTime.now().toString(),
        }, "ai_tag_click");
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColorTokens.primaryRed
                : const Color(0xFFDDDDDD),
            width: isSelected ? 1.8 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title / Description in dark text for readability on white card
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF1A1A1A),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Right-aligned Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: SizedBox(
                width: 48.w,
                height: 48.w,
                child: _buildThumbnail(imageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    if (imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF2F2F2),
            child: const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColorTokens.primaryRed,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
      );
    }
    return _buildFallbackThumbnail();
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        "assets/images/bigtv_default_post.png",
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          "assets/BIGTV-APP ICON.png",
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.newspaper_rounded,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    const baseColor = Color(0xFF283548);
    const highlightColor = Color(0xFF384960);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 68.h,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        color: barBackgroundColor,
        child: Row(
          children: [
            Container(
              width: 32.w,
              margin: EdgeInsets.only(left: 0, right: 6.w),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.r),
                  bottomRight: Radius.circular(8.r),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, __) => Container(
                  width: 260.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
