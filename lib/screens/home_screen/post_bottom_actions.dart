import 'dart:developer';

import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/Auth_module/auth_provider.dart';
import 'package:chotanews/screens/Auth_module/auth_screen.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/screens/videos_main/videos_model/videos_model.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/image_to_pdf_helper.dart';
import '../../services/local_data.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
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

        InkWell(
        onTap: () {
          log("Refresh");
          flipProvider.getArticles(
              refresh:
              true);
        },
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              height(height: 2),

              flipProvider.isRefresh?const SizedBox(
                  height: 20,
                  width: 20,
                  child: AppLoadingScreen()):  SvgPicture.asset("assets/svg/reload.svg",
                    height: 20,
                    width: 20,
                    color: postType=="BigBlackStandard"?Colors.white:Colors.grey[600]
                ),
              height(height: 4),
              Text(
                "రిలోడ్",
                style: fontStyle(fontSize: 14,
                    color: postType=="BigBlackStandard"?Colors.white:Colors.grey[600]
                ),
              ),
            ],
          ),
        ),
      ),

          BottomActions(
              postType: postType,
              icon: flipProvider.isLikeList.contains(article.id.toString())?"assets/svg/like_full.svg":"assets/svg/like.svg",
              label: 'లైక్',
              isLike: flipProvider.isLikeList.contains(article.id.toString())?true:false,
              onTap: () {
                log(
                  "Like",
                );
                flipProvider.isLikePost(article.id.toString());
              }),
          BottomActions(
              postType: postType,
              icon:
              "assets/svg/comment.svg",
              label: 'కామెంట్',
              onTap: () async {
                log("Comment --- ${context.read<AuthProvider>().loginType}");
                showComments(context, article.id.toString());

              }),

          BottomActions(
              postType: postType,
              icon:
              "assets/svg/share.svg",
              label: ' షేర్',
              onTap: () async {
                // final DynamicLinkParameters parameters = DynamicLinkParameters(
                //   uriPrefix: 'https://chotanews.page.link', // Make sure this matches Firebase Console
                //   link: Uri.parse('https://chotanews.com/store?postId=${article.id}'), // Ensure this is a valid URL
                //   androidParameters: const AndroidParameters(
                //     packageName: 'com.chotanews', // Ensure this matches your AndroidManifest.xml
                //   ),
                //   iosParameters: const IOSParameters(
                //     bundleId: 'com.chotanewstelugu.app', // Ensure this matches Firebase Console
                //     appStoreId: '1631068092',
                //   ),
                // );
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
    return   Consumer<FlipProvider>(
      builder: (_,flipProvider,__) {
        return Container(
          color: Colors.white,
          height: 50,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [
              BottomActions(
                  postType: "",
                  icon: flipProvider.isLikeList.contains(article.id.toString())?"assets/svg/like_full.svg":"assets/svg/like.svg",
                  label: 'లైక్',
                  isLike: flipProvider.isLikeList.contains(article.id.toString())?true:false,
                  onTap: () {
                    log(
                      "Like",
                    );
                    flipProvider.isLikePost(article.id.toString());
                  }),
              BottomActions(
                  postType: "",
                  icon:
                  "assets/svg/comment.svg",
                  label: 'కామెంట్',
                  onTap: () async {
                    LoginStatus  loginStatus  = await getLoginStatus();
                    log("Comment --- ${loginStatus}");
                    if (loginStatus == LoginStatus.login) {
                      showComments(context, article.id.toString(),
                      );
                    } else {
                      Navigator.pushNamed(
                          context,
                          RoutesManager.signInScreen
                      );
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
    );
  }
}