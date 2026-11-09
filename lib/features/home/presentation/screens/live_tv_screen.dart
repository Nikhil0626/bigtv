import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/live_eye_animation_icon.dart';
import 'package:chotanews/services/live_tv_share_helper.dart';
import 'package:chotanews/utils/top_right_wave_painter.dart';

class LiveTvScreen extends StatefulWidget {
  final String streamUrl;
  final String channelName;
  final String? playbackType;
  final int? watchCount;
  final String? formattedWatchCount;
  final bool? watchCountEnabled;

  const LiveTvScreen({
    super.key,
    required this.streamUrl,
    this.channelName = "BIGTV",
    this.playbackType = "hls",
    this.watchCount,
    this.formattedWatchCount,
    this.watchCountEnabled,
  });

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = "";
  bool _showControls = true;
  bool _isMuted = false;
  bool _isLandscape = false;
  Timer? _hideControlsTimer;
  DateTime? _playStartTime;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  int? _watchCount;
  String? _formattedWatchCount;
  bool _watchCountEnabled = true;
  Timer? _watchCountTimer;

  bool get _isMalayalam =>
      widget.streamUrl.contains('malayalam') ||
      widget.channelName.toLowerCase().contains('malayalam');

  @override
  void initState() {
    super.initState();
    _watchCount = widget.watchCount;
    _formattedWatchCount = widget.formattedWatchCount;
    _watchCountEnabled = widget.watchCountEnabled ?? true;

    if (_watchCount == null && (_formattedWatchCount == null || _formattedWatchCount!.isEmpty)) {
      _refreshWatchCount();
    }
    _watchCountTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshWatchCount();
    });

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_waveController);

    AnalyticsService.instance.track(AnalyticsEventName.liveTvOpen, properties: {
      'channel_id': widget.channelName,
      'source_screen': 'home',
    });
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
      _playStartTime = DateTime.now();
      AnalyticsService.instance.track(AnalyticsEventName.liveTvPlay, properties: {
        'channel_id': widget.channelName,
        'stream_type': widget.playbackType ?? 'hls',
      });

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        _startHideControlsTimer();
      }
    } catch (e, stackTrace) {
      log("Error initializing Live TV video player: $e", stackTrace: stackTrace);
      AnalyticsService.instance.track(AnalyticsEventName.liveTvError, properties: {
        'channel_id': widget.channelName,
        'error_code': e.toString(),
      });
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

  void _shareLiveTv() {
    final bool isMl = _isMalayalam;
    LiveTvShareHelper.shareLiveTv(
      context: context,
      channelName: widget.channelName,
      isTelugu: !isMl,
      langCode: isMl ? 'ml' : 'te',
      source: 'player',
    );
  }

  @override
  void dispose() {
    if (_playStartTime != null) {
      final watchDuration = DateTime.now().difference(_playStartTime!).inSeconds;
      AnalyticsService.instance.track(AnalyticsEventName.liveTvStop, properties: {
        'channel_id': widget.channelName,
        'watch_duration_seconds': watchDuration,
      });
    }
    _watchCountTimer?.cancel();
    _waveController.dispose();
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _refreshWatchCount() async {
    if (_isMalayalam) return;
    try {
      final response = await http.get(
        Uri.parse('https://api.pravasamedia.com/api/v1/live'),
        headers: {'accept': '*/*'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && mounted) {
          setState(() {
            if (data['watch_count'] != null) {
              _watchCount = data['watch_count'] is num
                  ? (data['watch_count'] as num).toInt()
                  : int.tryParse(data['watch_count'].toString());
            }
            if (data['formatted_watch_count'] != null) {
              _formattedWatchCount = data['formatted_watch_count'].toString();
            }
            if (data['watch_count_enabled'] != null) {
              _watchCountEnabled = data['watch_count_enabled'] == true ||
                  data['watch_count_enabled'] == 1 ||
                  data['watch_count_enabled'] == 'true';
            }
          });
        }
      }
    } catch (e) {
      log("Live TV watch count refresh error: $e");
    }
  }

  bool get _isWatchCountVisible {
    if (!_watchCountEnabled) return false;
    try {
      if (!context.read<HomeProvider>().liveTvCountEnable) return false;
    } catch (_) {}
    final str = _getDisplayWatchCount();
    return str.isNotEmpty && str != "0";
  }

  String _getDisplayWatchCount() {
    if (_formattedWatchCount != null && _formattedWatchCount!.trim().isNotEmpty) {
      return _formattedWatchCount!.trim();
    }
    if (_watchCount != null && _watchCount! > 0) {
      return _formatWatchCount(_watchCount!);
    }
    return "";
  }

  String _formatWatchCount(int count) {
    if (count >= 1000000) {
      final val = count / 1000000.0;
      return "${val.toStringAsFixed(val >= 10 ? 0 : 1)}M".replaceAll('.0M', 'M');
    }
    if (count >= 1000) {
      final val = count / 1000.0;
      return "${val.toStringAsFixed(val >= 10 ? 0 : 1)}K".replaceAll('.0K', 'K');
    }
    return count.toString();
  }

  Widget _buildWatchCountBadge(bool isLandscapeMode) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscapeMode ? 12.0 : 9.w,
        vertical: isLandscapeMode ? 5.5 : 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveEyeAnimationIcon(
            size: isLandscapeMode ? 24.0 : 16.0,
            color: Colors.white,
            pupilColor: const Color(0xFFED1C24),
            showRipple: true,
          ),
          SizedBox(width: isLandscapeMode ? 6.0 : 5.w),
          Text(
            _getDisplayWatchCount(),
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscapeMode ? 14.0 : 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
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
        backgroundColor: isLandscapeMode ? Colors.black : const Color(0xFF0F0F12),
        body: SafeArea(
          top: !isLandscapeMode,
          bottom: !isLandscapeMode,
          left: false,
          right: false,
          child: Stack(
            children: [
              // 1. Subtle Luxury Ambient Gradient Backdrop (from feedback_view.dart)
              if (!isLandscapeMode)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF180A0D),
                          Color(0xFF0F0F12),
                          Color(0xFF13090B),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

              // 2. Top Right Wave Ripple Art (from feedback_view.dart)
              if (!isLandscapeMode)
                Positioned(
                  top: 0,
                  right: 0,
                  width: MediaQuery.of(context).size.width,
                  height: 380.h,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: TopRightWavePainter(
                        isDark: true,
                        waveAnimation: _waveAnimation,
                      ),
                    ),
                  ),
                ),

              // 3. Bottom-Left Radiant Glow Orb (from feedback_view.dart)
              if (!isLandscapeMode)
                Positioned(
                  bottom: -60.h,
                  left: -60.w,
                  width: 280.w,
                  height: 280.w,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFED1C24).withValues(alpha: 0.16),
                            const Color(0xFFED1C24).withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

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
                                  horizontal: isLandscapeMode ? 10.0 : 10.w,
                                  vertical: isLandscapeMode ? 5.5 : 4.h,
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
                                      width: isLandscapeMode ? 7.5 : 8.r,
                                      height: isLandscapeMode ? 7.5 : 8.r,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: isLandscapeMode ? 5.0 : 4.w),
                                    Text(
                                      "LIVE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLandscapeMode ? 13.0 : 12.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Live Watch Count with Animated Eye Icon
                              if (_isWatchCountVisible) ...[
                                SizedBox(width: isLandscapeMode ? 8.0 : 8.w),
                                _buildWatchCountBadge(isLandscapeMode),
                              ],
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
                                  AnalyticsService.instance.track(AnalyticsEventName.liveTvPause, properties: {
                                    'channel_id': widget.channelName,
                                    'playback_position_seconds': _controller!.value.position.inSeconds,
                                  });
                                } else {
                                  _controller!.play();
                                  AnalyticsService.instance.track(AnalyticsEventName.liveTvResume, properties: {
                                    'channel_id': widget.channelName,
                                  });
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
                              Row(
                                children: [
                                  IconButton(
                                    iconSize: isLandscapeMode ? 32.r : 22.r,
                                    tooltip: "Share Live TV",
                                    icon: const Icon(
                                      Icons.share_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: _shareLiveTv,
                                  ),
                                  SizedBox(width: 4.w),
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
