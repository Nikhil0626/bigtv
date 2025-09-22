import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  String url = "";
  bool _isPlaying = false;
  bool _isMuted = false;

  VideoPlayerController? get controller => _controller;
  String get getUrl => url;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;

  /// Initialize the video controller
  Future<void> initializeVideo(String url) async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      _controller!.setLooping(true); // Loop video
      _controller!.play(); // Auto play on load
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Video initialization error: $e");
    }
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _isPlaying = false;
    } else {
      _controller!.play();
      _isPlaying = true;
    }
    notifyListeners();
  }

  /// Toggle mute/unmute
  void toggleMute() {
    if (_controller == null) return;
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
  void disposeController() {
    _controller?.dispose();
    _controller = null;
    _isPlaying = false;
    _isMuted = false;
    notifyListeners();
  }
}
