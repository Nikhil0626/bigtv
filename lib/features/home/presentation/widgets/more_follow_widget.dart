import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

class MoreFollowWidget extends StatefulWidget {
  final List<dynamic> moreFollowTags;

  const MoreFollowWidget({
    super.key,
    required this.moreFollowTags,
  });

  @override
  State<MoreFollowWidget> createState() => _MoreFollowWidgetState();
}

class _MoreFollowWidgetState extends State<MoreFollowWidget> {
  // Local state to keep track of followed tags by string ID
  final Set<String> followedTags = {};

  @override
  void initState() {
    super.initState();
    _syncFollowedTags();
  }

  @override
  void didUpdateWidget(covariant MoreFollowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moreFollowTags != widget.moreFollowTags) {
      _syncFollowedTags();
    }
  }

  void _syncFollowedTags() {
    followedTags.clear();
    for (var i = 0; i < widget.moreFollowTags.length; i++) {
      final tag = widget.moreFollowTags[i];
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "The more you follow,\nthe better it is",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        height: 1.1,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Personalize your feed by following topics",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tags List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: widget.moreFollowTags.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final tag = widget.moreFollowTags[index];
                  if (tag is! Map) return const SizedBox.shrink();

                  final rawId = tag['morefollowId'] ?? tag['id'] ?? tag['aitagid'] ?? index;
                  final String tagIdStr = rawId.toString();

                  final tagName = tag['morefollowName'] ??
                      tag['morefollowNameTranslations']?['te'] ??
                      tag['aitagname'] ??
                      tag['name'] ??
                      '';

                  final isFollowed = followedTags.contains(tagIdStr) ||
                      tag['isFollowed'] == true ||
                      tag['isFollowed'] == "true" ||
                      tag['isFollowed'] == 1;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "#${tagName.toString()}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isFollowed ? Colors.grey.shade400 : const Color(0xFFF42929),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isFollowed ? "Following" : "Follow",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
