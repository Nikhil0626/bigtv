import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/home/presentation/providers/news_posts_provider.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';

import '../aggricator_screens/events_data/event_repo.dart';
import 'date_format.dart';
import 'local_data.dart';

void showComments(BuildContext context, dynamic postId, dynamic postTitle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Push above keyboard
        ),
        child: CommentSection(postId: postId, postTitle: postTitle,),
      );
    },
  );
}

class CommentSection extends StatefulWidget {
  final dynamic postId;
  final dynamic postTitle;

  const CommentSection({super.key, required this.postId, required this.postTitle});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    context.read<NewsPostsProvider>().getAllComments(widget.postId.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // EdgeInsets gestureInsets = MediaQuery.of(context).systemGestureInsets;

    // String navigationMode = (gestureInsets.bottom > 0) ? "Gesture" : "Button";
    return Consumer<NewsPostsProvider>(
      builder: (_, newsPostsProvider, __) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Ensures it doesn't take full screen
          child: Container(
            padding: const EdgeInsets.only(top: 12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                height(height: 10),
                // Comments Header
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    children: [
                      Text(
                        "Comments",
                        style: fontStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.cancel_outlined,
                            size: 24,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                height(height: 16),

                // Comment List with Keyboard Scroll Fix
                Expanded(
                  child: newsPostsProvider.isLoadingComments
                      ? const AppLoadingScreen()
                      : newsPostsProvider.getAllCommentsList.isEmpty
                          ? Center(
                              child: Text(
                                "No comments yet... ",
                                style: fontStyle(
                                  fontSize: 14,
                                  color: const Color(0xff111928),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: newsPostsProvider.getAllCommentsList.length,
                              itemBuilder: (context, index) {
                                final comment = newsPostsProvider.getAllCommentsList[index];
                                final userName = (comment.user.name.trim().isNotEmpty)
                                    ? comment.user.name.trim()
                                    : "User";
                                final initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        child: Text(
                                          initial,
                                          style: fontStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                      width(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  userName,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                width(width: 4),
                                                Center(
                                                  child: Text(
                                                    "•",
                                                    textAlign: TextAlign.center,
                                                    style: fontStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                width(width: 4),
                                                Center(
                                                  child: Text(
                                                    formatTimeDifference(
                                                      comment.createdAt.toIso8601String(),
                                                      isComment: true,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    style: fontStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            height(height: 8),
                                            ExpandableTextWidget(
                                              text: comment.text,
                                            ),
                                            height(height: 8),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),

                // Comment Input Field
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, left: 12, right: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: newsPostsProvider.sendCommentLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        )
                                      : const Icon(Icons.send, color: Colors.red),
                                  onPressed: newsPostsProvider.sendCommentLoading
                                      ? null
                                      : () async {
                                          bool isLogin = await isUserLoggedIn();
                                          if (isLogin) {
                                            final text = controller.text.trim();
                                            if (text.isEmpty) return;
                                            controller.clear();
                                            EventRepo().addEvent({
                                              "commented": text,
                                              "postId": widget.postId.toString(),
                                              "createAt": DateTime.now().toString(),
                                              "postTitle": widget.postTitle.toString()
                                            }, "commented_article");
                                            await newsPostsProvider.sendCommentsOnPost(
                                              widget.postId,
                                              text,
                                            );
                                          } else {
                                            if (context.mounted) {
                                              try {
                                                context.read<HomeProvider>().isPlayingYoutube(false);
                                              } catch (_) {}
                                              try {
                                                context.read<VideoProvider>().pauseVideo();
                                              } catch (_) {}
                                              Navigator.pop(context);
                                              context.read<AuthenticationProvider>().newAppLoginStatus = NewAppLoginStatus.login;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LoginBackgroundView(),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

class ExpandableTextWidget extends StatefulWidget {
  final String text;

  const ExpandableTextWidget({super.key, required this.text});

  @override
  ExpandableTextWidgetState createState() => ExpandableTextWidgetState();
}

class ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure text overflow dynamically
        final textSpan = TextSpan(
          text: widget.text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        );

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 4, // Check overflow for 4 lines
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, expanded, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                  maxLines: expanded ? null : 4, // Initially collapsed
                  overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (isOverflowing) // Show "Read More" only if needed
                  GestureDetector(
                    onTap: () {
                      isExpanded.value = !isExpanded.value;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        expanded ? "Show Less" : "Read More",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
