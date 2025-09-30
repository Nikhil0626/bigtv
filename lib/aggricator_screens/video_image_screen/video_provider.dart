import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  String _currentUrl = "";
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isLoading = false;

  VideoPlayerController? get controller => _controller;
  String get currentUrl => _currentUrl;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get isLoading => _isLoading;

  /// Initialize the video controller
  Future<void> initializeVideo(String url) async {
    // Dispose previous controller if it exists
    if (_controller != null) {
      await disposeController();
    }

    // Don't reinitialize if it's the same URL and controller exists
    if (_controller != null && _currentUrl == url && _controller!.value.isInitialized) {
      return;
    }

    try {
      _isLoading = true;
      _currentUrl = url;
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      _controller!.setLooping(false);
      // _controller!.play();
      // Start paused instead of auto-playing
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Video initialization error: $e");
    }
  }

  /// Play video
  void playVideo() {
    // if (_controller == null || !_controller!.value.isInitialized) return;
    _controller!.play();
    _isPlaying = true;
    notifyListeners();
  }

  /// Pause video
  void pauseVideo() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _controller!.pause();
    _isPlaying = false;
    notifyListeners();
  }


  /// Toggle play/pause
  void togglePlayPause({bool? isPlay}) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (isPlay != null) {
      if (isPlay) {
        playVideo();
      } else {
        pauseVideo();
      }
    } else {
      if (_isPlaying) {
        pauseVideo();
      } else {
        playVideo();
      }
    }
  }

  /// Toggle mute/unmute
  void toggleMute() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isMuted) {
      _controller!.setVolume(1.0);
      _isMuted = false;
    } else {
      _controller!.setVolume(0.0);
      _isMuted = true;
    }
    notifyListeners();
  }

  /// Dispose the controller
  Future<void> disposeController() async {
    if (_controller != null) {
      await _controller!.pause();
      await _controller!.dispose();
      _controller = null;
    }
    _isPlaying = false;
    _isMuted = false;
    _currentUrl = "";
    notifyListeners();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}