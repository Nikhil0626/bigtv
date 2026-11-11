import 'dart:developer';

import 'package:chotanews/aggricator_screens/polls_screens/poll_model.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_toasts.dart';
import '../events_data/event_repo.dart';

class PollProvider with ChangeNotifier {
  PollProvider({
    PollRepo? pollRepo,
    Future<void> Function(Map<String, dynamic> eventData, String eventName)?
        eventTracker,
  })  : _pollRepo = pollRepo,
        _eventTracker = eventTracker;

  PollRepo? _pollRepo;
  PollRepo get pollRepo => _pollRepo ??= PollRepo();
  final Future<void> Function(Map<String, dynamic> eventData, String eventName)?
      _eventTracker;

  final TextEditingController commentController = TextEditingController();
  int? userVotedOptionId;
  int? tempSelectedOptionId;
  Map<String, dynamic> localArticle = {};
  PollData? currentPollData;

  // Provider-managed UI state (migrated from widget-local setState)
  final Set<String> _submittingPostIds = {};
  int _currentPollIndex = 0;
  bool _isGridView = false;

  int get currentPollIndex => _currentPollIndex;
  bool get isGridView => _isGridView;

  String _normalizePostKey(dynamic postId) => (postId ?? '0').toString();

  bool isSubmittingVoteForPost(dynamic postId) =>
      _submittingPostIds.contains(_normalizePostKey(postId));

  void setSubmittingVoteForPost(dynamic postId, bool submitting) {
    final key = _normalizePostKey(postId);
    if (submitting) {
      _submittingPostIds.add(key);
    } else {
      _submittingPostIds.remove(key);
    }
    notifyListeners();
  }

  void initFeedView({int initialIndex = 0}) {
    _currentPollIndex = initialIndex;
    _isGridView = false;
  }

  void setCurrentPollIndex(int index) {
    if (_currentPollIndex == index) return;
    _currentPollIndex = index;
    notifyListeners();
  }

  void setGridView(bool value) {
    if (_isGridView == value) return;
    _isGridView = value;
    notifyListeners();
  }

  void selectPollFromGrid(int index) {
    _currentPollIndex = index;
    _isGridView = false;
    notifyListeners();
  }

  Box<dynamic>? _getPollBox() {
    try {
      if (Hive.isBoxOpen('pollBox')) {
        final box = Hive.box('pollBox');
        if (box.isOpen) return box;
      }
    } catch (e) {
      log('Hive pollBox access note: $e');
    }
    return null;
  }

  void setTempSelectedOptionId(int id) {
    tempSelectedOptionId = id;
    notifyListeners();
  }

  void addData(dynamic artical) async {
    tempSelectedOptionId = null;
    await loadPollFromHive(artical);
  }

  void clearData() async {
    localArticle = {};
    userVotedOptionId = null;
    tempSelectedOptionId = null;
    currentPollData = null;
    notifyListeners();

    final box = _getPollBox();
    if (box != null) {
      await box.clear();
    }
    log('🧹 All Hive data cleared from pollBox');
  }

  Future<void> loadPollFromHive(dynamic artical) async {
    if (artical == null || artical is! Map) return;
    final box = _getPollBox();
    final postId = artical['id'];
    if (postId != null) {
      if (box != null) {
        final List<dynamic> storedPosts =
            box.get('pollPosts', defaultValue: []);
        final existingPost = storedPosts.firstWhere(
          (post) => post is Map && post['id'] == postId,
          orElse: () => {},
        );

        if (existingPost is Map && existingPost.isNotEmpty) {
          localArticle = Map<String, dynamic>.from(existingPost);
          if (localArticle['pollData'] is Map &&
              localArticle['pollData']['userHasVoted'] == true) {
            final options = localArticle['pollData']['options'];
            if (options is List) {
              Map<dynamic, dynamic>? votedOption;
              for (final opt in options) {
                if (opt is Map && opt['selected'] == true) {
                  votedOption = opt;
                  break;
                }
              }
              if (votedOption != null) {
                userVotedOptionId =
                    votedOption['id'] ?? votedOption['option'];
              }
            }
          }
        } else {
          await storePostInHive(artical);
        }
      }
      localArticle = Map<String, dynamic>.from(artical);

      // Hydrate PollData if available
      if (localArticle['pollData'] is Map) {
        currentPollData = PollData.fromJson(
          Map<String, dynamic>.from(localArticle['pollData'] as Map),
        );
        if (currentPollData!.userHasVoted &&
            currentPollData!.userVotedOption != null) {
          userVotedOptionId = currentPollData!.userVotedOption;
        }
      }

      notifyListeners();
    }
  }

  Future<void> storePostInHive(dynamic artical) async {
    final box = _getPollBox();
    if (box == null) return;
    final postId = artical['id'];
    if (postId != null) {
      final List<dynamic> storedPosts = List<dynamic>.from(
        box.get('pollPosts', defaultValue: []) as List,
      );
      final alreadyExists =
          storedPosts.any((post) => post is Map && post['id'] == postId);

      if (!alreadyExists) {
        storedPosts.add(artical);
        await box.put('pollPosts', storedPosts);
        notifyListeners();
      }
    }
  }

  Future<void> updatePollVoteInHive({
    required int postId,
    required int optionId,
    required Map<String, dynamic> commentBody,
  }) async {
    final box = _getPollBox();
    final List<dynamic> storedPosts = box != null
        ? List<dynamic>.from(box.get('pollPosts', defaultValue: []) as List)
        : <dynamic>[];
    final postIndex =
        storedPosts.indexWhere((post) => post is Map && post['id'] == postId);

    Map<String, dynamic> post;
    if (postIndex != -1) {
      post = Map<String, dynamic>.from(storedPosts[postIndex] as Map);
    } else if (localArticle.isNotEmpty &&
        (localArticle['id'] == postId || localArticle['post_id'] == postId)) {
      post = Map<String, dynamic>.from(localArticle);
    } else if (localArticle.isNotEmpty) {
      post = Map<String, dynamic>.from(localArticle);
    } else {
      post = <String, dynamic>{
        'id': postId,
        'pollData': <String, dynamic>{},
      };
    }

    final rawOptions =
        post['pollData']?['options'] ?? post['poll_options'] ?? [];
    final options = List<Map<String, dynamic>>.from(
      (rawOptions as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    int totalVotes = 0;

    for (var option in options) {
      final optId = option['id'] ?? option['option'];
      if (optId == optionId) {
        option['votes'] = ((option['votes'] ?? 0) as num).toInt() + 1;
        option['selected'] = true;
      } else {
        option['selected'] = false;
      }
      totalVotes += ((option['votes'] ?? 0) as num).toInt();
    }

    for (var option in options) {
      final v = ((option['votes'] ?? 0) as num).toDouble();
      option['percentage'] =
          totalVotes > 0 ? ((v / totalVotes) * 100).toDouble() : 0.0;
    }

    post['pollData'] = post['pollData'] is Map
        ? Map<String, dynamic>.from(post['pollData'] as Map)
        : <String, dynamic>{};
    post['pollData']['options'] = options;
    post['pollData']['userHasVoted'] = true;
    post['pollData']['userVotedOption'] = optionId;
    post['pollData']['totalVotes'] = totalVotes;
    if (commentBody.isNotEmpty) {
      if (post['topComments'] == null ||
          (post['topComments'] as List).isEmpty) {
        post['topComments'] = [commentBody];
      } else {
        (post['topComments'] as List).add(commentBody);
      }
    }

    if (box != null) {
      if (postIndex != -1) {
        storedPosts[postIndex] = post;
      } else {
        storedPosts.add(post);
      }
      await box.put('pollPosts', storedPosts);
    }

    localArticle = post;
    currentPollData =
        PollData.fromJson(Map<String, dynamic>.from(post['pollData'] as Map));
    userVotedOptionId = optionId;
    commentController.text = '';
    notifyListeners();
  }

  // Fetch Live Poll Results (GET /polls/{post_id}/results)
  Future<PollData?> fetchLivePollResults(int postId) async {
    final sp = await SharedPreferences.getInstance();
    final userId = sp.getString('userId');
    try {
      final Response response =
          await pollRepo.getPollResults(postId, userId: userId);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        currentPollData = PollData.fromJson(data);
        if (currentPollData!.userHasVoted &&
            currentPollData!.userVotedOption != null) {
          userVotedOptionId = currentPollData!.userVotedOption;
        }
        if (localArticle.isNotEmpty) {
          localArticle['pollData'] = currentPollData!.toJson();
        }
        notifyListeners();
        return currentPollData;
      }
    } catch (e, st) {
      log('Error fetching live poll results: $e -- $st');
    }
    return null;
  }

  // Submit Poll Vote (POST /polls/submit)
  Future<void> submitPolls(
    dynamic postId,
    int index,
    dynamic pollsOptions,
    dynamic articleTitle, {
    VoidCallback? onSuccess,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final userId = sp.getString('userId');
    final userName = sp.getString('userName');

    final intPostId = int.tryParse(postId.toString()) ?? 0;
    final intUserId = int.tryParse(userId ?? '0');
    final intSelectedOption = pollsOptions is num
        ? pollsOptions.toInt()
        : (int.tryParse(pollsOptions.toString()) ?? 0);

    final body = {
      'post_id': intPostId != 0 ? intPostId : postId,
      'user_id':
          intUserId != null && intUserId > 0 ? intUserId : (userId ?? '0'),
      'selected_option': intSelectedOption,
      'comment': commentController.text.trim(),
    };

    log('Submitting Poll Vote: $body');

    try {
      final Response response = await pollRepo.submitPolls(body);
      log('Poll submit response status: ${response.statusCode}, data: ${response.data}');
      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final commentBody = {
          'userName': userName ?? 'user',
          'userPhoto': null,
          'comment': commentController.text.trim(),
          'createdAt': formatter.format(DateTime.now()),
        };

        await updatePollVoteInHive(
          optionId: intSelectedOption,
          postId: intPostId,
          commentBody: commentController.text.isNotEmpty ? commentBody : {},
        );

        userVotedOptionId = intSelectedOption;
        CustomToast.showSuccessToast(
          msg: 'మీ ఓటు విజయవంతంగా నమోదు చేయబడింది!',
        );
        await _trackEventSafely(
          {
            'post_id': intPostId,
            'user_id': userId ?? '0',
            'post_title': articleTitle?.toString() ?? '',
            'selected_option': intSelectedOption,
            'comment': commentController.text.trim(),
          },
          'submit_poll',
        );
        if (onSuccess != null) onSuccess();
      } else {
        final errorMessage = response.data is Map
            ? (response.data['message'] ?? 'సమర్పించడం విఫలమైంది')
            : 'సమర్పించడం విఫలమైంది';
        CustomToast.showErrorToast(msg: errorMessage);
      }
    } on DioException catch (e, st) {
      log('DioException: $e \nStackTrace: $st');
      final errorMsg = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Network error occurred!')
          : 'Network error occurred!';
      CustomToast.showErrorToast(msg: errorMsg);
    } catch (e, st) {
      log('Exception: $e \nStackTrace: $st');
      CustomToast.showErrorToast(msg: 'Unexpected error occurred!');
    } finally {
      notifyListeners();
    }
  }

  /// Coordinates vote submission and loading state for a poll card.
  Future<void> executeVoteForArticle({
    required int optId,
    required Map<String, dynamic> article,
    required String title,
  }) async {
    final rawId = article['id'] ?? article['post_id'] ?? 888801;
    if (isSubmittingVoteForPost(rawId)) return;

    setSubmittingVoteForPost(rawId, true);
    final int pId = int.tryParse(rawId.toString()) ?? 0;
    setTempSelectedOptionId(optId);

    try {
      await submitPolls(
        rawId,
        0,
        optId,
        title,
        onSuccess: () {
          if (pId > 0) {
            fetchLivePollResults(pId);
          }
        },
      );
    } catch (e) {
      log('Error executing poll vote: $e');
    } finally {
      setSubmittingVoteForPost(rawId, false);
    }
  }

  Map<dynamic, dynamic> getAllPollCommentsList = {};
  bool isLoading = false;

  Future<void> getAllPollComments(String postId, dynamic name) async {
    isLoading = true;
    try {
      final Response response = await pollRepo.getAllPollComments(postId);
      if (response.statusCode == 200) {
        getAllPollCommentsList = response.data is Map ? response.data as Map : {};
        notifyListeners();
      }
    } catch (e, st) {
      log('Poll comments fetch error: $e --- $st');
    } finally {
      isLoading = false;
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
      log('PollProvider event tracking skipped: $e');
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
