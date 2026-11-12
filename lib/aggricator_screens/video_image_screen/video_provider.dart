import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoProvider extends ChangeNotifier {
  final VideoPlayerController Function(String url)? _controllerBuilder;
  final Set<VideoPlayerController> _disposedControllers = {};
  VideoPlayerController? _controller;
  String _currentUrl = "";
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isLoading = false;

  VideoProvider({
    VideoPlayerController Function(String url)? controllerBuilder,
  }) : _controllerBuilder = controllerBuilder;

  VideoPlayerController? get controller => _controller;
  String get currentUrl => _currentUrl;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get isLoading => _isLoading;

  bool isControllerDisposed(VideoPlayerController controller) =>
      _disposedControllers.contains(controller);

  /// Initialize the video controller
  Future<void> initializeVideo(String url) async {
    if (url.trim().isEmpty) return;

    // Don't reinitialize if it's the same URL and controller already exists
    if (_controller != null &&
        _currentUrl == url &&
        _controller!.value.isInitialized) {
      return;
    }

    // Dispose previous controller if switching to a different URL
    if (_controller != null) {
      await disposeController();
    }

    try {
      _isLoading = true;
      _currentUrl = url;
      final newController = _controllerBuilder?.call(url) ??
          VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = newController;
      await newController.initialize();
      if (_controller != newController) {
        _disposedControllers.add(newController);
        await newController.dispose();
        return;
      }
      newController.setLooping(false);
      // Start paused instead of auto-playing
      _isPlaying = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint("Video initialization error: $e");
    }
  }

  /// Play video
  void playVideo() {
    if (_controller == null || !_controller!.value.isInitialized) return;
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
  Future<void> disposeController({bool notify = true}) async {
    final oldController = _controller;
    _controller = null;
    _isPlaying = false;
    _isMuted = false;
    _isLoading = false;
    _currentUrl = "";
    if (oldController != null) {
      _disposedControllers.add(oldController);
    }
    if (notify) {
      notifyListeners();
    }
    if (oldController != null) {
      try {
        await oldController.pause();
      } catch (_) {}
      try {
        await oldController.dispose();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    disposeController(notify: false);
    super.dispose();
  }
}