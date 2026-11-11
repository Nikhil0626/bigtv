import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:chotanews/core/theme/color_tokens.dart';

import 'dart:developer';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class ReelsCardView extends StatefulWidget {
  final String postId;

  const ReelsCardView({super.key, required this.postId});

  @override
  State<ReelsCardView> createState() => _ReelsCardViewState();
}

class _ReelsCardViewState extends State<ReelsCardView> with WidgetsBindingObserver {
  ScreenshotController sc = ScreenshotController();
  final ValueNotifier<YoutubePlayerController?> _controllerNotifier = ValueNotifier<YoutubePlayerController?>(null);
  ReelsProviders? _reelsProviders;
  bool _suppressAutoPlay = false;
  bool _wasRouteActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setWakelock(enabled: true);

    context.read<ReelsProviders>().getIndividualReelData(widget.postId).then((value) {
      if (!mounted) return;
      log(value.toString());
      final videoId = YoutubePlayer.convertUrlToId(value.videoUrl) ?? value.videoUrl;
      if (videoId.isNotEmpty) {
        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: _isViewActive() && !_suppressAutoPlay,
            mute: false,
            forceHD: true,
            loop: false,
            disableDragSeek: true,
            enableCaption: false,
            controlsVisibleAtStart: true,
          ),
        )..addListener(_onPlayerStateChanged);
        _controllerNotifier.value = controller;
      }
    });
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

  bool _isViewActive() {
    if (!mounted) return false;
    final bool routeCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final bool tickerEnabled = TickerMode.valuesOf(context).enabled;
    return routeCurrent && tickerEnabled;
  }

  void _pauseController() {
    _suppressAutoPlay = true;
    try {
      _controllerNotifier.value?.pause();
    } catch (_) {}
    _setWakelock(enabled: false);
  }

  void _onPlayerStateChanged() {
    final controller = _controllerNotifier.value;
    if (controller != null &&
        !_isViewActive() &&
        controller.value.isPlaying) {
      try {
        controller.pause();
      } catch (_) {}
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final provider = context.read<ReelsProviders>();
      if (!identical(_reelsProviders, provider)) {
        _reelsProviders?.removePauseListener(_pauseController);
        _reelsProviders = provider;
        _reelsProviders!.addPauseListener(_pauseController);
      }
    } catch (_) {}
    final bool isActiveNow = _isViewActive();
    if (_wasRouteActive && !isActiveNow) {
      _pauseController();
    } else if (!_wasRouteActive && isActiveNow) {
      _suppressAutoPlay = false;
    }
    _wasRouteActive = isActiveNow;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pauseController();
    } else if (state == AppLifecycleState.resumed && _isViewActive()) {
      _setWakelock(enabled: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reelsProviders?.removePauseListener(_pauseController);
    _setWakelock(enabled: false);
    _controllerNotifier.value?.removeListener(_onPlayerStateChanged);
    _controllerNotifier.value?.dispose(); // Dispose properly
    _controllerNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.primaryRed,
      body: Consumer<ReelsProviders>(builder: (_, reelsProviders, __) {
        return ValueListenableBuilder<YoutubePlayerController?>(
          valueListenable: _controllerNotifier,
          builder: (context, controller, child) {
            if (reelsProviders.isReelDataLoading || controller == null) {
              return AppLoadingScreen();
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Screenshot(
                    controller: sc,
                    child: Container(
                      color: AppColorTokens.primaryRed,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width / (9 / 16),
                          child: YoutubePlayer(
                            controller: controller,
                            aspectRatio: 9 / 16,
                            onReady: () {
                              if (_suppressAutoPlay || !_isViewActive()) {
                                _suppressAutoPlay = false;
                                try {
                                  controller.pause();
                                } catch (_) {}
                              }
                            },
                            bottomActions: [
                              CurrentPosition(),
                              ProgressBar(
                                isExpanded: true,
                                colors: ProgressBarColors(bufferedColor: Colors.grey, playedColor: Colors.red),
                              ),
                              RemainingDuration(),
                              IconButton(
                                icon: Icon(
                                  reelsProviders.isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (reelsProviders.isMuted) {
                                    controller.unMute();
                                  } else {
                                    controller.mute();
                                  }
                                  reelsProviders.toggleMute();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // ... other Positioned widgets
              ],
            );
          },
        );
      }),
    );
  }
}

