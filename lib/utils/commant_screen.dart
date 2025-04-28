import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_background_view.dart';
import 'package:chotanews/aggricator_screens/home_screen/news_posts_provider.dart';
import 'package:chotanews/screens/home_screen/home_models/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/local_data.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globel_keys/app_router.dart';
import 'app_enums.dart';
import 'date_format.dart';

void showComments(BuildContext context,  postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows BottomSheet to resize with keyboard
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom, // Push above keyboard
        ),
        child: CommentSection(postId: postId),
      );
    },
  );
}

class CommentSection extends StatefulWidget {
  final  postId;

  const CommentSection({super.key, required this.postId});

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
    EdgeInsets gestureInsets = MediaQuery.of(context).systemGestureInsets;

    String navigationMode = (gestureInsets.bottom > 0) ? "Gesture" : "Button";
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
                              itemCount: newsPostsProvider.getAllCommentsList
                                  .length,
                              itemBuilder: (context, index) {
                                var filteredComments = newsPostsProvider
                                    .getAllCommentsList.toList();

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // User Avatar
                                      CircleAvatar(
                                        child: Text(
                                          filteredComments[index].user.name ==
                                                  ""
                                              ? "U"
                                              : filteredComments[index]
                                                      .user
                                                      .name
                                                      .toString()
                                                      .split("")
                                                      .first
                                                      .toString() ??
                                                  "U",
                                          style: fontStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                      width(width: 10),
                                      // Comment Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  filteredComments[index]
                                                              .user
                                                              .name ==
                                                          ""
                                                      ? "User"
                                                      : filteredComments[index]
                                                          .user
                                                          .name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                width(width: 4),
                                                Center(
                                                  child: Text(
                                                    formatTimeDifference(
                                                      filteredComments[index]
                                                          .createdAt
                                                          .toString(),
                                                      isComment: true,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    style: fontStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            height(height: 8),
                                            ExpandableTextWidget(
                                              text:
                                                  filteredComments[index].text,
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
                  padding:  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom,left: 12),

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
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () async {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          bool isLogin = sp.getString("loginType").toString() == "login"?true:false??false;
                          if (isLogin) {
                            if (controller.text.isEmpty) {
                            } else {
                              newsPostsProvider
                                  .sendCommentsOnPost(
                                      widget.postId, controller.text)
                                  .then(
                                    (value) => controller.text = '',
                                  );
                            }
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context, MaterialPageRoute(builder: (context) => LoginBackgroundView(),),(route) => false,);
                          }
                        },
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
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;
  bool isOverflowing = false;

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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
              maxLines: isExpanded ? null : 4, // Initially collapsed
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isOverflowing) // Show "Read More" only if needed
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? "Show Less" : "Read More",
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
  }
}

