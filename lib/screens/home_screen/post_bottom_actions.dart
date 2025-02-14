import 'dart:developer';

import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/screens/videos_main/videos_model/videos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/image_to_pdf_helper.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_toasts.dart';
import '../../utils/commant_screen.dart';
import 'botton_actions.dart';

class PostBottomActions extends StatelessWidget {
  final String postType;
  final FlipProvider flipProvider;
  final HomeScreenModel article;
  final ScreenshotController screenshotController;
  const PostBottomActions({super.key,required this.flipProvider,required this.article,required this.screenshotController,this.postType =""});

  @override
  Widget build(BuildContext context) {
    return   Container(
      color:postType == "BigBlackStandard" ?Colors.black:Colors.white,
      height: 50,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          flipProvider.isRefresh
              ? const AppLoadingScreen()
              : BottomActions(
            postType: postType,
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
              postType: postType,
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
              postType: postType,
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
                        "loginId").toString() ;
                log(loginId.toString());
                if (loginId.isNotEmpty && loginId != "Skip" ) {
                  flipProvider
                      .getAllPostById(
                      article.id);
                  showComments(
                      context,
                      article
                          .id
                          .toString());
                } else {
                  CustomToast.showInfoToast(
                      msg:
                      "Please Login And Continue");
                }
              }),

          BottomActions(
              postType: postType,
              icon:
              "assets/svg/share.svg",
              label: ' షేర్',
              onTap: () async {
                if(article.type=="Standard"){
                  takeScreenshotAndShare(article,screenshotController);
                }else if(article.type=="Image"){
                  takeScreenshotAndShare(article,screenshotController);
                  // convertImageUrlToPdfAndShare(context,article);
                }else if(article.type == "Gallery"){
                  createAndSharePdf(context,article);
                }

              }),
        ],
      ),
    );
  }
}


class GalleryPostBottomActions extends StatelessWidget {
  final  article;
  final bool isHome;
  const GalleryPostBottomActions({super.key,required this.article,this.isHome = false});

  @override
  Widget build(BuildContext context) {
    return   Container(
      color: Colors.white,
      height: 50,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          BottomActions(
              postType: "",
              icon: "assets/svg/like.svg",
              label: 'లైక్',
              isLike:  context.watch<FlipProvider>().isLikeList.contains(article.id.toString())?true:false,
              onTap: () {
                log(
                  "Like",
                );
                context.read<FlipProvider>().isLikePost(article.id.toString());

              }),
          BottomActions(
              postType: "",
              icon:
              "assets/svg/comment.svg",
              label: 'కామెంట్',
              onTap: () async {
                log("Comment");
                SharedPreferences
                sharedPreferences =
                await SharedPreferences
                    .getInstance();
                String  loginId =
                    sharedPreferences
                        .getString(
                        "loginId").toString();
                log(loginId.toString());
                if (loginId.isNotEmpty && loginId != "Skip" ) {
                  context.read<FlipProvider>()
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
              postType: "",
              icon:
              "assets/svg/share.svg",
              label: ' షేర్',
              onTap: () async {
                if(article.type == "Gallery"){
                  createAndSharePdf(context,article);
                }

              }),
        ],
      ),
    );
  }
}