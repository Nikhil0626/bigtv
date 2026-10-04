import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/reels/data/models/reels_model.dart';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/botton_actions.dart';
import 'package:chotanews/utils/commant_screen.dart';
import 'package:chotanews/utils/in_app_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ReelPreviewScreen extends StatefulWidget {
  final int initialIndex;

  const ReelPreviewScreen({super.key, required this.initialIndex});

  @override
  ReelPreviewScreenState createState() => ReelPreviewScreenState();
}

class ReelPreviewScreenState extends State<ReelPreviewScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  final Map<int, VideoPlayerController> _networkControllers = {};
  final Map<int, YoutubePlayerController> _youtubeControllers = {};
  final Map<int, bool> _initializingIndices = {};

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reelsList = context.read<ReelsProviders>().getAllReelsList;
      _preloadControllers(currentIndex, reelsList);
    });
  }

  String? _getYoutubeId(String url) {
    if (url.isEmpty) return null;
    final ytId = YoutubePlayer.convertUrlToId(url);
    if (ytId != null && ytId.isNotEmpty) return ytId;
    final regExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|shorts\/))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  Future<void> _preloadControllers(int index, List<ReelsModel> reels) async {
    if (reels.isEmpty) return;

    // Target active reel + adjacent reels to buffer in memory
    final targetIndices = [index, index + 1, index + 2, index - 1];

    // Clean up far away controllers to save memory
    final keysToDispose = _networkControllers.keys
        .where((k) => !targetIndices.contains(k))
        .toList();
    for (final k in keysToDispose) {
      _networkControllers[k]?.dispose();
      _networkControllers.remove(k);
    }

    final ytKeysToDispose = _youtubeControllers.keys
        .where((k) => !targetIndices.contains(k))
        .toList();
    for (final k in ytKeysToDispose) {
      _youtubeControllers[k]?.dispose();
      _youtubeControllers.remove(k);
    }

    // Pre-initialize target controllers
    for (final idx in targetIndices) {
      if (idx < 0 || idx >= reels.length) continue;
      if (_networkControllers.containsKey(idx) ||
          _youtubeControllers.containsKey(idx) ||
          _initializingIndices[idx] == true) {
        continue;
      }

      _initializingIndices[idx] = true;
      final videoUrl = reels[idx].videoUrl.trim();
      final ytId = _getYoutubeId(videoUrl);

      if (ytId != null && ytId.isNotEmpty) {
        try {
          final controller = YoutubePlayerController(
            initialVideoId: ytId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              forceHD: true,
              loop: false,
              disableDragSeek: true,
              enableCaption: false,
              controlsVisibleAtStart: false,
            ),
          );
          _youtubeControllers[idx] = controller;
          _initializingIndices.remove(idx);
          if (idx == currentIndex && mounted) {
            controller.play();
            setState(() {});
          }
        } catch (e) {
          log("Error initializing YT controller $idx: $e");
          _initializingIndices.remove(idx);
        }
      } else if (videoUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(videoUrl);
          final controller = VideoPlayerController.networkUrl(uri);
          await controller.initialize();
          controller.setLooping(true);
          _networkControllers[idx] = controller;
          _initializingIndices.remove(idx);

          if (idx == currentIndex && mounted) {
            controller.play();
            setState(() {});
          } else {
            controller.pause();
          }
        } catch (e) {
          log("Error pre-initializing network video controller $idx ($videoUrl): $e");
          _initializingIndices.remove(idx);
        }
      } else {
        _initializingIndices.remove(idx);
      }
    }
  }

  void _onPageSwiped(int newIndex, List<ReelsModel> reelsList) {
    // Pause previous active controllers
    _networkControllers[currentIndex]?.pause();
    _youtubeControllers[currentIndex]?.pause();

    setState(() {
      currentIndex = newIndex;
    });

    // Play new active controller instantly (0 latency!)
    if (_networkControllers.containsKey(newIndex)) {
      _networkControllers[newIndex]?.play();
    }
    if (_youtubeControllers.containsKey(newIndex)) {
      _youtubeControllers[newIndex]?.play();
    }

    // Trigger preloader for next upcoming reels
    _preloadControllers(newIndex, reelsList);

    // Track analytics
    if (newIndex < reelsList.length) {
      EventRepo().addEvent({
        "postid": reelsList[newIndex].id,
        "createAt": DateTime.now().toString(),
        "postTitle": reelsList[newIndex].title.toString(),
      }, "reel_viewed");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _networkControllers.values) {
      c.dispose();
    }
    for (final c in _youtubeControllers.values) {
      c.dispose();
    }
    _networkControllers.clear();
    _youtubeControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ReelsProviders>(
        builder: (_, reelsProviders, __) {
          final reelsList = reelsProviders.getAllReelsList;
          if (reelsList.isEmpty) {
            return const Center(
              child: Text(
                "No reels found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reelsList.length,
            onPageChanged: (value) {
              context.read<HomeProvider>().flipEvent(
                    'reel',
                    reelsList[value].id,
                    value > currentIndex ? false : true,
                  );
              _onPageSwiped(value, reelsList);
            },
            itemBuilder: (context, index) {
              final reel = reelsList[index];
              final videoController = _networkControllers[index];
              final ytController = _youtubeControllers[index];

              return ReelsCardView(
                reelCard: reel,
                videoController: videoController,
                youtubeController: ytController,
                isCurrentPage: index == currentIndex,
                onVideoEnded: () {
                  if (index < reelsList.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ReelsCardView extends StatefulWidget {
  final ReelsModel reelCard;
  final VideoPlayerController? videoController;
  final YoutubePlayerController? youtubeController;
  final bool isCurrentPage;
  final VoidCallback? onVideoEnded;

  const ReelsCardView({
    super.key,
    required this.reelCard,
    this.videoController,
    this.youtubeController,
    this.isCurrentPage = true,
    this.onVideoEnded,
  });

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> {
  ScreenshotController sc = ScreenshotController();

  Widget _buildVideoBody(BuildContext context) {
    // 1. Direct Network Video Player (pre-buffered from user server)
    if (widget.videoController != null &&
        widget.videoController!.value.isInitialized) {
      return Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          widget.videoController!
              .setVolume(homeProvider.isMuted ? 0.0 : 1.0);
          final size = widget.videoController!.value.size;
          final double vWidth = size.width > 0 ? size.width : 9;
          final double vHeight = size.height > 0 ? size.height : 16;

          return GestureDetector(
            onTap: () {
              if (widget.videoController!.value.isPlaying) {
                widget.videoController!.pause();
              } else {
                widget.videoController!.play();
              }
            },
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: vWidth,
                  height: vHeight,
                  child: VideoPlayer(widget.videoController!),
                ),
              ),
            ),
          );
        },
      );
    }

    // 2. YouTube Video Player
    if (widget.youtubeController != null) {
      return Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          if (homeProvider.isMuted) {
            widget.youtubeController!.mute();
          } else {
            widget.youtubeController!.unMute();
          }
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 9,
                height: 16,
                child: YoutubePlayer(
                  controller: widget.youtubeController!,
                  aspectRatio: 9 / 16,
                  bufferIndicator: const Align(
                    alignment: Alignment.bottomCenter,
                    child: LinearProgressIndicator(
                      color: Colors.red,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // 3. Instant Thumbnail Cover (Fills screen without cropping or top/bottom black bars)
    if (widget.reelCard.thumbnailUrl.isNotEmpty) {
      return SizedBox.expand(
        child: CachedNetworkImage(
          imageUrl: widget.reelCard.thumbnailUrl,
          fit: BoxFit.fill,
          placeholder: (_, __) => Container(color: Colors.black),
          errorWidget: (_, __, ___) => Container(color: Colors.black),
        ),
      );
    }

    return Container(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Screenshot(
            controller: sc,
            child: _buildVideoBody(context),
          ),
        ),
        Positioned(
          bottom: 65,
          left: 0,
          right: 80,
          child: Container(
            padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.reelCard.title,
                  style: newAppFont(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                height(height: 10.h),
                Row(
                  children: [
                    if (widget.reelCard.publisherImage.isNotEmpty) ...[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InAppWebViewScreen(
                                webUrl: "https://www.youtube.com",
                                title: "Videos",
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            child: CachedNetworkImage(
                              imageUrl: widget.reelCard.publisherImage,
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
                    ],
                    if (widget.reelCard.publisher.isNotEmpty)
                      Text(
                        widget.reelCard.publisher,
                        style: fontStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomActions(
                iconColor: Colors.white,
                postType: widget.reelCard.postName,
                icon: context
                        .read<ReelsProviders>()
                        .isLikeList
                        .contains(widget.reelCard.id.toString())
                    ? "assets/svg/like_full.svg"
                    : "assets/svg/like.svg",
                label: 'లైక్',
                isLike: context
                    .read<ReelsProviders>()
                    .isLikeList
                    .contains(widget.reelCard.id.toString()),
                onTap: () async {
                  log("Like");
                  context.read<ReelsProviders>().isLikePost(widget.reelCard);
                  EventRepo().addEvent({
                    "like": !context
                        .read<ReelsProviders>()
                        .isLikeList
                        .contains(widget.reelCard.id.toString()),
                    "postId": widget.reelCard.id.toString(),
                    "createAt": DateTime.now().toString(),
                    "postTitle": widget.reelCard.title.toString()
                  }, "liked_article");
                },
              ),
              height(height: 20),
              BottomActions(
                postType: "",
                icon: "assets/svg/new_comment.svg",
                label: 'కామెంట్',
                iconColor: Colors.white,
                onTap: () async {
                  context.read<AuthenticationProvider>().sendEvent("CommentPage");
                  showComments(
                      context, widget.reelCard.id.toString(), widget.reelCard.title.toString());
                },
              ),
              height(height: 20),
              BottomActions(
                postType: "",
                icon: "assets/svg/share.svg",
                label: 'షేర్',
                iconColor: Colors.white,
                onTap: () async {
                  log("Share Reel button tapped: ${widget.reelCard.id}");

                  final Size size = MediaQuery.of(context).size;
                  final Rect shareOrigin =
                      Rect.fromLTWH(0, 0, size.width, size.height / 2);

                  final String title = widget.reelCard.title.trim();
                  final String videoUrl = widget.reelCard.videoUrl.trim();
                  final String fallbackUrl =
                      "https://www.bigtv24x7.com/posts?postId=${widget.reelCard.id}";
                  final String shareLink =
                      videoUrl.isNotEmpty ? videoUrl : fallbackUrl;
                  final String shareText =
                      title.isNotEmpty ? "$title\n\n$shareLink" : shareLink;

                  try {
                    await Share.share(
                      shareText,
                      sharePositionOrigin: shareOrigin,
                    );
                  } catch (e) {
                    log("Error in Share.share: $e");
                    try {
                      await Share.share(shareText);
                    } catch (err) {
                      log("Fallback Share.share failed: $err");
                    }
                  }

                  EventRepo().addEvent({
                    "share": "reels",
                    "postId": widget.reelCard.id.toString(),
                    "createAt": DateTime.now().toString(),
                    "postTitle": widget.reelCard.title.toString()
                  }, "shared_article");

                  try {
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    String? userId = sp.getString("userId");
                    sendShareDetails(
                        userId, widget.reelCard.id, widget.reelCard.content.toString());
                  } catch (e) {
                    log("Error sending share details: $e");
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}