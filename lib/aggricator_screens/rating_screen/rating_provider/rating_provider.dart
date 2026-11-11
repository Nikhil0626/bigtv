import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_toasts.dart';
import '../../events_data/event_repo.dart';
import '../rating_model.dart';
import '../rating_repo/rating_repo.dart';

class RatingProvider extends ChangeNotifier {
  RatingProvider({
    RatingRepo? ratingRepo,
    Future<void> Function(Map<String, dynamic> eventData, String eventName)?
        eventTracker,
  })  : _ratingRepo = ratingRepo,
        _eventTracker = eventTracker;

  RatingRepo? _ratingRepo;
  RatingRepo get ratingRepo => _ratingRepo ??= RatingRepo();
  final Future<void> Function(Map<String, dynamic> eventData, String eventName)?
      _eventTracker;

  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();

  int selectedStar = 0;
  int selectedOption = 0;
  bool isLoading = false;
  bool isRated = false;
  List<Map<String, dynamic>> ratingsList = [];

  // Movie review breakdown & critic scores
  MovieReviewDetails? movieReviewDetails;
  Map<String, dynamic> getAllReviews = {};
  final Map<String, List<dynamic>> _postReviewsMap = {};
  bool isLoadingComments = false;
  bool isFilterData = false;

  Set<int> ratedArticleIds = {};

  // Provider-managed UI state (migrated from widget-local setState)
  final Set<String> _editingPostIds = {};
  final Set<String> _submittingPostIds = {};
  final Map<String, String> _userCommentsByPost = {};
  final Map<String, TextEditingController> _postCommentControllers = {};
  String _userName = '';
  int _currentReviewIndex = 0;
  bool _isGridView = false;

  String get userName => _userName;
  int get currentReviewIndex => _currentReviewIndex;
  bool get isGridView => _isGridView;

  String _normalizePostKey(dynamic postId) => (postId ?? '0').toString();

  bool isEditingForPost(dynamic postId) =>
      _editingPostIds.contains(_normalizePostKey(postId));

  bool isSubmittingForPost(dynamic postId) =>
      _submittingPostIds.contains(_normalizePostKey(postId));

  String getUserComment(dynamic postId) =>
      _userCommentsByPost[_normalizePostKey(postId)] ?? '';

  TextEditingController getCommentControllerForPost(dynamic postId) {
    final key = _normalizePostKey(postId);
    return _postCommentControllers.putIfAbsent(
      key,
      () => TextEditingController(),
    );
  }

  void setEditingForPost(
    dynamic postId,
    bool editing, {
    bool prefillExistingComment = true,
  }) {
    final key = _normalizePostKey(postId);
    if (editing) {
      _editingPostIds.add(key);
      if (prefillExistingComment) {
        final existing = _userCommentsByPost[key] ?? '';
        getCommentControllerForPost(key).text = existing;
      }
    } else {
      _editingPostIds.remove(key);
    }
    notifyListeners();
  }

  void toggleEditingForPost(dynamic postId) {
    final currentlyEditing = isEditingForPost(postId);
    setEditingForPost(postId, !currentlyEditing);
  }

  void setSubmittingForPost(dynamic postId, bool submitting) {
    final key = _normalizePostKey(postId);
    if (submitting) {
      _submittingPostIds.add(key);
    } else {
      _submittingPostIds.remove(key);
    }
    notifyListeners();
  }

  void setUserComment(
    dynamic postId,
    String comment, {
    bool notify = true,
  }) {
    final key = _normalizePostKey(postId);
    final trimmed = comment.trim();
    if (trimmed.isEmpty) return;
    if (_userCommentsByPost[key] == trimmed) return;
    _userCommentsByPost[key] = trimmed;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> loadUserName() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final storedName = sp.getString('userName');
      if (storedName != null && storedName.trim().isNotEmpty) {
        final trimmed = storedName.trim();
        if (_userName != trimmed) {
          _userName = trimmed;
          notifyListeners();
        }
      }
    } catch (e) {
      log('Error loading user data: $e');
    }
  }

  void initFeedView({int initialIndex = 0}) {
    _currentReviewIndex = initialIndex;
    _isGridView = false;
  }

  void setCurrentReviewIndex(int index) {
    if (_currentReviewIndex == index) return;
    _currentReviewIndex = index;
    notifyListeners();
  }

  void setGridView(bool value) {
    if (_isGridView == value) return;
    _isGridView = value;
    notifyListeners();
  }

  void selectReviewFromGrid(int index) {
    _currentReviewIndex = index;
    _isGridView = false;
    notifyListeners();
  }

  List<dynamic> getReviewsForPost(String postId) {
    if (_postReviewsMap.containsKey(postId)) {
      return _postReviewsMap[postId] ?? [];
    }
    return (getAllReviews['reviews'] as List?) ?? [];
  }

  void addLocalReview(String postId, Map<String, dynamic> review) {
    _postReviewsMap.putIfAbsent(postId, () => []);
    _postReviewsMap[postId]!
        .removeWhere((r) => r is Map && r['comment'] == review['comment']);
    _postReviewsMap[postId]!.insert(0, review);
    notifyListeners();
  }

  // Add or update rating properly
  void ratingUpdate(int rating, dynamic article, {bool isNew = false}) {
    final postId = article.toString();

    final existingIndex = ratingsList.indexWhere(
      (element) => element['postId'].toString() == postId,
    );

    if (existingIndex != -1) {
      ratingsList[existingIndex]['starRating'] = rating;
    } else {
      ratingsList.add({'postId': postId, 'starRating': rating});
    }

    selectedStar = rating;
    if (!isNew) {
      notifyListeners();
    }
  }

  // Safe getPostRating without errors
  int getPostRating(dynamic article) {
    final ratingEntry = ratingsList.firstWhere(
      (element) => element['postId'].toString() == article.toString(),
      orElse: () => {},
    );

    if (ratingEntry.isEmpty) return 0;

    selectedStar = ratingEntry['starRating'] ?? 0;
    return selectedStar;
  }

  void markAsRated(int articleId) {
    ratedArticleIds.add(articleId);
    notifyListeners();
  }

  bool isArticleRated(int articleId) {
    return ratedArticleIds.contains(articleId);
  }

  // Submit or update user star rating & review comment
  Future<bool> postSubmitRating(
    dynamic article,
    dynamic rated,
    dynamic title,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final deviceId = preferences.getString('deviceId');
    final userId = preferences.getString('userId');

    final parsedPostId = int.tryParse(article.toString());
    final parsedUserId = int.tryParse(userId ?? '0');

    final body = <String, dynamic>{
      'post_id': parsedPostId ?? article.toString(),
      'user_id':
          parsedUserId != null && parsedUserId > 0 ? parsedUserId : (userId ?? '0'),
      'rating': selectedStar,
      'comment': commentController.text.trim(),
      'device_id': deviceId ?? '',
    };

    log('Submitting rating: $body');

    try {
      final Response response = await ratingRepo.postSubmitRating(body);
      log('Submitting rating response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ratingsList.removeWhere(
          (element) => element['postId'].toString() == article.toString(),
        );
        ratingsList.add({'postId': article.toString(), 'starRating': selectedStar});

        markAsRated(int.tryParse(article.toString()) ?? 0);
        final commentSaved = commentController.text.trim();
        commentController.clear();

        final msg = response.data is Map
            ? (response.data['message'] ?? 'రేటింగ్ విజయవంతంగా నమోదు చేయబడింది!')
            : 'రేటింగ్ విజయవంతంగా నమోదు చేయబడింది!';
        CustomToast.showSuccessToast(msg: msg);
        await _trackEventSafely(
          {
            'post_id': article.toString(),
            'user_id': userId ?? '',
            'post_title': title?.toString() ?? '',
            'rating': selectedStar,
            'comment': commentSaved,
            'device_id': deviceId.toString(),
          },
          'submit_rating',
        );
        return true;
      } else {
        final errorMsg = response.data is Map
            ? (response.data['message'] ?? 'సమర్పించడం విఫలమైంది')
            : 'సమర్పించడం విఫలమైంది';
        CustomToast.showErrorToast(msg: errorMsg);
        return false;
      }
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(
        msg: e.response?.data?['message'] ?? 'Something went wrong',
      );
      log('Dio error: $e ---- $st');
      return false;
    } catch (e, st) {
      log('Catch error: $e --- $st');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Coordinates validation, submission, local cache hydration, and editing
  /// state transitions for a specific movie review card.
  Future<bool> submitReviewForArticle({
    required dynamic articleId,
    required dynamic userHasReviewed,
    required dynamic title,
    required int fallbackRating,
  }) async {
    final postKey = _normalizePostKey(articleId);
    if (isSubmittingForPost(postKey)) return false;

    final controller = getCommentControllerForPost(postKey);
    final commentText = controller.text.trim();
    if (commentText.isEmpty) {
      CustomToast.showErrorToast(
        msg: 'దయచేసి మీ సమీక్షను/కామెంట్‌ను నమోదు చేయండి',
      );
      return false;
    }

    final selectedRating = getPostRating(articleId ?? 0);
    if (selectedRating <= 0 && fallbackRating <= 0) {
      CustomToast.showErrorToast(msg: 'దయచేసి రేటింగ్ ఎంచుకోండి');
      return false;
    }
    if (selectedRating <= 0 && fallbackRating > 0) {
      ratingUpdate(fallbackRating, articleId ?? 0, isNew: true);
    }

    setSubmittingForPost(postKey, true);
    commentController.text = commentText;

    try {
      final success = await postSubmitRating(
        articleId ?? 0,
        userHasReviewed,
        title,
      );

      if (success) {
        final nowStr = DateTime.now().toUtc().toIso8601String();
        addLocalReview(
          postKey,
          {
            'user': {'name': _userName.isNotEmpty ? _userName : 'మీరు'},
            'comment': commentText,
            'rating': selectedRating > 0 ? selectedRating : fallbackRating,
            'created_at': nowStr,
          },
        );

        if (articleId != null) {
          await getReviews(articleId.toString(), 'newest');
        }

        _userCommentsByPost[postKey] = commentText;
        _editingPostIds.remove(postKey);
      }
      return success;
    } finally {
      _submittingPostIds.remove(postKey);
      notifyListeners();
    }
  }

  // Filter reviews
  void filterData(dynamic rating) {
    isFilterData = !isFilterData;
    notifyListeners();
    getReviews(
      rating.toString(),
      isFilterData ? 'highest_rated' : 'lowest_rated',
    );
  }

  // Fetch Review Details & Critic Breakdown (GET /moviereviews/{post_id})
  Future<void> getReviews(String postId, dynamic name) async {
    final queryParams = <String, dynamic>{
      'sort_by': name?.toString() ?? 'newest',
      'limit': 50,
    };
    isLoadingComments = true;
    try {
      final Response response = await ratingRepo.getReviews(postId, queryParams);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          getAllReviews = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          getAllReviews = Map<String, dynamic>.from(response.data as Map);
        }
        movieReviewDetails = MovieReviewDetails.fromJson(getAllReviews);
        if (getAllReviews['reviews'] is List) {
          _postReviewsMap[postId] =
              List<dynamic>.from(getAllReviews['reviews'] as List);
        }
        notifyListeners();
      }
    } catch (e, st) {
      log('Review fetch error: $e --- $st');
    } finally {
      isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<void> _trackEventSafely(
    Map<String, dynamic> eventData,
    String eventName,
  ) async {
    try {
      if (_eventTracker != null) {
        await _eventTracker(eventData, eventName);
      } else {
        await EventRepo().addEvent(eventData, eventName);
      }
    } catch (e) {
      log('RatingProvider event tracking skipped: $e');
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    for (final controller in _postCommentControllers.values) {
      controller.dispose();
    }
    _postCommentControllers.clear();
    super.dispose();
  }
}
