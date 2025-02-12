import 'dart:developer';

import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_loading_screen.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import 'botton_actions.dart';

class PostBottomActions extends StatelessWidget {
  final FlipProvider flipProvider;
  final HomeScreenModel article;
  final ScreenshotController screenshotController;
  const PostBottomActions({super.key,required this.flipProvider,required this.article,required this.screenshotController});

  @override
  Widget build(BuildContext context) {
    return   Container(
      color: Colors.white,
      height: 50,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          flipProvider.isRefresh
              ? const Center(
            child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator()),
          )
              : BottomActions(
              icon:
              "assets/svg/reload.svg",
              label: 'రిలోడ్ ',
              onTap: () {
                log("Refresh");
                flipProvider.getArticles(
                    refresh:
                    true);
              }),
          BottomActions(
              icon: "assets/svg/like.svg",
              label: 'లైక్',
              isLike: flipProvider.isLikeList.contains(article.id.toString())?true:false,
              onTap: () {
                log(
                  "Like",
                );
                flipProvider.isLikePost(article.id.toString());
                // setState(() {
                //   isLike = !isLike;
                // });
              }),
          BottomActions(
              icon:
              "assets/svg/comment.svg",
              label: 'కామెంట్',
              onTap: () async {
                log("Comment");
                SharedPreferences
                sharedPreferences =
                await SharedPreferences
                    .getInstance();
                String loginId =
                    sharedPreferences
                        .getString(
                        "loginId") ??
                        "";
                log(loginId.toString());
                if (loginId.isNotEmpty) {
                  flipProvider
                      .getAllPostById(
                      article.id)
                      .then((value) =>
                      showComments(
                          context,
                          article
                              .id
                              .toString()));
                } else {
                  CustomToast.showInfoToast(
                      msg:
                      "Please Login And Continue");
                }
              }),
          BottomActions(
              icon:
              "assets/svg/share.svg",
              label: ' షేర్',
              onTap: () async {
                flipProvider
                    .takeScreenshotAndShare(
                    article,
                    screenshotController);

              }),
        ],
      ),
    );
  }
}
