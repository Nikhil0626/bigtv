import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

class MoreFollowWidget extends StatefulWidget {
  final List<dynamic>? moreFollowTags;

  const MoreFollowWidget({
    super.key,
    this.moreFollowTags,
  });

  @override
  State<MoreFollowWidget> createState() => _MoreFollowWidgetState();
}

class _MoreFollowWidgetState extends State<MoreFollowWidget> {
  // Local state to keep track of followed tags by string ID
  final Set<String> followedTags = {};
  List<dynamic> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.moreFollowTags != null && widget.moreFollowTags!.isNotEmpty) {
      _tags = List.from(widget.moreFollowTags!);
      _syncFollowedTags();
    }
    _loadData();
  }

  @override
  void didUpdateWidget(covariant MoreFollowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moreFollowTags != widget.moreFollowTags) {
      if (widget.moreFollowTags != null && widget.moreFollowTags!.isNotEmpty) {
        _tags = List.from(widget.moreFollowTags!);
        _syncFollowedTags();
      }
    }
  }

  Future<void> _loadData() async {
    final homeProvider = context.read<HomeProvider>();
    if (_tags.isEmpty) {
      if (homeProvider.moreFollowTagsList.isNotEmpty) {
        setState(() {
          _tags = List.from(homeProvider.moreFollowTagsList);
          _syncFollowedTags();
        });
      } else {
        setState(() => _isLoading = true);
      }
    }

    final freshTags = await homeProvider.fetchMoreFollowTags();
    if (mounted && freshTags.isNotEmpty) {
      setState(() {
        _tags = List.from(freshTags);
        _syncFollowedTags();
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _syncFollowedTags() {
    followedTags.clear();
    for (var i = 0; i < _tags.length; i++) {
      final tag = _tags[i];
      if (tag is Map) {
        final isFollowed = tag['isFollowed'] == true ||
            tag['isFollowed'] == "true" ||
            tag['isFollowed'] == 1;
        if (isFollowed) {
          final rawId = tag['morefollowId'] ?? tag['id'] ?? tag['aitagid'] ?? i;
          followedTags.add(rawId.toString());
        }
      }
    }
  }

  String? _getValidImageUrl(Map tag) {
    for (final key in ['imageUrl', 'image_url', 'image', 'tagImage', 'icon', 'thumbnail', 'img', 'photo', 'picture']) {
      final val = tag[key]?.toString().trim();
      if (val != null && val.isNotEmpty) {
        var str = val;
        if (str.startsWith('"') && str.endsWith('"')) {
          str = str.substring(1, str.length - 1).trim();
        }
        if (str.toLowerCase() == 'string' || str.toLowerCase() == 'null' || str.isEmpty) {
          continue;
        }
        if (str.startsWith('//')) {
          return 'https:$str';
        }
        if (str.startsWith('http://') || str.startsWith('https://')) {
          return str;
        }
      }
    }
    return null;
  }

  Widget _buildFallbackTagIcon(String tagName, bool isDark) {
    final clean = tagName.replaceFirst('#', '').trim();
    final lower = clean.toLowerCase();

    // Themed icon for popular categories when image is missing or placeholder "string"
    IconData? iconData;
    if (lower.contains('క్రికెట్') || lower.contains('cricket') || lower.contains('sports') || lower.contains('క్రీడలు')) {
      iconData = Icons.sports_cricket_rounded;
    } else if (lower.contains('ట్రెండింగ్') || lower.contains('trending') || lower.contains('viral')) {
      iconData = Icons.local_fire_department_rounded;
    } else if (lower.contains('సినిమా') || lower.contains('movie') || lower.contains('film') || lower.contains('entertainment')) {
      iconData = Icons.movie_filter_rounded;
    } else if (lower.contains('రాజకీయాలు') || lower.contains('politics')) {
      iconData = Icons.how_to_vote_rounded;
    } else if (lower.contains('బిజినెస్') || lower.contains('business')) {
      iconData = Icons.trending_up_rounded;
    } else if (lower.contains('టెక్') || lower.contains('tech')) {
      iconData = Icons.memory_rounded;
    }

    if (iconData != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF26262A) : const Color(0xFFFFECEE),
        alignment: Alignment.center,
        child: Icon(
          iconData,
          size: 24.sp,
          color: const Color(0xFFED1C24),
        ),
      );
    }

    final char = clean.isNotEmpty ? clean.substring(0, 1) : '#';
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF26262A) : const Color(0xFFFFECEE),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFED1C24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final langCode = context.watch<HomeProvider>().postsLanguage ?? 'te';

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Section matching the design
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E151A), const Color(0xFF121212)]
                        : [const Color(0xFFFFF0F2), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Text Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Small red accent line + uppercase tag
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFED1C24),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "FOLLOW WHAT MATTERS",
                                style: TextStyle(
                                  color: const Color(0xFFED1C24),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Headline "The more you follow, the better it is"
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                color: textColor,
                              ),
                              children: const [
                                TextSpan(text: "The more you\nfollow,\n"),
                                TextSpan(
                                  text: "the better it is",
                                  style: TextStyle(
                                    color: Color(0xFFED1C24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle
                          Text(
                            "Personalize your feed by following topics you love",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: subTextColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right side 3D Illustration Graphic
                    Image.asset(
                      'assets/images/more_follow_3d_icon.png',
                      width: 130.w,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              if (_isLoading && _tags.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFED1C24)),
                      ),
                    ),
                  ),
                )
              else
                // Tags List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  itemCount: _tags.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final tag = _tags[index];
                    if (tag is! Map) return const SizedBox.shrink();

                    final rawId = tag['morefollowId'] ?? tag['id'] ?? tag['aitagid'] ?? index;
                    final String tagIdStr = rawId.toString();

                    String tagName = '';
                    if (tag['morefollowNameTranslations'] is Map) {
                      final trans = tag['morefollowNameTranslations'] as Map;
                      tagName = trans[langCode]?.toString() ??
                          trans['te']?.toString() ??
                          trans['en']?.toString() ??
                          '';
                    }
                    if (tagName.isEmpty) {
                      tagName = (tag['morefollowName'] ??
                              tag['aitagname'] ??
                              tag['name'] ??
                              '')
                          .toString();
                    }

                    final isFollowed = followedTags.contains(tagIdStr) ||
                        tag['isFollowed'] == true ||
                        tag['isFollowed'] == "true" ||
                        tag['isFollowed'] == 1;

                    final String? validImageUrl = _getValidImageUrl(tag);
                    final bool hasValidImage = validImageUrl != null;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tag Image / Icon Avatar left to the title
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F1F23) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333338) : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11.r),
                            child: hasValidImage
                                ? CachedNetworkImage(
                                    imageUrl: validImageUrl,
                                    width: 48.w,
                                    height: 48.w,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: SizedBox(
                                        width: 16.w,
                                        height: 16.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFED1C24)),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => _buildFallbackTagIcon(tagName, isDark),
                                  )
                                : _buildFallbackTagIcon(tagName, isDark),
                          ),
                        ),
                        SizedBox(width: 14.w),

                        // Tag Name
                        Expanded(
                          child: Text(
                            tagName.startsWith('#') ? tagName : "#$tagName",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Follow / Following Action Button
                        InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () {
                            setState(() {
                              if (isFollowed) {
                                followedTags.remove(tagIdStr);
                                tag['isFollowed'] = false;
                              } else {
                                followedTags.add(tagIdStr);
                                tag['isFollowed'] = true;
                              }
                            });

                            final intId = rawId is int ? rawId : (int.tryParse(tagIdStr) ?? index);
                            context.read<HomeProvider>().updateMoreFollowData([intId]);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color: isFollowed
                                  ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB))
                                  : const Color(0xFFED1C24),
                              borderRadius: BorderRadius.circular(20.r),
                              border: isFollowed
                                  ? Border.all(color: isDark ? Colors.white24 : Colors.black12)
                                  : null,
                            ),
                            child: Text(
                              isFollowed ? "Following" : "Follow",
                              style: TextStyle(
                                color: isFollowed
                                    ? (isDark ? Colors.white70 : Colors.black87)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
