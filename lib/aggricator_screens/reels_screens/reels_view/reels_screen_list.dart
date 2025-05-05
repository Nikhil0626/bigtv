import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_models/reels_model.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/home_screen/botton_actions.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';

class ReelsScreenList extends StatefulWidget {
  const ReelsScreenList({super.key});

  @override
  State<ReelsScreenList> createState() => _ReelsScreenListState();
}

class _ReelsScreenListState extends State<ReelsScreenList> {

  @override
  void initState() {
    if(context.read<ReelsProviders>().getAllReelsList.isEmpty){
      context.read<ReelsProviders>().getAllReelsList = [];
      context.read<ReelsProviders>().getAllReels();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ReelsProviders>(
        builder: (_,reelsProviders,__) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GridView.builder(
              itemCount: reelsProviders.getAllReelsList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemBuilder: (context, index) {
                final card = reelsProviders.getAllReelsList[index];
                return ReelsListViewCard(card: card,index: index, );
              },
            ),
          );
        }
      ),
    );
  }
}


class ReelsListViewCard extends StatefulWidget {
  final ReelsModel card;
  final int index;
  const ReelsListViewCard({super.key,required this.card,required this.index});

  @override
  State<ReelsListViewCard> createState() => _ReelsListViewCardState();
}

class _ReelsListViewCardState extends State<ReelsListViewCard> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelPreviewScreen(
                  initialIndex: widget.index,
                ),
              ));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r), // Fully rounded card
          child: Stack(
            children: [
              // Thumbnail Image with Rounded Corners
              CachedNetworkImage(
                imageUrl: widget.card.thumbnailUrl,
                fit: BoxFit.cover, // Ensure image fills the card
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: Colors.red),
              ),
              // Dark Gradient Overlay at Bottom for better text visibility
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title (Main Text)
                      Text(
                        widget.card.content ?? "No title",
                        style: newAppFont(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height(height: 6.h),

                      Row(
                        children: [
                          width(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InAppWebViewScreen(
                                      webUrl: "https://www.youtube.com",
                                      title: "Videos",
                                    ),
                                  ));
                            },
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.card.publisherImage,
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.borderColor.withOpacity(.2),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 30,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          width(width: 6.h),
                          Text(
                            widget.card.publisher,
                            style: fontStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          BottomActions(
                            postType: "",
                            icon: "assets/svg/share.svg",
                            label: 'షేర్',
                            iconColor: Colors.white,
                            onTap: () async {
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              String? userId = sp.getString("userId");
                              String? deviceId = sp.getString("deviceId");
                              EventRepo().sendEvent({
                                "key": "share_via_articles",
                                "data": {
                                  "device_id": "$deviceId",
                                  "userId": userId ?? "",
                                  "postId": widget.card.id.toString(),
                                  "isWhatAppShare": false,
                                  "source_from":"reel"
                                }
                              });

                              sendShareDetails(userId, widget.card.id, widget.card.content.toString());

                              try {
                                final image = await screenshotController.capture(
                                  pixelRatio: 2,
                                );
                                if (image != null) {
                                  final directory = await getTemporaryDirectory();
                                  final imagePath = '${directory.path}/${widget.card.id}.png';
                                  final imageFile = File(imagePath);
                                  await imageFile.writeAsBytes(image);

                                  Share.shareXFiles([XFile(imageFile.path)], text: widget.card.videoUrl);
                                } else {
                                  CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                                }
                              } catch (e) {
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bookmark Icon (Top-Right)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Consumer<ReelsProviders>(builder: (_, homeProvider, __) {
                  return GestureDetector(
                    onTap: () {
                      context.read<ReelsProviders>().isBookMarkPost(  widget.card,context);

                      print("");
                    },
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (homeProvider.isBookMark.contains(widget.card.id.toString()) || widget.card.isBookmarked == 1)
                            ? AppColors.appButtonColor
                            : Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (homeProvider.isBookMark.contains(widget.card.id.toString()) ||  widget.card.isBookmarked == 1) ? Icons.bookmark : Icons.bookmark_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                }),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
