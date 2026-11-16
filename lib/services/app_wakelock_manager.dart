import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Centralized, reference-counted Wakelock manager for all video playback in the app.
/// Ensures the device screen does NOT turn off or lock while any video or stream
/// (Live TV, Reels, Tag Video, Movie Trailers, Fullscreen Players) is actively playing.
///
/// When playback pauses or the player is disposed, releasing the lock allows the
/// screen timeout/lock to resume naturally once no active players remain.
class AppWakelockManager {
  AppWakelockManager._();

  static final Set<String> _activeHolders = <String>{};
  static bool _isCurrentlyLocked = false;

  /// Returns true if at least one video player is currently holding the wakelock.
  static bool get isLocked => _activeHolders.isNotEmpty;

  /// Active holder tags (for logging/debugging).
  static List<String> get activeHolders => _activeHolders.toList(growable: false);

  /// Enable wakelock for a specific player tag (e.g. 'live_tv', 'reels', etc.).
  static Future<void> enable(String tag) async {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isEmpty) return;

    final wasEmpty = _activeHolders.isEmpty;
    _activeHolders.add(cleanTag);

    if (wasEmpty || !_isCurrentlyLocked) {
      try {
        await WakelockPlus.enable();
        _isCurrentlyLocked = true;
        log('[AppWakelockManager] Screen lock prevented by: "$cleanTag" (Active: ${_activeHolders.join(', ')})');
      } catch (e) {
        debugPrint('[AppWakelockManager] Error enabling wakelock for $cleanTag: $e');
      }
    }
  }

  /// Disable wakelock for a specific player tag.
  static Future<void> disable(String tag) async {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isEmpty) return;

    _activeHolders.remove(cleanTag);

    if (_activeHolders.isEmpty && _isCurrentlyLocked) {
      try {
        await WakelockPlus.disable();
        _isCurrentlyLocked = false;
        log('[AppWakelockManager] All video locks released; normal screen timeout restored.');
      } catch (e) {
        debugPrint('[AppWakelockManager] Error disabling wakelock for $cleanTag: $e');
      }
    } else if (_activeHolders.isNotEmpty) {
      log('[AppWakelockManager] Released by "$cleanTag", still held by: ${_activeHolders.join(', ')}');
    }
  }

  /// Convenience method to set wakelock based on isPlaying boolean.
  static Future<void> set(String tag, bool isPlaying) async {
    if (isPlaying) {
      await enable(tag);
    } else {
      await disable(tag);
    }
  }

  /// Failsafe release of all locks (e.g. on user logout or app background).
  static Future<void> releaseAll() async {
    _activeHolders.clear();
    if (_isCurrentlyLocked) {
      try {
        await WakelockPlus.disable();
        _isCurrentlyLocked = false;
        log('[AppWakelockManager] All locks forcibly released.');
      } catch (e) {
        debugPrint('[AppWakelockManager] Error releasing all locks: $e');
      }
    }
  }

  /// Re-evaluates wakelock state on app resume.
  static Future<void> onAppResumed() async {
    if (_activeHolders.isNotEmpty) {
      try {
        await WakelockPlus.enable();
        _isCurrentlyLocked = true;
      } catch (_) {}
    }
  }

  /// Temporarily releases wakelock on app background so device doesn't keep display awake in pocket.
  static Future<void> onAppPaused() async {
    if (_isCurrentlyLocked) {
      try {
        await WakelockPlus.disable();
        _isCurrentlyLocked = false;
      } catch (_) {}
    }
  }
}
