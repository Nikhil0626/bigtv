import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/models/series_model.dart';

class ReelsStateController extends ChangeNotifier {
  final Map<int, VideoPlayerController> controllers = {};
  int currentIndex;
  final List<EpisodeModel> episodes;
  
  final Set<int> preloadedEpisodes = {};
  final Set<int> loadingEpisodes = {};
  
  ReelsStateController(this.currentIndex, this.episodes);

  void initPreload() {
    debugPrint('[PremiumPreload] Total episodes: ${episodes.length}');
    triggerPreloadLogic(currentIndex);
  }
  
  void triggerPreloadLogic(int currentIdx) {
    int totalEpisodes = episodes.length;
    
    if (totalEpisodes < 12) {
      // Rule 1: Preload all if < 12
      debugPrint('[PremiumPreload] Initial preload: Episodes 0-${totalEpisodes - 1}');
      for (int i = 0; i < totalEpisodes; i++) {
        _startPreload(i);
      }
    } else {
      // Rule 2 & 3: Batch logic
      int currentBatchStart = (currentIdx ~/ 4) * 4;
      int thirdEpisodeIndex = currentBatchStart + 2;
      
      // On initial load, preload first batch
      if (preloadedEpisodes.isEmpty && loadingEpisodes.isEmpty) {
        int endIdx = (currentBatchStart + 3).clamp(0, totalEpisodes - 1);
        debugPrint('[PremiumPreload] Initial preload: Episodes $currentBatchStart-$endIdx');
        _preloadBatch(currentBatchStart);
      }
      
      debugPrint('[PremiumPreload] Current episode: $currentIdx');
      
      // When reaching 3rd episode of the batch, preload next batch
      if (currentIdx == thirdEpisodeIndex) {
        int nextBatchStart = currentBatchStart + 4;
        if (nextBatchStart < totalEpisodes) {
          int endIdx = (nextBatchStart + 3).clamp(0, totalEpisodes - 1);
          debugPrint('[PremiumPreload] Preloading next batch: Episodes $nextBatchStart-$endIdx');
          _preloadBatch(nextBatchStart);
        }
      }
      
      // Memory Management: Dispose controllers outside of active boundaries
      // Retain the previous batch, current batch, and next batch
      int retainStart = currentBatchStart - 4;
      int retainEnd = currentBatchStart + 7;
      
      final keysToRemove = <int>[];
      for (var key in controllers.keys) {
        if (key < retainStart || key > retainEnd) {
          controllers[key]?.dispose();
          keysToRemove.add(key);
          preloadedEpisodes.remove(key);
        }
      }
      for (var key in keysToRemove) {
        controllers.remove(key);
      }
      if (keysToRemove.isNotEmpty) {
        notifyListeners();
      }
    }
  }
  
  void _preloadBatch(int startIndex) {
    for (int i = startIndex; i < startIndex + 4; i++) {
      if (i < episodes.length) {
        _startPreload(i);
      }
    }
  }

  Future<void> _startPreload(int index) async {
    if (index < 0 || index >= episodes.length) return;
    
    // Idempotency checks
    if (preloadedEpisodes.contains(index)) {
      // debugPrint('[PremiumPreload] Episode $index already preloaded, skipping.');
      return;
    }
    if (loadingEpisodes.contains(index)) {
      // debugPrint('[PremiumPreload] Episode $index currently loading, skipping.');
      return;
    }
    if (controllers.containsKey(index)) return;
    
    final url = episodes[index].videoUrl;
    if (url.isEmpty) return;
    
    loadingEpisodes.add(index);
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    controllers[index] = controller;
    notifyListeners();
    
    try {
      await controller.initialize();
      controller.setLooping(true);
      
      loadingEpisodes.remove(index);
      preloadedEpisodes.add(index);
      
      if (index == currentIndex) {
        controller.play();
      }
    } catch (e) {
      loadingEpisodes.remove(index);
      debugPrint('[PremiumPreload] Error initializing video at index $index: $e');
    }
  }
  
  void onPageChanged(int index) {
    // Pause all other videos to prevent audio overlapping on fast scrolls
    for (var k in controllers.keys) {
      if (k != index) {
        controllers[k]?.pause();
      }
    }
    currentIndex = index;
    controllers[currentIndex]?.play();
    triggerPreloadLogic(index);
  }
  
  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    preloadedEpisodes.clear();
    loadingEpisodes.clear();
    super.dispose();
  }
}

class SeriesReelsScreen extends StatefulWidget {
  final List<EpisodeModel> episodes;
  final int initialIndex;

  const SeriesReelsScreen({
    super.key,
    required this.episodes,
    this.initialIndex = 0,
  });

  @override
  State<SeriesReelsScreen> createState() => _SeriesReelsScreenState();
}

class _SeriesReelsScreenState extends State<SeriesReelsScreen> {
  late PageController _pageController;
  late ReelsStateController _reelsStateController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _reelsStateController = ReelsStateController(widget.initialIndex, widget.episodes);
    _reelsStateController.initPreload();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reelsStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.episodes.isEmpty
          ? const Center(
              child: Text(
                'No episodes available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _reelsStateController.onPageChanged,
              itemCount: widget.episodes.length,
              itemBuilder: (context, index) {
                final episode = widget.episodes[index];
                return AnimatedBuilder(
                  animation: _reelsStateController,
                  builder: (context, _) {
                    final controller = _reelsStateController.controllers[index];
                    return ReelVideoPlayer(
                      episode: episode,
                      controller: controller,
                    );
                  },
                );
              },
            ),
    );
  }
}

class ReelVideoPlayer extends StatelessWidget {
  final EpisodeModel episode;
  final VideoPlayerController? controller;

  const ReelVideoPlayer({
    super.key,
    required this.episode,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller!,
            builder: (context, value, child) {
              if (value.isInitialized) {
                return GestureDetector(
                  onTap: () {
                    if (controller!.value.isPlaying) {
                      controller!.pause();
                    } else {
                      controller!.play();
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: value.size.width,
                            height: value.size.height,
                            child: VideoPlayer(controller!),
                          ),
                        ),
                      ),
                      if (!value.isPlaying)
                        Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      // Video Controller Progress Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: VideoProgressIndicator(
                          controller!,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          colors: const VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (value.hasError) {
                return const Center(
                  child: Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const Align(
                alignment: Alignment.bottomCenter,
                child: LinearProgressIndicator(
                  color: Colors.red,
                  backgroundColor: Colors.transparent,
                ),
              ); // Replaced with linear bar at bottom
            },
          )
        else
          const Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(
              color: Colors.red,
              backgroundColor: Colors.transparent,
            ),
          ), // Replaced with linear bar at bottom

        // Overlay info
        Positioned(
          bottom: 20, // Adjusted to make room for the progress bar
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  episode.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
