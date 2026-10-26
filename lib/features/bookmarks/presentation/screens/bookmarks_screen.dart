import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../aggricator_screens/individual_post_details/individual_post_view.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../features/home/presentation/providers/home_provider.dart';
import '../../../../utils/app_loading_screen.dart';
import '../../data/models/bookmark_post_model.dart';
import '../providers/bookmarks_provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksProvider>().fetchBookmarks(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookmarksProvider>().fetchBookmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeProvider = context.watch<HomeProvider>();
    final isTelugu = homeProvider.langCode == 'te';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101216) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF16191E) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFED1C24).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Color(0xFFED1C24),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isTelugu ? "బుక్‌మార్క్‌లు" : "ബുക്ക്‌മാർക്കുകൾ",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<BookmarksProvider>(
              builder: (context, provider, _) {
                if (provider.totalBookmarks <= 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262A32)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    "${provider.totalBookmarks}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
            onPressed: () {
              context.read<BookmarksProvider>().fetchBookmarks(refresh: true);
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Consumer<BookmarksProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.bookmarks.isEmpty) {
            return const Center(child: AppLoadingScreen());
          }

          if (provider.bookmarks.isEmpty) {
            return _buildEmptyState(context, isDark, isTelugu);
          }

          return RefreshIndicator(
            color: AppColorTokens.primaryRed,
            onRefresh: () async {
              await provider.fetchBookmarks(refresh: true);
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              itemCount: provider.bookmarks.length + (provider.isMoreLoading ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == provider.bookmarks.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: AppLoadingScreen()),
                  );
                }

                final post = provider.bookmarks[index];
                return _buildBookmarkCard(context, post, isDark, isTelugu);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    BookmarkPostModel post,
    bool isDark,
    bool isTelugu,
  ) {
    final String category = post.categoryName.isNotEmpty
        ? post.categoryName.first
        : (isTelugu ? "తాజా వార్తలు" : "ഏറ്റവും പുതിയ വാർത്തകൾ");

    final String timeDisplay = _formatCreatedDate(post.created);

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IndividualPostView1(
              postId: post.id.toString(),
              isComeFrom: true,
              initialArticle: post.toMap(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D23) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? const Color(0xFF282C34) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with category tag
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 95.w,
                  height: 95.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      post.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: post.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: isDark ? const Color(0xFF2A2E37) : const Color(0xFFE2E8F0),
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: isDark ? const Color(0xFF2A2E37) : const Color(0xFFE2E8F0),
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: isDark ? Colors.white38 : Colors.grey,
                                  size: 26,
                                ),
                              ),
                            )
                          : Container(
                              color: isDark ? const Color(0xFF2A2E37) : const Color(0xFFE2E8F0),
                              child: const Icon(Icons.newspaper_rounded, color: Colors.grey),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Timestamp Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFED1C24).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFED1C24),
                              ),
                            ),
                          ),
                        ),
                        if (timeDisplay.isNotEmpty)
                          Text(
                            timeDisplay,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Title
                    Text(
                      post.title.isNotEmpty ? post.title : post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Action buttons: WhatsApp share & Remove bookmark
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // WhatsApp Share Button
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _sharePost(post),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              "assets/images/WhatsApp_icon.png",
                              height: 22,
                              width: 22,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),

                        // Bookmark Remove / Toggle Icon
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            final provider = context.read<BookmarksProvider>();
                            await provider.toggleBookmark(
                              postId: post.id,
                              article: post.toMap(),
                              explicitStatus: false,
                              context: context,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFED1C24).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bookmark_remove_rounded,
                                  size: 15,
                                  color: Color(0xFFED1C24),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isTelugu ? "తీసివేయి" : "നീക്കം ചെയ്യുക",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFED1C24),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isTelugu) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: const Color(0xFFED1C24).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.bookmark_border_rounded,
                  size: 44,
                  color: Color(0xFFED1C24),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              isTelugu ? "బుక్‌మార్క్‌లు ఏవీ లేవు" : "ബുക്ക്‌മാർക്കുകളൊന്നും ലഭ്യമല്ല",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isTelugu
                  ? "మీకు నచ్చిన వార్తలను తరువాత చదవడానికి బుక్‌మార్క్ చిహ్నాన్ని నొక్కండి."
                  : "നിങ്ങൾക്ക് ഇഷ്ടമുള്ള വാർത്തകൾ പിന്നീട് വായിക്കാൻ ബുക്ക്‌മാർക്ക് ഐക്കൺ ടാപ്പ് ചെയ്യുക.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.explore_rounded, size: 18, color: Colors.white),
              label: Text(
                isTelugu ? "వార్తలు అన్వేషించండి" : "വാർത്തകൾ പര്യവേക്ഷണം ചെയ്യുക",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTokens.primaryRed,
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BookmarkPostModel post) async {
    final String title = post.title;
    final String link = Platform.isIOS ? post.linkUrlIos : post.linkUrlAndroid;
    final String postUrl = post.postUrl;
    final String shareText = "$title\n${postUrl.isNotEmpty ? '$postUrl\n' : ''}$link";

    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('com.chotanews/whatsapp');
        try {
          await platform.invokeMethod('shareToWhatsApp', {'imagePath': '', 'text': shareText});
          return;
        } catch (_) {}
      }

      final url = "whatsapp://send?text=${Uri.encodeComponent(shareText)}";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      debugPrint("Bookmark share error: $e");
    }
  }

  String _formatCreatedDate(String rawDate) {
    if (rawDate.isEmpty) return "";
    try {
      final date = DateTime.tryParse(rawDate);
      if (date == null) return "";
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return "${diff.inMinutes > 0 ? diff.inMinutes : 1}m ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h ago";
      } else if (diff.inDays < 7) {
        return "${diff.inDays}d ago";
      }
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return "";
    }
  }
}
