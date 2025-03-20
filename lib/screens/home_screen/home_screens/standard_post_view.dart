// import 'dart:developer';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_fonts.dart';
// import '../../../utils/app_spaces.dart';
// import '../../../utils/app_toasts.dart';
// import '../../../utils/date_format.dart';
// import '../../videos_main/video_views/video_preview.dart';
// import '../home_models/home_screen_model.dart';
//
// class StandardPostView extends StatefulWidget {
//   final article;
//   final isFoldable;
//   const StandardPostView({super.key,required this.article,required this.isFoldable});
//
//   @override
//   State<StandardPostView> createState() => _StandardPostViewState();
// }
//
// class _StandardPostViewState extends State<StandardPostView> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: widget.article.subType ==
//           "BigBlackStandard"
//           ? Colors.black
//           : Colors.white,
//       height:
//       MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       child: Column(
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment:
//         CrossAxisAlignment.start,
//         children: [
// Expanded
// (
// // height: MediaQuery.of(context).size.height/2.35,
//
// child:
// ),
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding:
//               const EdgeInsets.symmetric(
//                   vertical: 8.0,
//                   horizontal: 16.0),
//               child: Column(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//                 mainAxisAlignment:
//                 MainAxisAlignment.start,
//                 children: [
//                   Text(
//                       widget.article.title ??
//                           "No Title",
//                       style: homeScreenFontStyle(
//                           color: widget.article
//                               .subType ==
//                               "BigBlackStandard"
//                               ? Colors.white
//                               : Colors.black,
//                           fontSize:
//                           Platform.isIOS
//                               ? 19
//                               : 18,
//                           fontWeight:
//                           FontWeight.bold)),
//                   height(height: 8),
//                   Expanded(
//                     child:
//                     widget.article
//                         .subType ==
//                         "BulletPost"
//                         ? Column(
//                       mainAxisAlignment:
//                       MainAxisAlignment
//                           .start,
//                       crossAxisAlignment:
//                       CrossAxisAlignment
//                           .start,
//                       children: [
//                         (widget.article
//                             .content !=
//                             "")
//                             ? Text(
//                             widget
//                                 .article
//                                 .content,
//                             style:
//                             homeScreenFontStyle(
//                               color:
//                               Colors.black,
//                               fontWeight:
//                               FontWeight.w500,
//                               fontSize:
//                               16,
//                             ))
//                             : const SizedBox
//                             .shrink(),
//                         height(
//                             height:
//                             8),
//                         Expanded(
//                           child:
//                           ListView(
//                             physics:
//                             const NeverScrollableScrollPhysics(),
//                             children: widget
//                                 .article
//                                 .bulletPoints
//                                 .map<Widget>(
//                                     (item) {
//                                   // Explicitly specify <Widget>
//                                   return Row(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.start,
//                                     children: [
//                                       const Text("• ",
//                                           textAlign: TextAlign.start,
//                                           style: TextStyle(fontSize: 30)),
//                                       // Bullet point
//                                       Expanded(
//                                         child: Text(
//                                           item,
//                                           style: homeScreenFontStyle(
//                                             color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.black,
//                                             fontWeight: FontWeight.w400,
//                                             fontSize: Platform.isIOS ? 17 : 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }).toList(), // Ensure it is converted to List<Widget>
//                           ),
//                         ),
//                         Text(
//                           '\n\nPosted ${formatTimeDifference(widget.article.created)}',
//                           style:
//                           fontStyle(
//                             fontSize:
//                             10,
//                             fontWeight:
//                             FontWeight
//                                 .w400,
//                             color: Colors
//                                 .grey,
//                           ),
//                         ),
//                       ],
//                     )
//                         : RichText(
//                       text: TextSpan(
//                         text: '',
//                         children: [
//                           ..._parseText(
//                             context,
//                             '${widget.article.content}',
//                             widget
//                                 .article
//                                 .links,
//                           ),
//                           TextSpan(
//                             text:
//                             '\n\nPosted ${formatTimeDifference(widget.article.created)}',
//                             style:
//                             fontStyle(
//                               fontSize:
//                               10,
//                               fontWeight:
//                               FontWeight.w400,
//                               color: Colors
//                                   .grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//
//

// }
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../services/image_to_pdf_helper.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
import '../../../utils/date_format.dart';
import '../../Auth_module/auth_provider/auth_provider.dart';
import '../../videos_main/video_views/video_preview.dart';
import '../botton_actions.dart';
import '../home_provider/provider.dart';
import '../home_repo/event_repo.dart';

class StandardPostView extends StatefulWidget {
  final article;
  final isFoldable;
  final FlipProvider flipProvider;
  final ScreenshotController screenshotController;
  final isAds;

  const StandardPostView({super.key, required this.article, required this.isFoldable, required this.flipProvider, required this.screenshotController, this.isAds = false});

  @override
  _StandardPostViewState createState() => _StandardPostViewState();
}

class _StandardPostViewState extends State<StandardPostView> {
  final ScreenshotController adsScreenshotController = ScreenshotController();
  bool isBookmarked = false;
  double minDragDistance = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.article.type == "Video" ? Colors.black : Colors.white,
      body: SafeArea(
        child: Consumer<FlipProvider>(builder: (_, flipProvider, __) {
          int data = (MediaQuery.of(context).size.height * 0.40).round();
          int bigData = (MediaQuery.of(context).size.height * 0.58).round();
          log("height is :  ${MediaQuery.of(context).size.width}");
          return GestureDetector(
            onVerticalDragUpdate: widget.isAds
                ? (details) {
                    if (widget.isAds) {
                      if (details.primaryDelta! > 10) {
                        // Swiping down
                        Navigator.pop(context);
                      } else if (details.primaryDelta! < -10) {
                        // Swiping up (if needed, handle separately)
                        Navigator.pop(context);
                      }
                    }
                  }
                : null,
            // onVerticalDragEnd: widget.isAds?(details){
            //     Navigator.pop(context);
            // }:null,
            child: Screenshot(
              controller: adsScreenshotController,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // IMAGE CONTAINER - 40% HEIGHT

                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: widget.article.subType == "BigBlackStandard"
                          ? bigData.toDouble()
                          :  data.toDouble() , // Image takes 40% of screen
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16.r),
                          topLeft: Radius.circular(16.r),
                        ),
                        color: Colors.black,
                      ),
                      child: widget.article.type == "Video"
                          ? Align(
                        alignment: Alignment.topCenter,
                              child: VideoPreview(
                                imageUrl: widget.article.imageUrl.url,
                                url: widget.article.videoUrl?.url ?? "",
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16.r),
                                topLeft: Radius.circular(16.r),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.article.imageUrl.url,
                                height: MediaQuery.of(context).size.height * 0.40,
                                width: MediaQuery.of(context).size.width,
                                fit: widget.isFoldable ? BoxFit.fill : BoxFit.fill,
                                placeholder: (context, url) => Container(
                                  color: AppColors.borderColor.withOpacity(.2),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    // BOTTOM CONTAINER - 60% HEIGHT
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: widget.article.subType != "BigBlackStandard" ? bigData.toDouble() : data.toDouble(), // Bottom part takes 60% of screen
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: widget.article.subType == "BigBlackStandard" ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.sp),
                            topLeft: Radius.circular(10.sp),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            height(height: 8.sp),
                            Padding(
                              padding: EdgeInsets.only(right: 16.0.sp, left: 16.0.sp, top: 16.sp),
                              child: Text(widget.article.title ?? "No Title",
                                  style: homeScreenFontStyle(
                                      color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.black.withOpacity(0.6), fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            ),
                            height(height: 6.sp),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
                                child: widget.article.subType == "BulletPost"
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          (widget.article.content != "")
                                              ? Text(widget.article.content,
                                                  style: homeScreenFontStyle(
                                                    color: Colors.black.withOpacity(0.5),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16.sp,
                                                  ))
                                              : const SizedBox.shrink(),
                                          height(height: 8.sp),
                                          Expanded(
                                            child: ListView(
                                              physics: const NeverScrollableScrollPhysics(),
                                              children: widget.article.bulletPoints.map<Widget>((item) {
                                                // Explicitly specify <Widget>
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
                                                  children: [
                                                    Text(
                                                      "● ",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: Colors.black.withOpacity(0.5), // Reduce bullet size for better alignment
                                                        height: 2, // Ensures proper line height
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.sp), // Space between bullet & text
                                                    Expanded(
                                                      child: Text(
                                                        item,
                                                        strutStyle: StrutStyle(
                                                          fontSize: 17.sp, // Match font size
                                                          height: 2.sp, // Ensures consistent line height
                                                        ),
                                                        style: homeScreenFontStyle(
                                                          color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.black.withOpacity(0.5),
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(), // Ensure it is converted to List<Widget>
                                            ),
                                          ),
                                          if (widget.article.isReporter == true)
                                            Text(
                                              '\n\nReported by ${widget.article.reportedBy.toString()}',
                                              maxLines: 1,
                                              style: fontStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          Text(
                                            '\nPosted ${formatTimeDifference(widget.article.created)}',
                                            style: fontStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          text: '',
                                          children: [
                                            ..._parseText(
                                              context,
                                              '${widget.article.content}',
                                              widget.article.links,
                                            ),
                                            if (!widget.isAds)
                                              TextSpan(
                                                text: widget.article.isReporter == true
                                                    ? '\n\nReported by ${widget.article.reportedBy.toString()}, ${formatTimeDifference(widget.article.created)}'
                                                    : '\n\nPosted ${formatTimeDifference(widget.article.created)}',
                                                style: fontStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey,
                                                ),
                                              ),

                                            // TextSpan(
                                            //   text:
                                            //   '\n\nPosted ${formatTimeDifference(widget.article.created)}',
                                            //   style: fontStyle(
                                            //     fontSize: 10.sp,
                                            //     fontWeight: FontWeight.w400,
                                            //     color: Colors.grey,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            Container(
                              color: widget.article.subType == "BigBlackStandard" ? Colors.black : Colors.white,
                              height: 45.sp,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    color: AppColors.borderColor,
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0.sp, vertical: 5.sp),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Consumer<FlipProvider>(builder: (_, flipProvider, __) {
                                          return BottomActions(
                                            postType: widget.article.subType ?? "",
                                            icon: flipProvider.isLikeList.contains(widget.article.id.toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                            label: 'లైక్',
                                            isLike: flipProvider.isLikeList.contains(widget.article.id.toString()),
                                            onTap: () {
                                              log("Like");
                                              flipProvider.isLikePost(widget.article);
                                            },
                                          );
                                        }),
                                        width(width: 20),
                                        BottomActions(
                                          postType: widget.article.subType ?? "",
                                          icon: "assets/svg/comment.svg",
                                          label: 'కామెంట్',
                                          onTap: () {
                                            context.read<AuthProvider>().sendEvent("CommentPage");
                                            EventRepo().sendEvent({
                                              "key": "comments",
                                              "data": {
                                                "device_id": "${GlobalVariables().deviceId}",
                                                "userId": context.read<FlipProvider>().userId ?? "",
                                                "postId": widget.article.id.toString(),
                                              }
                                            });
                                            log("Comment --- ${context.read<AuthProvider>().loginType}");
                                            showComments(context, widget.article);
                                            EventRepo().sendEvent({
                                              "key": "comments",
                                              "data": {"deviceId": GlobalVariables().deviceId.toString(), "openTime": DateTime.now().toString()}
                                            });
                                          },
                                        ),
                                        Spacer(),
                                        BottomActions(
                                          postType: widget.article.subType ?? "",
                                          icon: "assets/svg/share.svg",
                                          label: 'షేర్',
                                          onTap: () async {
                                            // EventRepo().sendEvent({
                                            //   "key": "share_via_articles",
                                            //   "data": {
                                            //     "device_id": "${GlobalVariables().deviceId}",
                                            //     "userId": context.read<FlipProvider>().userId ?? "",
                                            //     "postId": widget.article.id.toString(),
                                            //     "isWhatAppShare": false,
                                            //   }
                                            // });
                                            log("hello siva1");
                                            // sendShareDetails(context.read<FlipProvider>().userId, widget.article.id, widget.article.content.toString());

                                            if (widget.article.type == "Standard" || widget.article.type == "Image" || widget.article.type == "Video" ) {
                                              log("hello ddd");
                                              if (widget.isAds) {
                                                log("hello siva2");
                                                try {
                                                  final image = await adsScreenshotController.capture(
                                                    pixelRatio: 1.5,
                                                  );
                                                  if (image != null) {
                                                    final directory = await getTemporaryDirectory();
                                                    final imagePath = '${directory.path}/${widget.article.id}.png';
                                                    final imageFile = File(imagePath);
                                                    await imageFile.writeAsBytes(image);

                                                    Share.shareXFiles([XFile(imageFile.path)], text: Platform.isIOS ? widget.article.linkURLIos.toString() : widget.article.linkURLAndroid.toString());
                                                  } else {
                                                    CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                                  }
                                                } catch (e) {
                                                  CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                                }
                                              } else {
                                                log("hello siva");

                                                takeScreenshotAndShare(widget.article, widget.isAds ? adsScreenshotController : widget.screenshotController);
                                              }
                                            } else if (widget.article.type == "Gallery") {
                                              log("hello siva3");
                                              createAndSharePdf(context, widget.article);
                                            }
                                          },
                                        ),
                                        width(width: 20),
                                        if (!widget.isAds)
                                          InkWell(
                                            onTap: () {
                                              log("Refresh");
                                              EventRepo().sendEvent({
                                                "key": "reload",
                                                "data": {
                                                  "device_id": "${GlobalVariables().deviceId}",
                                                  "userId": GlobalVariables().userId ?? "",
                                                }
                                              });
                                              widget.flipProvider.getArticles(refresh: true);
                                            },
                                            child: widget.flipProvider.isRefresh
                                                ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                                                : SvgPicture.asset(
                                                    "assets/svg/reload.svg",
                                                    height: 22,
                                                    width: 22,
                                                    color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.grey,
                                                  ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: widget.article.subType != "BigBlackStandard" ? bigData.toDouble() - 16 : data.toDouble() - 16, // Half in image, half in news
                      left: 20,
                      // right: MediaQuery.of(context).size.width * 0.3,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.1),
                          //     blurRadius: 5,
                          //     spreadRadius: 2,
                          //   ),
                          // ],
                        ),
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Chota ",
                                  style: fontStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "News",
                                  style: fontStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff00A8FF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );

    //   Scaffold(
    //   backgroundColor: widget.article.subType != "BigBlackStandard"
    //       ? Colors.black
    //       : Colors.grey[200],
    //   body: SafeArea(
    //     child: GestureDetector(
    //       onVerticalDragStart: widget.isAds? (details) {
    //         if ( details.globalPosition.dy > minDragDistance) {
    //           Navigator.pop(context);
    //         }
    //       }:null,
    //       child: Column(
    //         children: [
    //           Expanded(
    //             child: Screenshot(
    //               controller: adsScreenshotController,
    //               child: Stack(
    //                 children: [

    //                   Positioned(
    //                     bottom: 0,
    //                     child: SizedBox(
    //                       height: widget.article.subType == "BigBlackStandard"
    //                           ? MediaQuery.of(context).size.height * .40
    //                           :widget.article.type == "Video"?MediaQuery.of(context).size.height * .50:MediaQuery.of(context).size.height * .58,
    //                       width: MediaQuery.of(context).size.width,
    //                       child: Stack(
    //                         children: [
    //                           Positioned(
    //                             bottom: 0,
    //                             child: Container(
    //                               alignment: Alignment.bottomCenter,
    //                               height: widget.article.subType == "BigBlackStandard"
    //                                   ? MediaQuery.of(context).size.height * .38
    //                                   : widget.article.type == "Video"?MediaQuery.of(context).size.height * .48:MediaQuery.of(context).size.height * .55,
    //                               width: MediaQuery.of(context).size.width,
    //                               decoration: BoxDecoration(
    //                                 color: widget.article.subType == "BigBlackStandard"
    //                                     ? Colors.black
    //                                     : Colors.white,
    //                                 borderRadius: BorderRadius.only(
    //                                   topRight: Radius.circular(10.sp),
    //                                   topLeft: Radius.circular(10.sp),
    //                                 ),
    //                               ),
    //                               child: Column(
    //                                 mainAxisAlignment: MainAxisAlignment.start,
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 children: [
    //                                   height(height: 8.sp),
    //                                   Padding(
    //                                     padding:  EdgeInsets.only(right: 16.0.sp,left: 16.0.sp,top: 16.sp),
    //                                     child: Text(widget.article.title ?? "No Title",
    //                                         style: homeScreenFontStyle(
    //                                             color: widget.article.subType ==
    //                                                     "BigBlackStandard"
    //                                                 ? Colors.white
    //                                                 : Colors.black.withOpacity(0.6),
    //                                             fontSize: 18.sp,
    //                                             fontWeight: FontWeight.bold)),
    //                                   ),
    //                                   height(height: 6.sp),
    //                                   Expanded(
    //                                     child: Padding(
    //                                       padding:  EdgeInsets.symmetric(horizontal: 16.0.sp),
    //                                       child: widget.article.subType == "BulletPost"
    //                                           ? Column(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment.start,
    //                                               crossAxisAlignment:
    //                                                   CrossAxisAlignment.start,
    //                                               children: [
    //                                                 (widget.article.content != "")
    //                                                     ? Text(widget.article.content,
    //                                                         style: homeScreenFontStyle(
    //                                                           color: Colors.black
    //                                                               .withOpacity(0.5),
    //                                                           fontWeight:
    //                                                               FontWeight.w500,
    //                                                           fontSize: 16.sp,
    //                                                         ))
    //                                                     : const SizedBox.shrink(),
    //                                                 height(height: 8.sp),
    //                                                 Expanded(
    //                                                   child: ListView(
    //                                                     physics:
    //                                                         const NeverScrollableScrollPhysics(),
    //                                                     children: widget
    //                                                         .article.bulletPoints
    //                                                         .map<Widget>((item) {
    //                                                       // Explicitly specify <Widget>
    //                                                       return Row(
    //                                                         crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
    //                                                         children: [
    //                                                           Text(
    //                                                             "● ",
    //                                                             style: TextStyle(
    //                                                               fontSize: 16.sp,
    //                                                               color: Colors.black.withOpacity(0.5),// Reduce bullet size for better alignment
    //                                                               height: 2, // Ensures proper line height
    //                                                             ),
    //                                                           ),
    //                                                           SizedBox(width: 5.sp), // Space between bullet & text
    //                                                           Expanded(
    //                                                             child: Text(
    //                                                               item,
    //                                                               strutStyle: StrutStyle(
    //                                                                 fontSize: 17.sp, // Match font size
    //                                                                 height: 2.sp, // Ensures consistent line height
    //                                                               ),
    //                                                               style: homeScreenFontStyle(
    //                                                                 color: widget.article.subType == "BigBlackStandard"
    //                                                                     ? Colors.white
    //                                                                     : Colors.black.withOpacity(0.5),
    //                                                                 fontWeight: FontWeight.w400,
    //                                                                 fontSize: 17.sp,
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ],
    //                                                       )
    //       ;
    //                                                     }).toList(), // Ensure it is converted to List<Widget>
    //                                                   ),
    //                                                 ),
    //                                                 if(widget.article.isReporter == true)
    //                                                 Text(
    //                                                   '\n\nReported by ${widget.article.reportedBy.toString()}',
    //                                                   maxLines: 1,
    //                                                   style: fontStyle(
    //                                                     fontSize: 10.sp,
    //                                                     fontWeight: FontWeight.w400,
    //                                                     color: Colors.grey,
    //                                                   ),
    //                                                 ),Text(
    //                                                   '\nPosted ${formatTimeDifference(widget.article.created)}',
    //                                                   style: fontStyle(
    //                                                     fontSize: 10.sp,
    //                                                     fontWeight: FontWeight.w400,
    //                                                     color: Colors.grey,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             )
    //                                           : RichText(
    //                                               text: TextSpan(
    //                                                 text: '',
    //                                                 children: [
    //                                                   ..._parseText(
    //                                                     context,
    //                                                     '${widget.article.content}',
    //                                                     widget.article.links,
    //                                                   ),
    //                                                   if(widget.article.isReporter == true)
    //                                                     TextSpan(
    //                                                       text:  '\n\nReported by ${widget.article.reportedBy.toString()}',
    //                                                       style: fontStyle(
    //                                                         fontSize: 10.sp,
    //                                                         fontWeight: FontWeight.w400,
    //                                                         color: Colors.grey,
    //                                                       ),
    //                                                     ),
    //                                                   if (!widget.isAds)
    //                                                     TextSpan(
    //                                                       text:
    //                                                           '\n\nPosted ${formatTimeDifference(widget.article.created)}',
    //                                                       style: fontStyle(
    //                                                         fontSize: 10.sp,
    //                                                         fontWeight: FontWeight.w400,
    //                                                         color: Colors.grey,
    //                                                       ),
    //                                                     ),
    //                                                 ],
    //                                               ),
    //                                             ),
    //                                     ),
    //                                   ),
    //
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                           Positioned(
    //                               top: 0,
    //                               left: widget.article.isReporter ? 10 : 20,
    //                               child: Row(
    //                                 children: [
    //                                   Container(
    //                                     margin:  EdgeInsets.all(8),
    //                                     padding:  EdgeInsets.symmetric(
    //                                         horizontal: 8),
    //                                     height: 30,
    //                                     width: 110,
    //                                     decoration:  BoxDecoration(
    //                                         color: Colors.white,
    //                                         borderRadius: BorderRadius.all(
    //                                           Radius.circular(10.r),
    //                                         )),
    //                                     child: Row(
    //                                       children: [
    //                                         Text(
    //                                           "Chota ",
    //                                           style: TextStyle(
    //                                               color: Colors.black,
    //                                               fontSize: 15,
    //                                               fontWeight: FontWeight.bold),
    //                                         ),
    //                                         Text(
    //                                           "News",
    //                                           style: TextStyle(
    //                                               color: Colors.lightBlue,
    //                                               fontSize: 16,
    //                                               fontWeight: FontWeight.bold),
    //                                         )
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ],
    //                               )),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           Container(
    //             color: Colors.white,
    //             height: 45.sp,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.spaceAround,
    //               children: [
    //                 Container(
    //                   color: AppColors.borderColor,
    //                   width: MediaQuery.of(context).size.width,
    //                   height: 1,
    //                 ),
    //
    //                 Padding(
    //                   padding:  EdgeInsets.symmetric(horizontal: 16.0.sp,vertical: 5.sp),
    //                   child: Row(
    //                     mainAxisAlignment:
    //                     MainAxisAlignment.spaceEvenly,
    //                     children: [
    //                       Consumer<FlipProvider>(
    //                           builder: (_, flipProvider, __) {
    //                             return BottomActions(
    //                               postType: widget.article.subType ?? "",
    //                               icon: flipProvider.isLikeList.contains(
    //                                   widget.article.id.toString())
    //                                   ? "assets/svg/like_full.svg"
    //                                   : "assets/svg/like.svg",
    //                               label: 'లైక్',
    //                               isLike: flipProvider.isLikeList
    //                                   .contains(
    //                                   widget.article.id.toString()),
    //                               onTap: () {
    //                                 log("Like");
    //                                 flipProvider
    //                                     .isLikePost(widget.article);
    //                               },
    //                             );
    //                           }),
    //                       width(width: 20),
    //                       BottomActions(
    //                         postType: widget.article.subType ?? "",
    //                         icon: "assets/svg/comment.svg",
    //                         label: 'కామెంట్',
    //                         onTap: () {
    //                           context
    //                               .read<AuthProvider>()
    //                               .sendEvent("CommentPage");
    //                           EventRepo().sendEvent({
    //                             "key": "comments",
    //                             "data": {
    //                               "device_id":
    //                               "${GlobalVariables().deviceId}",
    //                               "userId": context
    //                                   .read<FlipProvider>()
    //                                   .userId ??
    //                                   "",
    //                               "postId":
    //                               widget.article.id.toString(),
    //                             }
    //                           });
    //                           log("Comment --- ${context.read<AuthProvider>().loginType}");
    //                           showComments(context, widget.article);
    //                           EventRepo().sendEvent({
    //                             "key": "comments",
    //                             "data": {
    //                               "deviceId": GlobalVariables()
    //                                   .deviceId
    //                                   .toString(),
    //                               "openTime":
    //                               DateTime.now().toString()
    //                             }
    //                           });
    //                         },
    //                       ),
    //                       Spacer(),
    //                       BottomActions(
    //                         postType: widget.article.subType ?? "",
    //                         icon: "assets/svg/share.svg",
    //                         label: 'షేర్',
    //                         onTap: () {
    //
    //                           log("shares");
    //                           EventRepo().sendEvent({
    //                             "key": "share_via_articles",
    //                             "data": {
    //                               "device_id":
    //                               "${GlobalVariables().deviceId}",
    //                               "userId": context
    //                                   .read<FlipProvider>()
    //                                   .userId ??
    //                                   "",
    //                               "postId":
    //                               widget.article.id.toString(),
    //                               "isWhatAppShare": false,
    //                             }
    //                           });
    //
    //                           sendShareDetails(
    //                               context.read<FlipProvider>().userId,
    //                               widget.article.id,
    //                               widget.article.content.toString());
    //                           if (widget.article.type == "Standard" ||
    //                               widget.article.type == "Image") {
    //                             takeScreenshotAndShare(widget.article,
    //                                 widget.isAds?adsScreenshotController: widget.screenshotController);
    //                           } else if (widget.article.type ==
    //                               "Gallery") {
    //                             createAndSharePdf(
    //                                 context, widget.article);
    //                           }
    //                         },
    //                       ),
    //                       width(width: 20),
    //                       if (!widget.isAds)
    //                         InkWell(
    //                           onTap: () {
    //                             log("Refresh");
    //                             EventRepo().sendEvent({
    //                               "key": "reload",
    //                               "data": {
    //                                 "device_id":
    //                                 "${GlobalVariables().deviceId}",
    //                                 "userId":
    //                                 GlobalVariables().userId ??
    //                                     "",
    //                               }
    //                             });
    //                             widget.flipProvider
    //                                 .getArticles(refresh: true);
    //                           },
    //                           child: widget.flipProvider.isRefresh
    //                               ? const SizedBox(
    //                               height: 22,
    //                               width: 22,
    //                               child: AppLoadingScreen())
    //                               : SvgPicture.asset(
    //                             "assets/svg/reload.svg",
    //                             height: 22,
    //                             width: 22,
    //                             color: widget.article.subType ==
    //                                 "BigBlackStandard"
    //                                 ? Colors.white
    //                                 : Colors.grey,
    //                           ),
    //                         ),
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           // height(height: 5),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  List<TextSpan> _parseText(BuildContext context, String text, links) {
    RegExp linkRegExp = RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];

    text.splitMapJoin(
      linkRegExp,
      onMatch: (match) {
        String link = match.group(0)!;

        if (link.contains('<link1>')) {
          log("click linkss    ${links!.first.value.toString()}");
          link = links.first.value.toString();
        }

        if (link.contains('<link1>') && links != null && links.isNotEmpty) {
          link = links[0].value.toString();
        } else if (link.contains('<link2>') && links != null && links.length > 1) {
          link = links[1].value.toString();
        } else if (link.contains('<link3>') && links != null && links.length > 2) {
          link = links[2].value.toString();
        } else {
          link = link;
        }
        spans.add(TextSpan(
          text: match
              .group(0)
              .toString()
              .replaceFirst('<link1>', '')
              .replaceFirst('</link1>', '')
              .replaceFirst('<link2>', '')
              .replaceFirst('</link2>', '')
              .replaceFirst('<link3>', '')
              .replaceFirst('</link3>', ''),
          style: homeScreenFontStyle(
            color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              print(" $link");
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                CustomToast.showErrorToast(msg: "Could not launch $link");
              }
            },
        ));

        return "";
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(
            text: nonMatch,
            style: homeScreenFontStyle(
              color: widget.article.subType == "BigBlackStandard" ? Colors.white : Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w400,
              fontSize: 17.sp,
            )));
        return "";
      },
    );

    return spans;
  }
}
