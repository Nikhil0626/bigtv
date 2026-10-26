import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/bookmark_post_model.dart';
import '../../data/repositories/bookmarks_repository.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';

class BookmarksProvider extends ChangeNotifier {
  final BookmarksRepository _repository = BookmarksRepository();

  List<BookmarkPostModel> _bookmarks = [];
  final Set<int> _bookmarkedPostIds = {};
  bool _isLoading = false;
  bool _isMoreLoading = false;
  int _totalBookmarks = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  List<BookmarkPostModel> get bookmarks => List.unmodifiable(_bookmarks);
  Set<int> get bookmarkedPostIds => Set.unmodifiable(_bookmarkedPostIds);
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  int get totalBookmarks => _totalBookmarks;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  BookmarksProvider() {
    _loadCachedBookmarkIds();
  }

  final Set<int> _unbookmarkedSessionIds = {};

  /// Check if a given post is bookmarked (checks cache, active set, or post's default)
  bool isPostBookmarked(dynamic postId, {bool? fallbackIsBookmarked}) {
    final int id = int.tryParse(postId?.toString() ?? '0') ?? 0;
    if (id <= 0) return false;
    if (_bookmarkedPostIds.contains(id)) return true;
    if (_unbookmarkedSessionIds.contains(id)) return false;
    if (fallbackIsBookmarked == true) return true;
    return false;
  }

  /// Resolve numeric userId from preferences (fallback to 12 if not logged in or guest)
  Future<int> resolveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUserId = prefs.getString('userId') ?? prefs.getString('loginId') ?? '';
    final parsed = int.tryParse(rawUserId);
    if (parsed != null && parsed > 0) {
      return parsed;
    }
    return 12; // Default dev test user ID matching backend sample
  }

  /// Resolve deviceId from preferences
  Future<String> resolveDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawDeviceId = prefs.getString('deviceId');
    if (rawDeviceId != null && rawDeviceId.trim().isNotEmpty) {
      return rawDeviceId;
    }
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Load cached bookmarked post IDs from SharedPreferences
  Future<void> _loadCachedBookmarkIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList('dev_cached_bookmarks_ids');
      if (rawList != null) {
        _bookmarkedPostIds.clear();
        for (final item in rawList) {
          final id = int.tryParse(item);
          if (id != null && id > 0) {
            _bookmarkedPostIds.add(id);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      log("Error loading cached bookmark ids: $e");
    }
  }

  /// Save cached bookmarked post IDs to SharedPreferences
  Future<void> _saveCachedBookmarkIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _bookmarkedPostIds.map((e) => e.toString()).toList();
      await prefs.setStringList('dev_cached_bookmarks_ids', list);
    } catch (e) {
      log("Error saving cached bookmark ids: $e");
    }
  }

  /// Fetch bookmarked posts from GET /bookmarks
  Future<void> fetchBookmarks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      notifyListeners();
    } else {
      if (_isLoading || _isMoreLoading || !_hasMore) return;
      if (_currentPage == 1 && _bookmarks.isEmpty) {
        _isLoading = true;
        notifyListeners();
      } else {
        _isMoreLoading = true;
        notifyListeners();
      }
    }

    try {
      final userId = await resolveUserId();
      final result = await _repository.getBookmarks(
        userId: userId,
        page: _currentPage,
        limit: _pageSize,
        isBigTv: false,
      );

      final List<BookmarkPostModel> fetchedPosts =
          (result['posts'] as List<BookmarkPostModel>?) ?? [];
      final int total = result['total'] as int? ?? fetchedPosts.length;

      if (_currentPage == 1) {
        _bookmarks = List.from(fetchedPosts);
      } else {
        _bookmarks.addAll(fetchedPosts);
      }

      _totalBookmarks = total;
      _hasMore = _bookmarks.length < _totalBookmarks && fetchedPosts.isNotEmpty;
      if (_hasMore) {
        _currentPage++;
      }

      // Sync active set of bookmarked IDs
      for (final post in _bookmarks) {
        if (post.isBookmarked) {
          _bookmarkedPostIds.add(post.id);
        }
      }
      _saveCachedBookmarkIds();
    } catch (e, st) {
      log("BookmarksProvider.fetchBookmarks error: $e", stackTrace: st);
    } finally {
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  /// Toggle bookmark for a post
  /// Returns the new bookmarked state (true = bookmarked, false = removed)
  Future<bool> toggleBookmark({
    required dynamic postId,
    Map<String, dynamic>? article,
    bool? explicitStatus,
    BuildContext? context,
  }) async {
    final int id = int.tryParse(postId?.toString() ?? '0') ?? 0;
    if (id <= 0) return false;

    final bool currentStatus = isPostBookmarked(
      id,
      fallbackIsBookmarked: article?['isBookmarked'] == true ||
          article?['isBookmarked'] == 1 ||
          article?['isBookmarked'] == 'true',
    );
    final bool targetStatus = explicitStatus ?? !currentStatus;

    // 1. Optimistic UI update
    if (targetStatus) {
      _bookmarkedPostIds.add(id);
      _unbookmarkedSessionIds.remove(id);
      AnalyticsService.instance.track(AnalyticsEventName.articleLike, properties: {'article_id': id});
      AnalyticsService.instance.track(AnalyticsEventName.articleFavorite, properties: {'article_id': id});
      if (article != null && !_bookmarks.any((b) => b.id == id)) {
        try {
          final copy = Map<String, dynamic>.from(article);
          copy['isBookmarked'] = true;
          _bookmarks.insert(0, BookmarkPostModel.fromJson(copy));
          _totalBookmarks++;
        } catch (_) {}
      }
    } else {
      _bookmarkedPostIds.remove(id);
      _unbookmarkedSessionIds.add(id);
      AnalyticsService.instance.track(AnalyticsEventName.articleUnlike, properties: {'article_id': id});
      AnalyticsService.instance.track(AnalyticsEventName.articleUnfavorite, properties: {'article_id': id});
      _bookmarks.removeWhere((b) => b.id == id);
      if (_totalBookmarks > 0) _totalBookmarks--;
    }
    _saveCachedBookmarkIds();
    notifyListeners();

    // 2. Call POST API
    try {
      final userId = await resolveUserId();
      final deviceId = await resolveDeviceId();

      final res = await _repository.toggleBookmark(
        postId: id,
        userId: userId,
        deviceId: deviceId,
        isBookmarked: targetStatus,
      );

      final String msg = res['message']?.toString() ??
          (targetStatus ? "Post bookmarked." : "Post removed from bookmarks.");

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  targetStatus
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_remove_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: targetStatus
                ? const Color(0xFF1E293B)
                : const Color(0xFF475569),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return targetStatus;
    } catch (e, st) {
      log("BookmarksProvider.toggleBookmark error: $e", stackTrace: st);
      // Revert optimistic update on failure
      if (currentStatus) {
        _bookmarkedPostIds.add(id);
      } else {
        _bookmarkedPostIds.remove(id);
      }
      _saveCachedBookmarkIds();
      notifyListeners();

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update bookmark. Please try again."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return currentStatus;
    }
  }
}
