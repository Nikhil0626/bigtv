import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class LiveTvScreen extends StatefulWidget {
  final String streamUrl;
  final String channelName;
  final String? playbackType;

  const LiveTvScreen({
    super.key,
    required this.streamUrl,
    this.channelName = "BIGTV",
    this.playbackType = "hls",
  });

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = "";
  bool _showControls = true;
  bool _isMuted = false;
  bool _isLandscape = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
      _errorMessage = "";
    });

    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      log("Initializing Live TV stream URL: ${widget.streamUrl}");
      final Uri uri = Uri.parse(widget.streamUrl);
      final controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      await controller.initialize();
      controller.setLooping(true);
      await controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        _startHideControlsTimer();
      }
    } catch (e, stackTrace) {
      log("Error initializing Live TV video player: $e", stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = "Failed to load Live TV stream. Please check your internet connection.";
        });
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_showControls && _controller != null && _controller!.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _controller != null && _controller!.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscapeMode = _isLandscape ||
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (_isLandscape) {
          _toggleOrientation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !isLandscapeMode,
          bottom: !isLandscapeMode,
          left: false,
          right: false,
          child: Stack(
            children: [
              // Video Surface
              Center(
                child: _hasError
                    ? _buildErrorWidget()
                    : (_isInitialized && _controller != null)
                        ? (isLandscapeMode
                            ? SizedBox.expand(
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: SizedBox(
                                    width: _controller!.value.size.width > 0
                                        ? _controller!.value.size.width
                                        : 16,
                                    height: _controller!.value.size.height > 0
                                        ? _controller!.value.size.height
                                        : 9,
                                    child: VideoPlayer(_controller!),
                                  ),
                                ),
                              )
                            : AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio > 0
                                    ? _controller!.value.aspectRatio
                                    : 16 / 9,
                                child: VideoPlayer(_controller!),
                              ))
                        : const CircularProgressIndicator(
                            color: Colors.red,
                          ),
              ),

              // Buffering indicator when initialized but buffering
              if (_isInitialized && _controller != null && _controller!.value.isBuffering)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),

              // Gesture Detector overlay for controls toggle
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleControls,
                  child: const SizedBox.expand(),
                ),
              ),

              // Controls overlay
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      // Top Overlay Bar (Header)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: isLandscapeMode ? 4.h : 8.h,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: isLandscapeMode ? 32.r : 24.r,
                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  widget.channelName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isLandscapeMode ? 10.sp : 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Live Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscapeMode ? 6.w : 10.w,
                                  vertical: isLandscapeMode ? 2.h : 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: isLandscapeMode ? 5.r : 8.r,
                                      height: isLandscapeMode ? 5.r : 8.r,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "LIVE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLandscapeMode ? 8.sp : 12.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                          ),
                        ),
                      ),

                      // Center Play/Pause button
                      if (_isInitialized && _controller != null)
                        Center(
                          child: IconButton(
                            iconSize: isLandscapeMode ? 96.r : 64.r,
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_filled_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                              _startHideControlsTimer();
                            },
                          ),
                        ),

                      // Bottom Overlay Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: isLandscapeMode ? 6.h : 12.h,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black87],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    iconSize: isLandscapeMode ? 36.r : 24.r,
                                    icon: Icon(
                                      _isMuted ? Icons.volume_off : Icons.volume_up,
                                      color: Colors.white,
                                    ),
                                    onPressed: _toggleMute,
                                  ),
                                  Text(
                                    "Live Stream",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isLandscapeMode ? 9.sp : 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                padding: EdgeInsets.all(4.r),
                                constraints: const BoxConstraints(),
                                icon: Container(
                                  padding: EdgeInsets.all(isLandscapeMode ? 10.r : 4.r),
                                  decoration: BoxDecoration(
                                    color: isLandscapeMode
                                        ? Colors.red.withValues(alpha: 0.85)
                                        : Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isLandscapeMode
                                        ? Icons.fullscreen_exit_rounded
                                        : Icons.fullscreen_rounded,
                                    color: Colors.white,
                                    size: isLandscapeMode ? 44.r : 28.r,
                                  ),
                                ),
                                onPressed: _toggleOrientation,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 48.r,
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage.isNotEmpty
                ? _errorMessage
                : "Unable to load Live TV stream.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            onPressed: _initializePlayer,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
