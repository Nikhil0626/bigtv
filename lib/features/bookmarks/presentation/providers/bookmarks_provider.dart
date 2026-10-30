import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/bookmark_post_model.dart';
import '../../data/repositories/bookmarks_repository.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/local_data.dart';

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

  bool _isLoggedIn = false;
  int? _currentUserId;

  List<BookmarkPostModel> get bookmarks => List.unmodifiable(_bookmarks);
  Set<int> get bookmarkedPostIds => Set.unmodifiable(_bookmarkedPostIds);
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  int get totalBookmarks => _totalBookmarks;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoggedIn => _isLoggedIn;
  int? get currentUserId => _currentUserId;

  BookmarksProvider() {
    _initAuthAndCache();
  }

  Future<void> _initAuthAndCache() async {
    final direct = GlobalVariables().userId;
    if (direct != null && direct.isNotEmpty) {
      final parsed = int.tryParse(direct);
      if (parsed != null && parsed > 0) {
        _isLoggedIn = true;
        _currentUserId = parsed;
      }
    }
    await _loadCachedBookmarkIds();
  }

  final Set<int> _unbookmarkedSessionIds = {};

  /// Check if a given post is bookmarked (checks cache, active set, or post's default)
  bool isPostBookmarked(dynamic postId, {bool? fallbackIsBookmarked}) {
    if (!_isLoggedIn) return false;
    final int id = int.tryParse(postId?.toString() ?? '0') ?? 0;
    if (id <= 0) return false;
    if (_bookmarkedPostIds.contains(id)) return true;
    if (_unbookmarkedSessionIds.contains(id)) return false;
    if (fallbackIsBookmarked == true) return true;
    return false;
  }

  /// Resolve numeric userId from preferences (strictly for logged-in user, returns null for guests)
  Future<int?> resolveUserId() async {
    final loggedIn = await isUserLoggedIn();
    if (!loggedIn) {
      _isLoggedIn = false;
      _currentUserId = null;
      return null;
    }

    final rawUserId = await getUserid();
    if (rawUserId != null && rawUserId.isNotEmpty) {
      final parsed = int.tryParse(rawUserId);
      if (parsed != null && parsed > 0) {
        _isLoggedIn = true;
        _currentUserId = parsed;
        return parsed;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final directUserId = prefs.getString('userId') ?? prefs.getString('loginId') ?? GlobalVariables().userId;
    final parsedDirect = int.tryParse(directUserId ?? '');
    if (parsedDirect != null && parsedDirect > 0) {
      _isLoggedIn = true;
      _currentUserId = parsedDirect;
      return parsedDirect;
    }

    _isLoggedIn = false;
    _currentUserId = null;
    return null;
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

  /// Load cached bookmarked post IDs from SharedPreferences for the logged-in user
  Future<void> _loadCachedBookmarkIds() async {
    try {
      final userId = await resolveUserId();
      if (userId == null) {
        _isLoggedIn = false;
        _currentUserId = null;
        _bookmarkedPostIds.clear();
        _bookmarks.clear();
        _totalBookmarks = 0;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('dev_cached_bookmarks_ids');
        } catch (_) {}
        notifyListeners();
        return;
      }

      _isLoggedIn = true;
      _currentUserId = userId;
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList =
          prefs.getStringList('cached_bookmarks_ids_$userId') ??
          prefs.getStringList('dev_cached_bookmarks_ids');
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

  /// Save cached bookmarked post IDs to SharedPreferences for the logged-in user
  Future<void> _saveCachedBookmarkIds() async {
    try {
      final userId = _currentUserId ?? await resolveUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();
      final list = _bookmarkedPostIds.map((e) => e.toString()).toList();
      await prefs.setStringList('cached_bookmarks_ids_$userId', list);
    } catch (e) {
      log("Error saving cached bookmark ids: $e");
    }
  }

  /// Clear all bookmark state when user logs out
  void clearBookmarksOnLogout() {
    _bookmarks = [];
    _bookmarkedPostIds.clear();
    _unbookmarkedSessionIds.clear();
    _totalBookmarks = 0;
    _currentPage = 1;
    _hasMore = true;
    _isLoggedIn = false;
    _currentUserId = null;
    notifyListeners();
  }

  /// Fetch bookmarked posts from GET /bookmarks strictly for the logged-in user
  Future<void> fetchBookmarks({bool refresh = false}) async {
    final userId = await resolveUserId();
    if (userId == null) {
      _isLoggedIn = false;
      _currentUserId = null;
      _bookmarks = [];
      _bookmarkedPostIds.clear();
      _totalBookmarks = 0;
      _currentPage = 1;
      _hasMore = false;
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
      return;
    }

    _isLoggedIn = true;
    _currentUserId = userId;

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

  /// Show login required dialog when unauthenticated user tries to bookmark
  static Future<bool> showLoginRequiredDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String langCode = 'te';
    try {
      langCode = context.read<HomeProvider>().langCode;
    } catch (_) {}
    final isTelugu = langCode == 'te';

    final bool? shouldLogin = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E222A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColorTokens.primaryRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  color: AppColorTokens.primaryRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isTelugu ? 'లాగిన్ అవ్వండి' : 'ലോഗിൻ ചെയ്യുക',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isTelugu
                ? 'వార్తలను బుక్‌మార్క్ చేయడానికి మరియు ఎప్పుడైనా చదవడానికి దయచేసి లాగిన్ అవ్వండి.'
                : 'വാർത്തകൾ ബുക്ക്‌മാർക്ക് ചെയ്യാനും പിന്നീട് വായിക്കാനും ദയവായി ലോഗിൻ ചെയ്യുക.',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(
                isTelugu ? 'రద్దు చేయి' : 'റദ്దాക്കുക',
                style: TextStyle(color: const Color(0xFF64748B), fontSize: 13.sp),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTokens.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx, true);
              },
              child: Text(
                isTelugu ? 'లాగిన్ అవ్వండి' : 'ഇപ്പോൾ ലോഗിൻ ചെയ്യുക',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogin == true && context.mounted) {
      try {
        context.read<HomeProvider>().isPlayingYoutube(false);
      } catch (_) {}
      try {
        context.read<VideoProvider>().pauseVideo();
      } catch (_) {}
      context.read<AuthenticationProvider>().newAppLoginStatus = NewAppLoginStatus.login;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginBackgroundView()),
      );
      if (context.mounted) {
        await context.read<BookmarksProvider>().fetchBookmarks(refresh: true);
        return await isUserLoggedIn();
      }
    }
    return false;
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

    // Check if user is logged in
    int? userId = await resolveUserId();
    if (userId == null) {
      if (context != null && context.mounted) {
        final didLogin = await showLoginRequiredDialog(context);
        if (didLogin && context.mounted) {
          userId = await resolveUserId();
        }
      }
      if (userId == null) {
        return false;
      }
    }

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
