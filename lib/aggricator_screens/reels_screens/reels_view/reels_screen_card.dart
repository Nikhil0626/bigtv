import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_models/reels_model.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_preview.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../botton_actions.dart';
import '../../event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../in_app_web_view.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/commant_screen.dart';
import '../../../utils/date_format.dart';
import '../../e_papers_screens/paper_view/papers_screen_card.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  YoutubePlayerController? _controller;
  List<ReelsModel> removedCards = [];
  Offset slideOffset = Offset.zero;
  bool isAnimating = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    context.read<ReelsProviders>().getAllReelsList = [];
    context.read<ReelsProviders>().getAllReels();
    _pageController = PageController(viewportFraction: 1.0);
  }

  void animateRemoveTopCard() async {
    if (context.read<ReelsProviders>().getAllReelsList.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, -1);
    });
    await Future.delayed(Duration(milliseconds: 600));
    setState(() {
      removedCards.add(context.read<ReelsProviders>().getAllReelsList.removeLast());
      slideOffset = Offset.zero;
      isAnimating = false;
    });
  }

  void animateUndoCard() async {
    if (removedCards.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, 1);
      context.read<ReelsProviders>().getAllReelsList.add(removedCards.removeLast());
    });

    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      slideOffset = Offset.zero;
    });

    await Future.delayed(Duration(milliseconds: 600));
    setState(() {
      isAnimating = false;
    });
  }

  final CardSwiperController controller = CardSwiperController();

  double dragOffset = 0.0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // backgroundColor: Colors.white,
      child: Consumer<ReelsProviders>(builder: (_, reelsProvider, __) {
        return reelsProvider.reelsLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CardSwiper(
                  allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                  controller: controller,
                  // Assign the controller
                  cardsCount: 5,
                  onSwipe: (previousIndex, currentIndex, direction) {
                    print("Swiped from $previousIndex to $currentIndex");
                    return true;
                  },
                  numberOfCardsDisplayed: 4,
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                    return ShimmerCard();
                  },
                ),
              )
            : reelsProvider.getAllReelsList.isEmpty
                ? AppNoData()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: CardSwiper(
                      controller: controller,
                      cardsCount: reelsProvider.getAllReelsList.length,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        if (direction == CardSwiperDirection.bottom) {
                          context.read<HomeProvider>().flipEvent('reel', reelsProvider.getAllReelsList[currentIndex!].id, false);
                          _undo();

                          return false;
                        } else {
                          context.read<HomeProvider>().flipEvent('reel', reelsProvider.getAllReelsList[currentIndex!].id, true);
                        }

                        if (currentIndex != null) {
                          currentIndexs = currentIndex;
                        }
                        debugPrint(
                          'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
                        );
                        return true;
                      },
                      // onSwipeDirectionChange:  ,
                      // onUndo: _onUndo,
                      allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
                      // allowedSwipeDirection: AllowedSwipeDirection.only(up:true),
                      numberOfCardsDisplayed: 4,
                      duration: const Duration(milliseconds: 100),
                      backCardOffset: const Offset(0, 40),
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        bottom: 40.0,
                      ),
                      // alignment: Alignment.topCenter,
                      cardBuilder: (
                        context,
                        index,
                        horizontalThresholdPercentage,
                        verticalThresholdPercentage,
                      ) {
                        final post = reelsProvider.getAllReelsList[index];

                        return EachReelCard(reel: post, reelsProvider: reelsProvider, index: index);
                      },
                    ),
                  );
      }),
    );
  }

  int currentIndexs = 0;

  void _undo() {
    if (currentIndexs > 0) {
      setState(() {
        currentIndexs--;
      });
      controller.undo();
    }
  }
}

class EachReelCard extends StatefulWidget {
  final ReelsModel reel;
  final ReelsProviders reelsProvider;
  final int index;

  EachReelCard({super.key, required this.reel, required this.reelsProvider, required this.index});

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
                color: Colors.grey.withOpacity(0.2),
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
                            color: AppColors.borderColor.withOpacity(.2),
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
                               EventRepo().addEvent({
                                "like": !widget.reelsProvider.isLikeList.contains(widget.reel.id.toString()),
                                "postId": widget.reel.id.toString()??"000",
                                "createAt": DateTime.now().toString()
                              }, "liked_article");
                            },
                          ),
                          BottomActions(
                            postType: "",
                            icon: "assets/svg/new_comment.svg",
                            label: 'కామెంట్',
                            iconColor: AppColors.iconColors,
                            onTap: () async {
                              context.read<AuthenticationProvider>().sendEvent("CommentPage");


                              showComments(context, widget.reel.id.toString());
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
                                "postId": widget.reel.id.toString()??"000",
                                "createAt": DateTime.now().toString()
                              }, "shared_article");


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
                                print("Error: $e");
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
