import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/services/video_position_service.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

class TagVideoPlayerScreen extends StatefulWidget {
  final List videos;
  final int initialIndex;
  final String tagTitle;
  final String? tagThumbnailUrl;

  const TagVideoPlayerScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.tagTitle = "Videos",
    this.tagThumbnailUrl,
  });

  @override
  State<TagVideoPlayerScreen> createState() => _TagVideoPlayerScreenState();
}

class _TagVideoPlayerScreenState extends State<TagVideoPlayerScreen> {
  late int _currentIndex;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isChangingTrack = false;
  bool _showControls = true;
  bool _isFullScreen = true;
  bool _hasError = false;
  bool _isMuted = false;
  double _volume = 1.0;
  bool _showVolumeSlider = false;

  String _getThumbnailUrl(BuildContext context, Map<String, dynamic> item) {
    final rawThumbnail = item['thumbnailUrl'] ??
        item['thumbnail_url'] ??
        item['thumbnail'] ??
        item['thumb'] ??
        item['posterUrl'] ??
        item['poster_url'] ??
        item['poster'] ??
        item['imageUrl'] ??
        item['image_url'] ??
        item['image'] ??
        item['coverUrl'] ??
        item['cover_url'] ??
        item['cover'] ??
        item['photoUrl'] ??
        item['photo_url'] ??
        item['photo'] ??
        item['bannerUrl'] ??
        item['banner_url'] ??
        item['banner'];

    if (rawThumbnail != null && rawThumbnail.toString().trim().isNotEmpty) {
      return rawThumbnail.toString().trim();
    }

    final videoUrl = (item['url'] ??
            item['videoUrl'] ??
            item['video_url'] ??
            item['linkURLAndroid'] ??
            item['linkURLIos'] ??
            item['postUrl'] ??
            item['link'] ??
            '')
        .toString()
        .trim();

    if (videoUrl.isNotEmpty) {
      try {
        final ytId = YoutubePlayer.convertUrlToId(videoUrl);
        if (ytId != null && ytId.isNotEmpty) {
          return "https://img.youtube.com/vi/$ytId/hqdefault.jpg";
        }
      } catch (_) {}

      final regExp = RegExp(
        r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|shorts\/))([\w-]{11})',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(videoUrl);
      if (match != null && match.groupCount >= 1) {
        final id = match.group(1);
        if (id != null && id.isNotEmpty) {
          return "https://img.youtube.com/vi/$id/hqdefault.jpg";
        }
      }
    }

    for (final entry in item.entries) {
      final val = entry.value?.toString().trim() ?? '';
      if (val.startsWith('http://') || val.startsWith('https://')) {
        final lower = val.toLowerCase();
        if (lower.contains('.jpg') ||
            lower.contains('.jpeg') ||
            lower.contains('.png') ||
            lower.contains('.webp') ||
            lower.contains('.gif') ||
            lower.contains('/images/') ||
            lower.contains('/thumbnails/')) {
          return val;
        }
      }
    }

    if (widget.tagThumbnailUrl != null && widget.tagThumbnailUrl!.trim().isNotEmpty) {
      return widget.tagThumbnailUrl!.trim();
    }

    try {
      final homeProviderThumb = Provider.of<HomeProvider>(context, listen: false).currentTagThumbnailUrl;
      if (homeProviderThumb != null && homeProviderThumb.trim().isNotEmpty) {
        return homeProviderThumb.trim();
      }
    } catch (_) {}

    return "";
  }

  Widget _buildDefaultThumbnailBox() {
    return Container(
      width: 58.w,
      height: 44.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade800, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  void _seekRelative(int seconds) {
    if (_controller != null && _controller!.value.isInitialized) {
      final currentPos = _controller!.value.position;
      final targetPos = currentPos + Duration(seconds: seconds);
      final duration = _controller!.value.duration;
      final clampedPos = targetPos < Duration.zero
          ? Duration.zero
          : (targetPos > duration ? duration : targetPos);
      _controller!.seekTo(clampedPos);
    }
  }

  void _toggleMute() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : (_volume > 0 ? _volume : 1.0));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _isFullScreen = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initController(_currentIndex);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  Future<void> _initController(int index) async {
    if (widget.videos.isEmpty || index < 0 || index >= widget.videos.length) return;

    if (_controller != null && _controller!.value.isInitialized && _currentIndex < widget.videos.length) {
      final pos = _controller!.value.position;
      final dur = _controller!.value.duration;
      final currentItem = widget.videos[_currentIndex];
      if (pos.inSeconds > 1 && dur > Duration.zero && pos < dur - const Duration(seconds: 2)) {
        await VideoPositionService.savePosition(currentItem, pos);
      }
    }

    setState(() {
      _isInitialized = false;
      _hasError = false;
      _isChangingTrack = false;
    });

    final oldController = _controller;
    _controller = null;
    if (oldController != null) {
      oldController.removeListener(_videoListener);
      await oldController.dispose();
    }

    final videoItem = widget.videos[index];
    String rawUrl = (videoItem['url'] ?? '').toString().trim();
    if (rawUrl.isEmpty) {
      log("Empty video URL for index $index");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      return;
    }

    log("Initializing video track $index: $rawUrl");

    bool success = await _tryInitializeUrl(rawUrl);

    // Fallback attempt: Try switching http <-> https if initial attempt failed
    if (!success) {
      String fallbackUrl = rawUrl;
      if (rawUrl.startsWith("http://")) {
        fallbackUrl = rawUrl.replaceFirst("http://", "https://");
      } else if (rawUrl.startsWith("https://")) {
        fallbackUrl = rawUrl.replaceFirst("https://", "http://");
      }

      if (fallbackUrl != rawUrl) {
        log("Retrying video initialization with fallback URL: $fallbackUrl");
        success = await _tryInitializeUrl(fallbackUrl);
      }
    }

    if (!success && mounted) {
      setState(() {
        _isInitialized = false;
        _hasError = true;
      });
    }
  }

  Future<bool> _tryInitializeUrl(String url) async {
    try {
      final Uri videoUri = Uri.parse(url);
      final controller = VideoPlayerController.networkUrl(videoUri);
      await controller.initialize();
      controller.addListener(_videoListener);

      final currentItem = (widget.videos.isNotEmpty && _currentIndex < widget.videos.length)
          ? widget.videos[_currentIndex]
          : null;
      if (currentItem != null) {
        final savedPos = await VideoPositionService.getSavedPosition(currentItem);
        if (savedPos > const Duration(seconds: 1) &&
            controller.value.duration > Duration.zero &&
            savedPos < controller.value.duration - const Duration(seconds: 2)) {
          await controller.seekTo(savedPos);
          log("Resumed video track $_currentIndex at ${savedPos.inSeconds} seconds");
        }
      }

      await controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _hasError = false;
        });
      }
      return true;
    } catch (e, st) {
      log("Error initializing video at URL $url: $e", stackTrace: st);
      return false;
    }
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.isInitialized) {
      final value = _controller!.value;
      final currentItem = (widget.videos.isNotEmpty && _currentIndex < widget.videos.length)
          ? widget.videos[_currentIndex]
          : null;

      if (value.position >= value.duration && value.duration > Duration.zero && !_isChangingTrack) {
        if (currentItem != null) {
          VideoPositionService.clearPosition(currentItem);
        }
        _isChangingTrack = true;
        log("Video finished playing, auto-advancing to next track...");
        _playNextTrack();
      } else {
        if (currentItem != null && value.position.inSeconds > 1) {
          VideoPositionService.savePosition(currentItem, value.position);
        }
        if (mounted) setState(() {});
      }
    }
  }

  void _playNextTrack() {
    if (_currentIndex + 1 < widget.videos.length) {
      _currentIndex++;
      _initController(_currentIndex);
    } else {
      log("Reached end of playlist. Restarting from beginning.");
      _currentIndex = 0;
      _initController(_currentIndex);
    }
  }

  void _playPrevTrack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _initController(_currentIndex);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    if (_controller != null) {
      if (_controller!.value.isInitialized && _currentIndex < widget.videos.length) {
        final pos = _controller!.value.position;
        final dur = _controller!.value.duration;
        final currentItem = widget.videos[_currentIndex];
        if (pos.inSeconds > 1 && dur > Duration.zero && pos < dur - const Duration(seconds: 2)) {
          VideoPositionService.savePosition(currentItem, pos);
        }
      }
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    super.dispose();
  }

  String _cleanFileName(String name) {
    if (name.isEmpty) return "Video Track";
    return name.replaceAll(RegExp(r'\.(mp4|mov|mkv|avi)$', caseSensitive: false), '');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = (widget.videos.isNotEmpty && _currentIndex < widget.videos.length)
        ? widget.videos[_currentIndex]
        : null;
    final currentTitle = currentVideo != null ? _cleanFileName(currentVideo['fileName'] ?? '') : "Video Player";

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape || _isFullScreen;

        if (isLandscape) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  _toggleFullScreen();
                }
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                child: SizedBox.expand(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_controller != null && _isInitialized)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              key: ValueKey(_controller),
                              width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 16,
                              height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 9,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        )
                      else if (_hasError)
                        _buildErrorView()
                      else
                        const Center(child: CircularProgressIndicator(color: Colors.red)),

                      if (_showControls && _controller != null && _isInitialized)
                        _buildFullscreenControls(currentTitle),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgImage = isDark ? "assets/images/tag_bg_dark.png" : "assets/images/tag_bg_light.png";

        // Portrait Layout (matching screenshot design)
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0C0D14) : Colors.white,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgImage),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Navigation Bar with Logo
                  _buildHeader(context),

                  // 2. Subheader Tag Info
                  _buildTagInfo(widget.tagTitle, context),

                const SizedBox(height: 8),

                // 3. Rounded Video Player Container & Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 200.h,
                      color: Colors.black,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showControls = !_showControls;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_controller != null && _isInitialized)
                              SizedBox.expand(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    key: ValueKey(_controller),
                                    width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 16,
                                    height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 9,
                                    child: VideoPlayer(_controller!),
                                  ),
                                ),
                              )
                            else if (_hasError)
                              _buildErrorView()
                            else
                              const Center(child: CircularProgressIndicator(color: Colors.red)),

                            if (_showControls && _controller != null && _isInitialized)
                              _buildPlayerOverlayControls(currentTitle),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Progress bar & Timer row below video player box
                if (_controller != null && _isInitialized)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                    child: Column(
                      children: [
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller!.value.position),
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 9.sp),
                            ),
                            Text(
                              _formatDuration(_controller!.value.duration),
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 9.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 4),
                Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),

                // 6. Playlist Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Playlist (${widget.videos.length} ${widget.videos.length == 1 ? 'Track' : 'Tracks'})",
                        style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          _currentIndex = 0;
                          _initController(0);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 2),
                            Text(
                              "Play All",
                              style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 7. Playlist Track Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    itemCount: widget.videos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final isSelected = index == _currentIndex;
                      final item = widget.videos[index];
                      final Map<String, dynamic> itemMap = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
                      final itemTitle = _cleanFileName((itemMap['fileName'] ?? '').toString());
                      final date = itemMap['createdAt'] != null ? itemMap['createdAt'].toString().split('T').first : "2026-09-16";

                      final String imageUrl = _getThumbnailUrl(context, itemMap);
                      final bool hasImage = imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

                      return InkWell(
                        onTap: () {
                          _currentIndex = index;
                          _initController(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF191D2B) : const Color(0xFFFFF0F2))
                                : (isDark ? const Color(0xFF131520) : Colors.white.withValues(alpha: 0.9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.red.withValues(alpha: 0.5) : (isDark ? Colors.white10 : Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Track Thumbnail Box with Playing Equalizer Overlay
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 58.w,
                                      height: 44.h,
                                      color: Colors.grey.shade900,
                                      child: hasImage
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(color: Colors.grey.shade900),
                                              errorWidget: (context, url, error) => _buildDefaultThumbnailBox(),
                                            )
                                          : _buildDefaultThumbnailBox(),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 58.w,
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.equalizer, color: Colors.red, size: 24),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Track Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemTitle,
                                      style: TextStyle(
                                        color: isSelected 
                                            ? Colors.redAccent 
                                            : (isDark ? Colors.white : Colors.black87),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 13.sp, // Decreased video title font size
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      date,
                                      style: TextStyle(
                                        color: isDark ? Colors.white38 : Colors.grey.shade600, 
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Playing Pill Badge
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3D121B),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.equalizer, color: Colors.red, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Playing",
                                        style: TextStyle(color: Colors.red, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  // Top Navigation Bar (Header)
  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          Image.asset(
            'assets/images/BigTvPostLogo.png',
            height: 32.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              "BIG TV",
              style: TextStyle(color: Colors.red, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  // Subheader Tag Info
  Widget _buildTagInfo(String tagTitle, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tagTitle,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            "మన భావోద్వేగాలకు మరో పేరు",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey.shade700,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Overlay Controls inside Video Player Frame
  Widget _buildPlayerOverlayControls(String title) {
    return Container(
      color: Colors.black38,
      child: Stack(
        children: [
          // Volume & Fullscreen icon top right
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showVolumeSlider)
                  SizedBox(
                    width: 70.w,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                        activeTrackColor: Colors.red,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _isMuted ? 0.0 : _volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) {
                          setState(() {
                            _volume = val;
                            _isMuted = val == 0;
                            _controller?.setVolume(val);
                          });
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _isMuted || _volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _showVolumeSlider = !_showVolumeSlider;
                    });
                    _toggleMute();
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.crop_free,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
          ),

          // Center controls: Skip Prev | Rewind 10s | Play/Pause | Forward 10s | Skip Next
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 26,
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: _currentIndex > 0 ? _playPrevTrack : null,
                ),
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () => _seekRelative(-10),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 36,
                    icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () => _seekRelative(10),
                ),
                IconButton(
                  iconSize: 26,
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: _currentIndex + 1 < widget.videos.length ? _playNextTrack : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fullscreen Overlay Controls
  Widget _buildFullscreenControls(String title) {
    return Container(
      color: Colors.black45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_showVolumeSlider)
                  SizedBox(
                    width: 90.w,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                        activeTrackColor: Colors.red,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _isMuted ? 0.0 : _volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) {
                          setState(() {
                            _volume = val;
                            _isMuted = val == 0;
                            _controller?.setVolume(val);
                          });
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _isMuted || _volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _showVolumeSlider = !_showVolumeSlider;
                    });
                    _toggleMute();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 22),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: _currentIndex > 0 ? _playPrevTrack : null,
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => _seekRelative(-10),
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 44,
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => _seekRelative(10),
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: _currentIndex + 1 < widget.videos.length ? _playNextTrack : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_controller!.value.position),
                      style: TextStyle(color: Colors.white, fontSize: 9.sp),
                    ),
                    Text(
                      _formatDuration(_controller!.value.duration),
                      style: TextStyle(color: Colors.white, fontSize: 9.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Error View inside Player Box
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: 6),
          Text(
            "Unable to load video track",
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => _initController(_currentIndex),
                icon: const Icon(Icons.refresh, size: 14),
                label: Text("Retry", style: TextStyle(fontSize: 11.sp)),
              ),
              if (_currentIndex + 1 < widget.videos.length) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: _playNextTrack,
                  icon: const Icon(Icons.skip_next, size: 14),
                  label: Text("Next Track", style: TextStyle(fontSize: 11.sp)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
