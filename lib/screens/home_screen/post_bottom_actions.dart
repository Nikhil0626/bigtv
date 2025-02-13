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

class PostBottomActions extends StatefulWidget {
  final FlipProvider flipProvider;
  final HomeScreenModel article;
  final ScreenshotController screenshotController;
  const PostBottomActions({super.key, required this.flipProvider, required this.article, required this.screenshotController});

  @override
  _PostBottomActionsState createState() => _PostBottomActionsState();
}

class _PostBottomActionsState extends State<PostBottomActions> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isVisible ? 50 : 0,
      color: Colors.white,
      child: _isVisible
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          widget.flipProvider.isRefresh
              ? const Center(
            child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
          )
              : BottomActions(
              icon: "assets/svg/reload.svg",
              label: 'రిలోడ్ ',
              onTap: () {
                log("Refresh");
                widget.flipProvider.getArticles(refresh: true);
              }),
          BottomActions(
              icon: "assets/svg/like.svg",
              label: 'లైక్',
              isLike: widget.flipProvider.isLikeList.contains(widget.article.id.toString()),
              onTap: () {
                log("Like");
                widget.flipProvider.isLikePost(widget.article.id.toString());
              }),
          BottomActions(
              icon: "assets/svg/comment.svg",
              label: 'కామెంట్',
              onTap: () async {
                log("Comment");
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                String loginId = sharedPreferences.getString("loginId") ?? "";
                log(loginId.toString());
                if (loginId.isNotEmpty) {
                  widget.flipProvider.getAllPostById(widget.article.id).then((value) => showComments(context, widget.article.id.toString()));
                } else {
                  CustomToast.showInfoToast(msg: "Please Login And Continue");
                }
              }),
          BottomActions(
              icon: "assets/svg/share.svg",
              label: ' షేర్',
              onTap: () async {
                widget.flipProvider.takeScreenshotAndShare(widget.article, widget.screenshotController);
              }),
        ],
      )
          : null,
    );
  }
}
