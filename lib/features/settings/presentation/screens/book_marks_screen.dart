import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/features/reels/presentation/widgets/individual_reel_post.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SavedArticles extends StatefulWidget {
  const SavedArticles({super.key});

  @override
  State<SavedArticles> createState() => _SavedArticlesState();
}

class _SavedArticlesState extends State<SavedArticles> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().getAllBookMarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),
        centerTitle: false,
        title: Text(
          "Bookmarks",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (_, settingsProvider, __) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: settingsProvider.isBookMarkLoading
                ? AppLoadingScreen()
                : settingsProvider.getAllBookmarkList.isEmpty
                    ? AppNoData()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: settingsProvider.getAllBookmarkList.length,
                        itemBuilder: (context, index) {
                          final article = settingsProvider.getAllBookmarkList[index];
                          log(article.title);

                          return InkWell(
                            onTap: () {
                              if (article.type.toString() == "Reels") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReelsCardView(
                                              postId: article.postId.toString(),
                                            )));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IndividualPostView1(
                                        postId: article.postId.toString(),
                                        isComeFrom: true,
                                      ),
                                    ));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                                  child: Stack(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 100,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                  imageUrl: article.imageUrl.toString(),
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 80,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) => Container(
                                                        color: AppColors.borderColor.withValues(alpha: .2),
                                                      ),
                                                  errorWidget: (context, url, error) {
                                                    log(error.toString());
                                                    return Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 80,
                                                        color: Colors.grey.shade300,
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                          width(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    article.type.toString(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                ),
                                                height(height: 6),
                                                Text(
                                                  article.title.toString(),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: newAppFont(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                height(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.access_time_outlined, color: Colors.grey.shade700, size: 16),
                                                    width(width: 4.w),
                                                    Text(
                                                      " ${formatTimeDifference(article.created.toString())}",
                                                      style: fontStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            settingsProvider.saveBookmarks(article.postId, context, 0).then(
                                              (value) {
                                                settingsProvider.getAllBookMarks();
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.appButtonColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.bookmark,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
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
