import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/loading_screen/home_shimmer.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/reels/data/models/reels_model.dart';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:chotanews/features/reels/presentation/widgets/reels_screen_preview.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/botton_actions.dart';
import 'package:chotanews/utils/commant_screen.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen> {
  YoutubePlayerController? _controller;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelsProviders>().getAllReelsList = [];
      context.read<ReelsProviders>().getAllReels();
    });
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ReelsProviders>(builder: (_, reelsProvider, __) {
        return reelsProvider.reelsLoading
            ? HomeShimmer()
            : reelsProvider.getAllReelsList.isEmpty
                ? AppNoData()
                : ReelPreviewScreen(initialIndex: 0);
      }),
    );
  }
}

class EachReelCard extends StatefulWidget {
  final ReelsModel reel;
  final ReelsProviders reelsProvider;
  final int index;

  const EachReelCard({super.key, required this.reel, required this.reelsProvider, required this.index});

  @override
  State<EachReelCard> createState() => _EachReelCardState();
}

class _EachReelCardState extends State<EachReelCard> {
  ScreenshotController sc = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReelPreviewScreen(
                initialIndex: widget.index,
              ),
            ));
      },
      child: Screenshot(
        controller: sc,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0.sp, vertical: 15.sp),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        child: CachedNetworkImage(
                          imageUrl: widget.reel.thumbnailUrl.toString(),
                          height: MediaQuery.of(context).size.height * .52,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: MediaQuery.of(context).size.height * .52,
                            width: MediaQuery.of(context).size.width,
                            color: AppColors.borderColor.withValues(alpha: .2),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.image,
                              size: 100.sp,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.h),
                      child: Text(
                        widget.reel.title,
                        style: homeScreenFontStyle(color: AppColors.textColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      decoration: BoxDecoration(
                          color: AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )),
                      child: Row(
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
                                  imageUrl: widget.reel.publisherImage,
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.borderColor.withValues(alpha: .2),
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
                            widget.reel.publisher,
                            style: fontStyle(
                              color: AppColors.bodyTextColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            " ● ",
                            style: fontStyle(
                              color: AppColors.borderColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            " ${formatTimeDifference(widget.reel.createdAt.toString())}",
                            style: fontStyle(fontSize: 10.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                          ),
                          width(width: 15.w),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.only(bottom: 16.h, top: 6.h, left: 10.sp, right: 10.sp),
                      decoration: BoxDecoration(
                          color: AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BottomActions(
                            iconColor: AppColors.iconColors,
                            postType: widget.reel.postName ?? "",
                            icon: widget.reelsProvider.isLikeList.contains(widget.reel.id.toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                            label: 'లైక్',
                            isLike: widget.reelsProvider.isLikeList.contains(widget.reel.id.toString()),
                            onTap: () async {
                              widget.reelsProvider.isLikePost(widget.reel);
                              log("Like");
                              EventRepo().addEvent(
                                  {
                                    "like": !widget.reelsProvider.isLikeList.contains(widget.reel.id.toString()),
                                    "postId": widget.reel.id.toString() ?? "000",
                                    "createAt": DateTime.now().toString(),
                                    "postTitle": widget.reel.title.toString(),

                                  },

                              "liked_article");
                            },
                          ),
                          BottomActions(
                            postType: "",
                            icon: "assets/svg/new_comment.svg",
                            label: 'కామెంట్',
                            iconColor: AppColors.iconColors,
                            onTap: () async {
                              context.read<AuthenticationProvider>().sendEvent("CommentPage");

                              showComments(context, widget.reel.id.toString(),widget.reel.title.toString());
                            },
                          ),
                          Spacer(),
                          BottomActions(
                            postType: "",
                            icon: "assets/svg/share.svg",
                            label: 'షేర్',
                            iconColor: AppColors.iconColors,
                            onTap: () async {
                              print("Share");

                              // ✅ Get userId first
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              String? userId = sp.getString("userId");

                              // ✅ Now it's safe to use userId
                              EventRepo().addEvent({
                                "share": "reels",
                                "postId": widget.reel.id.toString() ?? "000",
                                "createAt": DateTime.now().toString(),
                                "postTitle": widget.reel.title.toString(),
                              },
                                  "shared_article");

                              sendShareDetails(userId, widget.reel.id, widget.reel.content.toString());

                              try {
                                final image = await sc.capture(
                                  pixelRatio: 2,
                                );
                                if (image != null) {
                                  final directory = await getTemporaryDirectory();
                                  final imagePath = '${directory.path}/${widget.reel.id}.png';
                                  final imageFile = File(imagePath);
                                  await imageFile.writeAsBytes(image);

                                  Share.shareXFiles(
                                    [XFile(imageFile.path)],
                                    text: widget.reel.videoUrl,
                                  );
                                } else {
                                  CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                                }
                              } catch (e) {
                                log("Error sharing reel: $e");
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    // height(height: 20.sp)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
