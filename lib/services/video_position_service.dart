import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPositionService {
  static final Map<String, int> _inMemoryPositions = {};

  static String _getTrackKey(dynamic videoItem) {
    if (videoItem == null) return '';
    if (videoItem is! Map) return videoItem.toString();
    final url = (videoItem['url'] ?? '').toString().trim();
    if (url.isNotEmpty) return url;
    final id = (videoItem['id'] ?? '').toString().trim();
    if (id.isNotEmpty) return id;
    final fileName = (videoItem['fileName'] ?? '').toString().trim();
    return fileName;
  }

  static Future<void> savePosition(dynamic videoItem, Duration position) async {
    final key = _getTrackKey(videoItem);
    if (key.isEmpty) return;
    final seconds = position.inSeconds;
    _inMemoryPositions[key] = seconds;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('video_pos_$key', seconds);
      log("Saved playback position $seconds sec for key: $key");
    } catch (e) {
      log("Error saving video position: $e");
    }
  }

  static Future<Duration> getSavedPosition(dynamic videoItem) async {
    final key = _getTrackKey(videoItem);
    if (key.isEmpty) return Duration.zero;

    if (_inMemoryPositions.containsKey(key)) {
      final cachedSec = _inMemoryPositions[key] ?? 0;
      return Duration(seconds: cachedSec);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final seconds = prefs.getInt('video_pos_$key') ?? 0;
      _inMemoryPositions[key] = seconds;
      return Duration(seconds: seconds);
    } catch (e) {
      log("Error getting video position: $e");
      return Duration.zero;
    }
  }

  static Future<void> clearPosition(dynamic videoItem) async {
    final key = _getTrackKey(videoItem);
    if (key.isEmpty) return;
    _inMemoryPositions.remove(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('video_pos_$key');
      log("Cleared playback position for key: $key");
    } catch (e) {
      log("Error clearing video position: $e");
    }
  }
}
