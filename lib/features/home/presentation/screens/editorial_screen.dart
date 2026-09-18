import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/theme/theme_extensions.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:chotanews/utils/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class EditorialScreen extends StatefulWidget {
  const EditorialScreen({super.key});

  @override
  State<EditorialScreen> createState() => _EditorialScreenState();
}

class _EditorialScreenState extends State<EditorialScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      if (homeProvider.editorialPosts.isEmpty) {
        homeProvider.fetchEditorialPosts();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.loadMoreEditorialPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildEditorialShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180.h,
                  width: double.infinity,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 16.h,
                            width: 80.w,
                            color: Colors.white,
                          ),
                          const Spacer(),
                          Container(
                            height: 14.h,
                            width: 60.w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 18.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 18.h,
                        width: MediaQuery.of(context).size.width * 0.6,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 20.h,
                            width: 100.w,
                            color: Colors.white,
                          ),
                          Container(
                            height: 28.h,
                            width: 28.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColorTokens.primaryRed,
        elevation: 0,
        centerTitle: true,
        title: Consumer<HomeProvider>(
          builder: (_, homeProvider, __) {
            final title = homeProvider.langCode == 'ml' ? 'എഡിറ്റോറിയൽ' : 'ఎడిటోరియల్';
            return Text(
              title,
              style: homeScreenFontStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isEditorialLoading && homeProvider.editorialPosts.isEmpty) {
            return _buildEditorialShimmer();
          }

          final posts = homeProvider.editorialPosts;
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    homeProvider.langCode == 'ml'
                        ? 'എഡിറ്റോറിയലുകൾ ലഭ്യമല്ല'
                        : 'ఎడిటోరియల్స్ అందుబాటులో లేవు',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColorTokens.primaryRed,
            onRefresh: () async {
              await homeProvider.fetchEditorialPosts(refresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: posts.length + (homeProvider.isEditorialLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }

                final article = posts[index];
                final String title = article['title']?.toString() ?? 'Editorial';
                final String imageUrl = article['image_url']?.toString() ?? '';
                final String publishDate = article['publishDate']?.toString() ?? '';
                final String webUrl = article['link']?.toString() ?? '';
                final String shareUrl = webUrl.isNotEmpty ? webUrl : "https://www.bigtvlive.com/?p=${article['id']}";

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (webUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InAppWebViewScreen(
                              webUrl: webUrl,
                              title: title,
                            ),
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: 180.h,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/bigtv_default_post.png',
                              height: 180.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Image.asset(
                            'assets/images/bigtv_default_post.png',
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColorTokens.primaryRed.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'EDITORIAL',
                                      style: TextStyle(
                                        color: AppColorTokens.primaryRed,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (publishDate.isNotEmpty)
                                    Text(
                                      publishDate,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TranslatedText(
                                title,
                                translate: homeProvider.isEnglishMode,
                                style: homeScreenFontStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/BigTvPostLogo.png',
                                        height: 34.h,
                                        width: 34.h,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        homeProvider.langCode == 'ml' ? 'കൂടുതൽ വായിക്കുക' : 'ఇంకా చదవండి',
                                        style: TextStyle(
                                          color: AppColorTokens.primaryRed,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final text = Uri.encodeComponent("$title\n$shareUrl");
                                      final whatsappUrl = Uri.parse("whatsapp://send?text=$text");
                                      if (await canLaunchUrl(whatsappUrl)) {
                                        await launchUrl(whatsappUrl);
                                      } else {
                                        Share.share("$title\n$shareUrl");
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/WhatsApp_icon.png',
                                      height: 28,
                                      width: 28,
                                      fit: BoxFit.contain,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
