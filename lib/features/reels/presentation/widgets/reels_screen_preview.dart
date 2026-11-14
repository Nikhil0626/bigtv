import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';
import 'package:chotanews/features/home/presentation/widgets/infocus_bar_widget.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/core/theme/color_tokens.dart';

class ReelPreviewScreen extends StatefulWidget {
  final int initialIndex;
  final VideoPlayerController Function(String url)? videoControllerBuilder;

  const ReelPreviewScreen({
    super.key,
    required this.initialIndex,
    this.videoControllerBuilder,
  });

  @override
  ReelPreviewScreenState createState() => ReelPreviewScreenState();
}

class ReelPreviewScreenState extends State<ReelPreviewScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  late final ValueNotifier<int> _currentIndexNotifier;
  final ValueNotifier<int> _controllersRevision = ValueNotifier<int>(0);
  bool _isAutoScrolling = false;
  ReelsProviders? _reelsProviders;
  int _localPauseGeneration = 0;
  bool _wasRouteActive = true;

  int get currentIndex => _currentIndexNotifier.value;

  final Map<int, VideoPlayerController> _networkControllers = {};
  final Map<int, YoutubePlayerController> _youtubeControllers = {};
  final Map<int, bool> _initializingIndices = {};

  DateTime? _reelStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setWakelock(enabled: true);
    _currentIndexNotifier = ValueNotifier<int>(widget.initialIndex);
    _reelStartTime = DateTime.now();
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncPauseSubscription();
      final reelsList = context.read<ReelsProviders>().getAllReelsList;
      if (reelsList.isNotEmpty && currentIndex < reelsList.length) {
        AnalyticsService.instance
            .track(AnalyticsEventName.reelOpen, properties: {
          'reel_id': reelsList[currentIndex].id,
          'position': currentIndex,
        });
        AnalyticsService.instance
            .track(AnalyticsEventName.reelPlay, properties: {
          'reel_id': reelsList[currentIndex].id,
        });
      }
      _preloadControllers(currentIndex, reelsList);
    });
  }

  void _syncPauseSubscription() {
    if (!mounted) return;
    final provider = context.read<ReelsProviders>();
    if (!identical(_reelsProviders, provider)) {
      _reelsProviders?.removePauseListener(_pauseAllControllers);
      _reelsProviders = provider;
      _reelsProviders!.addPauseListener(_pauseAllControllers);
    }
  }

  bool _isScreenActive() {
    if (!mounted) return false;
    final bool routeCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final bool tickerEnabled = TickerMode.valuesOf(context).enabled;
    return routeCurrent && tickerEnabled;
  }

  bool _canAutoPlayIndex(
    int idx, {
    required int expectedEpoch,
    required int expectedLocalGen,
  }) {
    if (!_isScreenActive()) return false;
    if (idx != _currentIndexNotifier.value) return false;
    if (expectedEpoch != (_reelsProviders?.pauseEpoch ?? expectedEpoch)) {
      return false;
    }
    return expectedLocalGen == _localPauseGeneration;
  }

  void _pauseAllControllers() {
    _localPauseGeneration++;
    _isAutoScrolling = false;
    for (final controller in _networkControllers.values) {
      if (controller.value.isInitialized) {
        try {
          controller.pause();
        } catch (_) {}
      }
    }
    for (final ytController in _youtubeControllers.values) {
      try {
        ytController.pause();
      } catch (_) {}
    }
    _setWakelock(enabled: false);
  }

  void _setWakelock({required bool enabled}) {
    try {
      if (enabled) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPauseSubscription();
    final bool isActiveNow = _isScreenActive();
    if (_wasRouteActive && !isActiveNow) {
      _pauseAllControllers();
    }
    _wasRouteActive = isActiveNow;
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
    _syncPauseSubscription();
    final int expectedEpoch = _reelsProviders?.pauseEpoch ?? 0;
    final int expectedLocalGen = _localPauseGeneration;

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
          if (_canAutoPlayIndex(
            idx,
            expectedEpoch: expectedEpoch,
            expectedLocalGen: expectedLocalGen,
          )) {
            controller.play();
          } else {
            try {
              controller.pause();
            } catch (_) {}
          }
          if (mounted) {
            _controllersRevision.value++;
          }
        } catch (e) {
          log("Error initializing YT controller $idx: $e");
          _initializingIndices.remove(idx);
        }
      } else if (videoUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(videoUrl);
          final controller = widget.videoControllerBuilder?.call(videoUrl) ??
              VideoPlayerController.networkUrl(uri);
          await controller.initialize();
          controller.setLooping(false);
          _networkControllers[idx] = controller;
          _initializingIndices.remove(idx);

          if (_canAutoPlayIndex(
            idx,
            expectedEpoch: expectedEpoch,
            expectedLocalGen: expectedLocalGen,
          )) {
            await controller.seekTo(Duration.zero);
            await controller.play();
          } else {
            await controller.pause();
            await controller.seekTo(Duration.zero);
          }
          if (mounted) {
            _controllersRevision.value++;
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
    _isAutoScrolling = false;
    final int previousIndex = _currentIndexNotifier.value;

    // Pause previous active controllers and rewind if finished
    final prevNet = _networkControllers[previousIndex];
    if (prevNet != null && prevNet.value.isInitialized) {
      prevNet.pause();
      final pos = prevNet.value.position;
      final dur = prevNet.value.duration;
      if (dur > Duration.zero &&
          pos >= dur - const Duration(milliseconds: 500)) {
        prevNet.seekTo(Duration.zero);
      }
    }
    final prevYt = _youtubeControllers[previousIndex];
    if (prevYt != null) {
      prevYt.pause();
      if (prevYt.value.playerState == PlayerState.ended) {
        prevYt.seekTo(Duration.zero);
      }
    }

    _currentIndexNotifier.value = newIndex;

    // Play new active controller only while this route and tab are active.
    if (_isScreenActive()) {
      final nextNet = _networkControllers[newIndex];
      if (nextNet != null && nextNet.value.isInitialized) {
        final pos = nextNet.value.position;
        final dur = nextNet.value.duration;
        if (dur > Duration.zero &&
            pos >= dur - const Duration(milliseconds: 500)) {
          nextNet.seekTo(Duration.zero);
        }
        nextNet.play();
      }
      final nextYt = _youtubeControllers[newIndex];
      if (nextYt != null) {
        if (nextYt.value.playerState == PlayerState.ended) {
          nextYt.seekTo(Duration.zero);
        }
        nextYt.play();
      }
    }

    // Trigger preloader for next upcoming reels
    _preloadControllers(newIndex, reelsList);

    // Track analytics
    final watchDuration = _reelStartTime != null
        ? DateTime.now().difference(_reelStartTime!).inSeconds
        : 0;

    if (previousIndex < reelsList.length) {
      AnalyticsService.instance.track(AnalyticsEventName.reelSkip, properties: {
        'reel_id': reelsList[previousIndex].id,
        'watch_duration_seconds': watchDuration,
      });
    }

    _reelStartTime = DateTime.now();

    if (newIndex < reelsList.length) {
      final newReel = reelsList[newIndex];
      AnalyticsService.instance.track(AnalyticsEventName.reelOpen, properties: {
        'reel_id': newReel.id,
        'position': newIndex,
      });
      AnalyticsService.instance.track(AnalyticsEventName.reelPlay, properties: {
        'reel_id': newReel.id,
      });
      EventRepo().addEvent({
        "postid": newReel.id,
        "createAt": DateTime.now().toString(),
        "postTitle": newReel.title.toString(),
      }, "reel_viewed");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isScreenActive()) {
        _setWakelock(enabled: true);
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pauseAllControllers();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reelsProviders?.removePauseListener(_pauseAllControllers);
    _setWakelock(enabled: false);
    _currentIndexNotifier.dispose();
    _controllersRevision.dispose();
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
      backgroundColor: InFocusBarWidget.barBackgroundColor,
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

          return AnimatedBuilder(
            animation: Listenable.merge([
              _controllersRevision,
              _currentIndexNotifier,
            ]),
            builder: (context, _) {
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: reelsList.length,
                onPageChanged: (value) {
                  _isAutoScrolling = false;
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
                    canPlayback: () =>
                        _isScreenActive() &&
                        index == _currentIndexNotifier.value,
                    onVideoEnded: () {
                      // Only permit auto-scrolling if triggered by the active visible reel!
                      if (index != currentIndex) return;
                      if (_isAutoScrolling) return;

                      if (index < reelsList.length - 1) {
                        if (_pageController.hasClients) {
                          _isAutoScrolling = true;
                          _pageController
                              .nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          )
                              .then((_) {
                            _isAutoScrolling = false;
                          }).catchError((_) {
                            _isAutoScrolling = false;
                          });
                        }
                      } else {
                        // Replay last reel from beginning
                        final lastNet = _networkControllers[index];
                        if (lastNet != null && lastNet.value.isInitialized) {
                          lastNet.seekTo(Duration.zero);
                          lastNet.play();
                        }
                        final lastYt = _youtubeControllers[index];
                        if (lastYt != null) {
                          lastYt.seekTo(Duration.zero);
                          lastYt.play();
                        }
                      }
                    },
                  );
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
  final bool Function()? canPlayback;
  final VoidCallback? onVideoEnded;

  const ReelsCardView({
    super.key,
    required this.reelCard,
    this.videoController,
    this.youtubeController,
    this.isCurrentPage = true,
    this.canPlayback,
    this.onVideoEnded,
  });

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView>
    with SingleTickerProviderStateMixin {
  ScreenshotController sc = ScreenshotController();
  bool _hasCompleted = false;
  int _playCount = 0;
  Timer? _feedbackTimer;
  final ValueNotifier<({bool show, IconData icon})> _feedbackState =
      ValueNotifier<({bool show, IconData icon})>(
    (show: false, icon: Icons.play_arrow_rounded),
  );
  final ValueNotifier<bool> _isLikePopVisible = ValueNotifier<bool>(false);
  late final AnimationController _likePopController;
  late final Animation<double> _likePopScale;
  late final Animation<double> _likePopOpacity;
  late final Animation<double> _likePopTilt;

  @override
  void initState() {
    super.initState();
    _likePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _isLikePopVisible.value = false;
        }
      });
    _likePopScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.35, end: 1.22)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.22, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.96, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 38,
      ),
    ]).animate(_likePopController);
    _likePopOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 54,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_likePopController);
    _likePopTilt = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.14, end: 0.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 32,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.06, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 40,
      ),
    ]).animate(_likePopController);
    widget.videoController?.addListener(_controllerListener);
    widget.youtubeController?.addListener(_ytListener);
  }

  @override
  void didUpdateWidget(ReelsCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController?.removeListener(_controllerListener);
      widget.videoController?.addListener(_controllerListener);
      _hasCompleted = false;
      _playCount = 0;
    }
    if (oldWidget.youtubeController != widget.youtubeController) {
      oldWidget.youtubeController?.removeListener(_ytListener);
      widget.youtubeController?.addListener(_ytListener);
      _hasCompleted = false;
      _playCount = 0;
    }
    // When this card transitions from off-screen to the active visible page (user scrolled to it)
    if (!oldWidget.isCurrentPage && widget.isCurrentPage) {
      _hasCompleted = false;
      if (_isPlaybackAllowed()) {
        try {
          final vc = widget.videoController;
          if (vc != null && vc.value.isInitialized && !vc.value.isPlaying) {
            final pos = vc.value.position;
            final dur = vc.value.duration;
            if (dur > Duration.zero &&
                pos >= dur - const Duration(milliseconds: 500)) {
              vc.seekTo(Duration.zero);
            }
            vc.play();
          }
        } catch (_) {}
        try {
          final yc = widget.youtubeController;
          if (yc != null && !yc.value.isPlaying) {
            if (yc.value.playerState == PlayerState.ended) {
              yc.seekTo(Duration.zero);
            }
            yc.play();
          }
        } catch (_) {}
      }
    } else if (oldWidget.isCurrentPage && !widget.isCurrentPage) {
      try {
        widget.videoController?.pause();
      } catch (_) {}
      try {
        widget.youtubeController?.pause();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _feedbackState.dispose();
    _isLikePopVisible.dispose();
    _likePopController.dispose();
    widget.videoController?.removeListener(_controllerListener);
    widget.youtubeController?.removeListener(_ytListener);
    super.dispose();
  }

  void _triggerLike(
    ReelsProviders reelsProvider, {
    required bool onlyIfNotLiked,
    required String source,
  }) {
    final bool isLiked =
        reelsProvider.isReelLiked(widget.reelCard.id.toString());
    if (onlyIfNotLiked && isLiked) {
      return;
    }
    AnalyticsService.instance.track(AnalyticsEventName.reelLike, properties: {
      'reel_id': widget.reelCard.id,
      'source': source,
    });
    final bool newLikeState = !isLiked;
    reelsProvider.isLikePost(widget.reelCard);
    EventRepo().addEvent({
      "like": newLikeState,
      "postId": widget.reelCard.id.toString(),
      "createAt": DateTime.now().toString(),
      "postTitle": widget.reelCard.title.toString(),
    }, "liked_article");
  }

  void _handleDoubleTapLike() {
    _isLikePopVisible.value = true;
    _likePopController.forward(from: 0.0);
    final reelsProvider = context.read<ReelsProviders>();
    _triggerLike(
      reelsProvider,
      onlyIfNotLiked: true,
      source: 'double_tap',
    );
  }

  Widget _buildDoubleTapLikePopup() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLikePopVisible,
      builder: (context, visible, _) {
        if (!visible) return const SizedBox.shrink();
        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                key: const Key('reel_double_tap_like_popup'),
                animation: _likePopController,
                builder: (context, child) {
                  final double scale = _likePopScale.value;
                  final double opacity = _likePopOpacity.value;
                  final double tilt = _likePopTilt.value;
                  final double ringProgress =
                      (_likePopController.value / 0.65).clamp(0.0, 1.0);
                  final double ringScale = 0.75 + (ringProgress * 0.85);
                  final double ringOpacity = (1.0 - ringProgress) * 0.45;

                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (ringOpacity > 0.0)
                          Transform.scale(
                            scale: ringScale,
                            child: Container(
                              width: 108.r,
                              height: 108.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: ringOpacity),
                                  width: 3.0,
                                ),
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: tilt,
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 96.r,
                  height: 96.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1877F2),
                        Color(0xFF0A66C2),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1877F2).withValues(alpha: 0.5),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/svg/like_full.svg",
                    width: 46.r,
                    height: 46.r,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _togglePlayPause() {
    bool nowPlaying = false;
    final vc = widget.videoController;
    final yc = widget.youtubeController;

    if (vc != null && vc.value.isInitialized) {
      if (vc.value.isPlaying) {
        vc.pause();
        nowPlaying = false;
        AnalyticsService.instance
            .track(AnalyticsEventName.reelPause, properties: {
          'reel_id': widget.reelCard.id,
        });
      } else {
        vc.play();
        nowPlaying = true;
        AnalyticsService.instance
            .track(AnalyticsEventName.reelPlay, properties: {
          'reel_id': widget.reelCard.id,
        });
      }
    } else if (yc != null) {
      if (yc.value.isPlaying) {
        yc.pause();
        nowPlaying = false;
        AnalyticsService.instance
            .track(AnalyticsEventName.reelPause, properties: {
          'reel_id': widget.reelCard.id,
        });
      } else {
        yc.play();
        nowPlaying = true;
        AnalyticsService.instance
            .track(AnalyticsEventName.reelPlay, properties: {
          'reel_id': widget.reelCard.id,
        });
      }
    }

    _feedbackTimer?.cancel();
    final IconData updatedIcon =
        nowPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded;
    _feedbackState.value = (show: true, icon: updatedIcon);

    _feedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        _feedbackState.value = (show: false, icon: updatedIcon);
      }
    });
  }

  Widget _buildBufferingIndicator() {
    return Center(
      child: Container(
        width: 64.r,
        height: 64.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: 30.r,
            height: 30.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseOverlay(bool isPlaying) {
    return ValueListenableBuilder<({bool show, IconData icon})>(
      valueListenable: _feedbackState,
      builder: (context, feedback, _) {
        final bool shouldShow = !isPlaying || feedback.show;
        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        final IconData icon =
            feedback.show ? feedback.icon : Icons.play_arrow_rounded;

        return Center(
          child: AnimatedOpacity(
            opacity: shouldShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 46.r,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isPlaybackAllowed() {
    if (!mounted || !widget.isCurrentPage) return false;
    final bool routeCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final bool tickerEnabled = TickerMode.valuesOf(context).enabled;
    final bool parentAllowed = widget.canPlayback?.call() ?? true;
    return routeCurrent && tickerEnabled && parentAllowed;
  }

  void _controllerListener() {
    final controller = widget.videoController;
    if (!_isPlaybackAllowed()) {
      if (controller != null &&
          controller.value.isInitialized &&
          controller.value.isPlaying) {
        try {
          controller.pause();
        } catch (_) {}
      }
      return;
    }
    if (controller != null && controller.value.isInitialized) {
      final pos = controller.value.position;
      final dur = controller.value.duration;

      // Verify duration is valid (>1.5s) and video is not in an initial buffering/unloaded state
      if (dur > const Duration(milliseconds: 1500) &&
          !controller.value.isBuffering) {
        // Completion condition:
        // 1. Position is within 400ms of duration OR controller reported isCompleted
        // 2. Position has played at least 80% of total duration OR controller reported isCompleted
        // 3. Position is at least 1.5 seconds into the video (prevents false early triggers)
        final bool isNearEnd = pos >= dur - const Duration(milliseconds: 400) ||
            controller.value.isCompleted;
        final bool hasPlayedSufficiently =
            pos.inMilliseconds >= (dur.inMilliseconds * 0.80) ||
                controller.value.isCompleted;

        if (isNearEnd && hasPlayedSufficiently && !_hasCompleted) {
          _hasCompleted = true;
          _playCount++;
          AnalyticsService.instance
              .track(AnalyticsEventName.reelComplete, properties: {
            'reel_id': widget.reelCard.id,
            'watch_duration_seconds': dur.inSeconds,
          });
          widget.onVideoEnded?.call();
        } else if (pos < const Duration(milliseconds: 500) &&
            _hasCompleted &&
            _playCount > 0) {
          _hasCompleted = false;
          AnalyticsService.instance
              .track(AnalyticsEventName.reelRewatch, properties: {
            'reel_id': widget.reelCard.id,
          });
        }
      }
    }
  }

  void _ytListener() {
    final ytController = widget.youtubeController;
    if (!_isPlaybackAllowed()) {
      if (ytController != null && ytController.value.isPlaying) {
        try {
          ytController.pause();
        } catch (_) {}
      }
      return;
    }
    if (ytController != null) {
      final pos = ytController.value.position;
      final dur = ytController.metadata.duration;
      final bool isEnded = ytController.value.playerState == PlayerState.ended;
      final bool isNearEnd = dur > const Duration(seconds: 1) &&
          pos >= dur - const Duration(milliseconds: 500) &&
          pos >= const Duration(seconds: 2);

      if ((isEnded || isNearEnd) && !_hasCompleted) {
        _hasCompleted = true;
        _playCount++;
        AnalyticsService.instance
            .track(AnalyticsEventName.reelComplete, properties: {
          'reel_id': widget.reelCard.id,
          'watch_duration_seconds': dur.inSeconds,
        });
        widget.onVideoEnded?.call();
      } else if (ytController.value.playerState == PlayerState.playing &&
          _hasCompleted &&
          pos < const Duration(milliseconds: 500)) {
        _hasCompleted = false;
      }
    }
  }

  Widget _buildVideoBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 1. Direct Network Video Player (pre-buffered from user server)
    if (widget.videoController != null &&
        widget.videoController!.value.isInitialized) {
      return Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          widget.videoController!.setVolume(homeProvider.isMuted ? 0.0 : 1.0);
          final size = widget.videoController!.value.size;
          final double vWidth = size.width > 0 ? size.width : screenWidth;
          final double vHeight = size.height > 0 ? size.height : screenHeight;

          return ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: widget.videoController!,
            builder: (context, videoValue, _) {
              final bool isBuffering = videoValue.isBuffering;

              return Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: vWidth,
                          height: vHeight,
                          child: VideoPlayer(widget.videoController!),
                        ),
                      ),
                    ),
                    if (isBuffering)
                      _buildBufferingIndicator()
                    else
                      _buildPlayPauseOverlay(videoValue.isPlaying),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    // 2. YouTube Video Player with full device resolution viewport
    if (widget.youtubeController != null) {
      return Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          if (homeProvider.isMuted) {
            widget.youtubeController!.mute();
          } else {
            widget.youtubeController!.unMute();
          }
          return ValueListenableBuilder<YoutubePlayerValue>(
            valueListenable: widget.youtubeController!,
            builder: (context, ytValue, _) {
              final bool isBuffering =
                  ytValue.playerState == PlayerState.buffering ||
                      (!ytValue.isReady && widget.isCurrentPage);

              return Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: screenWidth,
                          height: screenWidth / (9 / 16),
                          child: IgnorePointer(
                            ignoring: true,
                            child: YoutubePlayer(
                              controller: widget.youtubeController!,
                              aspectRatio: 9 / 16,
                              onReady: () {
                                if (_isPlaybackAllowed()) {
                                  try {
                                    widget.youtubeController?.play();
                                  } catch (_) {}
                                } else {
                                  try {
                                    widget.youtubeController?.pause();
                                  } catch (_) {}
                                }
                              },
                              bufferIndicator: const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isBuffering)
                      _buildBufferingIndicator()
                    else
                      _buildPlayPauseOverlay(ytValue.isPlaying),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    // 3. Instant Thumbnail Cover (Fills screen with BoxFit.cover)
    if (widget.reelCard.thumbnailUrl.isNotEmpty) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.reelCard.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.black),
              errorWidget: (_, __, ___) => Container(color: Colors.black),
            ),
            if (widget.isCurrentPage)
              _buildBufferingIndicator()
            else
              _buildPlayPauseOverlay(false),
          ],
        ),
      );
    }

    return Container(color: Colors.black);
  }

  Widget _buildProgressBar(double bottomOffset) {
    if (widget.videoController != null &&
        widget.videoController!.value.isInitialized) {
      return Positioned(
        bottom: bottomOffset,
        left: 0,
        right: 0,
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.videoController!,
          builder: (context, videoValue, _) {
            final int total = videoValue.duration.inMilliseconds;
            final int current = videoValue.position.inMilliseconds;
            final double progress =
                (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;
            return _buildProgressBarLine(
              progress: progress,
              onSeek: (fraction) {
                final targetMs = (fraction * total).toInt();
                widget.videoController
                    ?.seekTo(Duration(milliseconds: targetMs));
              },
            );
          },
        ),
      );
    }

    if (widget.youtubeController != null) {
      return Positioned(
        bottom: bottomOffset,
        left: 0,
        right: 0,
        child: ValueListenableBuilder<YoutubePlayerValue>(
          valueListenable: widget.youtubeController!,
          builder: (context, ytValue, _) {
            final int total = ytValue.metaData.duration.inMilliseconds;
            final int current = ytValue.position.inMilliseconds;
            final double progress =
                (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;
            return _buildProgressBarLine(
              progress: progress,
              onSeek: (fraction) {
                final targetMs = (fraction * total).toInt();
                widget.youtubeController
                    ?.seekTo(Duration(milliseconds: targetMs));
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProgressBarLine({
    required double progress,
    required ValueChanged<double> onSeek,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final double boxWidth = constraints.maxWidth;
            if (boxWidth > 0) {
              final double fraction =
                  (details.localPosition.dx / boxWidth).clamp(0.0, 1.0);
              onSeek(fraction);
            }
          },
          onTapDown: (details) {
            final double boxWidth = constraints.maxWidth;
            if (boxWidth > 0) {
              final double fraction =
                  (details.localPosition.dx / boxWidth).clamp(0.0, 1.0);
              onSeek(fraction);
            }
          },
          child: Container(
            height: 12.h,
            alignment: Alignment.bottomCenter,
            color: Colors.transparent,
            child: Container(
              height: 2.8.h,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.22),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColorTokens.cinemaRed,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(1.5.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    HomeProvider? homeProvider;
    try {
      homeProvider = context.watch<HomeProvider>();
    } catch (_) {}
    final bool isRootTab = ModalRoute.of(context)?.isFirst ?? true;
    final bool hasBottomNav =
        isRootTab && (homeProvider?.isBottomEnable ?? true);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double bottomBarHeight =
        hasBottomNav ? (50.0 + bottomPadding) : bottomPadding;

    final double contentBottomBase =
        hasBottomNav ? bottomBarHeight : bottomPadding;

    return Stack(
      children: [
        Positioned.fill(
          bottom: hasBottomNav ? bottomBarHeight : 0,
          child: GestureDetector(
            key: const Key('reel_card_gesture_area'),
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayPause,
            onDoubleTap: _handleDoubleTapLike,
            child: Screenshot(
              controller: sc,
              child: _buildVideoBody(context),
            ),
          ),
        ),
        // Full-width bottom-to-top black gradient shade for contrast & readability
        Positioned(
          bottom: hasBottomNav ? bottomBarHeight : 0,
          left: 0,
          right: 0,
          height: 320.h,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.90),
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.30, 0.60, 0.85, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Description content directly on gradient (no box)
        Positioned(
          bottom: contentBottomBase + 14,
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
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 12.5.sp,
                  ).copyWith(
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                height(height: 10.h),
                Row(
                  children: [
                    if (widget.reelCard.publisherImage.isNotEmpty) ...[
                      SizedBox(
                        height: 36.r,
                        width: 36.r,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(18.r)),
                          child: CachedNetworkImage(
                            imageUrl: widget.reelCard.publisherImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color:
                                  AppColors.borderColor.withValues(alpha: .2),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.account_circle,
                                size: 36.r,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                      width(width: 8.w),
                    ],
                    if (widget.reelCard.publisher.isNotEmpty)
                      Text(
                        widget.reelCard.publisher,
                        style: fontStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ).copyWith(
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildDoubleTapLikePopup(),
        Positioned(
          right: 10,
          bottom: contentBottomBase + 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ReelsProviders>(
                builder: (context, reelsProvider, child) {
                  final bool isLiked =
                      reelsProvider.isReelLiked(widget.reelCard.id.toString());
                  final isMl = context.watch<HomeProvider>().langCode == 'ml';
                  return BottomActions(
                    iconColor: Colors.white,
                    postType: widget.reelCard.postName,
                    icon: isLiked
                        ? "assets/svg/like_full.svg"
                        : "assets/svg/like.svg",
                    label: isMl ? 'ലൈക്ക്' : 'లైక్',
                    isLike: isLiked,
                    onTap: () async {
                      log("Like");
                      _triggerLike(
                        reelsProvider,
                        onlyIfNotLiked: false,
                        source: 'button',
                      );
                    },
                  );
                },
              ),
              height(height: 20),
              Builder(
                builder: (context) {
                  final isMl = context.watch<HomeProvider>().langCode == 'ml';
                  return BottomActions(
                    postType: "",
                    icon: "assets/svg/new_comment.svg",
                    label: isMl ? 'കമന്റ്' : 'కామెంట్',
                    iconColor: Colors.white,
                    onTap: () async {
                      context
                          .read<AuthenticationProvider>()
                          .sendEvent("CommentPage");
                      showComments(context, widget.reelCard.id.toString(),
                          widget.reelCard.title.toString());
                    },
                  );
                },
              ),
              height(height: 20),
              Builder(
                builder: (context) {
                  final isMl = context.watch<HomeProvider>().langCode == 'ml';
                  return BottomActions(
                    postType: "",
                    icon: "assets/svg/share.svg",
                    label: isMl ? 'പങ്കിടുക' : 'షేర్',
                    iconColor: Colors.white,
                    onTap: () async {
                      log("Share Reel button tapped: ${widget.reelCard.id}");
                      AnalyticsService.instance
                          .track(AnalyticsEventName.reelShare, properties: {
                        'reel_id': widget.reelCard.id,
                        'share_target': 'general',
                      });

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
                        SharedPreferences sp =
                            await SharedPreferences.getInstance();
                        String? userId = sp.getString("userId");
                        sendShareDetails(userId, widget.reelCard.id,
                            widget.reelCard.content.toString());
                      } catch (e) {
                        log("Error sending share details: $e");
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        _buildProgressBar(bottomBarHeight),
      ],
    );
  }
}
