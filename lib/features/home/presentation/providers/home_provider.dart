import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/main.dart';
import 'package:app_links/app_links.dart';

import 'package:chotanews/aggricator_screens/contest_screen/contest_provider.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/features/home/data/repositories/home_repo.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_detail_screen.dart';
import 'package:chotanews/features/home/presentation/screens/tag_video_player_screen.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_event_screen.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/services/deviice_details.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/translation_service.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';



class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];

  List getAllAiTagsList = [];
  List getAllAiTagsPostList = [];
  List tagVideosList = [];
  bool isTagVideosLoading = false;
  String currentTagSlug = "";
  String currentTagTitle = "";
  String? currentTagThumbnailUrl;
  List getAllSurveyDataList = [];
  List getImageAdsList = [];



  var getSinglePostList = {};
  int aiCurrentPostId = 0;
  int selectedIndex = 0;
  bool isSwitched = false;
  bool isWebView = false;
  String webUrl = '';
  bool isHomeLoading = false;
  bool isPlaying = false;
  bool isPostLoading = false;
  bool isMuted = false;
  bool isImageAdClose = false;
  late YoutubePlayerController controller;
  dynamic _selectedTagId;

  bool isVideoPlaying = false;
  bool isVideosMuted = false;
  late VideoPlayerController videoController;

  dynamic get selectedTagId => _selectedTagId;

  String langCode = 'te';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    langCode = prefs.getString("selectedLanguageCode") ?? "te";
    isEnglishMode = langCode == 'en';
    notifyListeners();
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void isImageAd() {
    isImageAdClose = true;
    notifyListeners();
  }

  void clearSinglePost() {
    getSinglePostList = {};
    isPostLoading = true;
    notifyListeners();
  }

  bool folkNight = false;
  bool liveTvVideosEnable = true;
  bool aiTagEnable = true;
  bool englishLanguageEnable = true;
  bool liveTvCountEnable = true;

  bool get showTopNavTags => liveTvVideosEnable || aiTagEnable;

  bool isEnglishMode = false;
  void toggleEnglishMode() {
    isEnglishMode = !isEnglishMode;
    if (isEnglishMode) {
      // Ensure model is ready (retries if previous attempt failed)
      TranslationService().init();
      TranslationService().preloadAllArticles(getAllPostList);
    }
    notifyListeners();
  }

  void setEnglishMode(bool value) {
    if (isEnglishMode != value) {
      toggleEnglishMode();
    }
  }

  Future<void> getAppConfig() async {
    try {
      Response response = await HomeRepo().getAppConfig();
      log("getAppConfig response [${response.statusCode}]: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {}
        }
        if (responseData != null && responseData is Map && responseData['success'] == true) {
          var dataList = responseData['data'];
          Map<String, dynamic>? configMap;
          if (dataList is List && dataList.isNotEmpty) {
            configMap = Map<String, dynamic>.from(dataList.first);
          } else if (dataList is Map) {
            configMap = Map<String, dynamic>.from(dataList);
          }

          if (configMap != null) {
            folkNight = configMap['folkNight'] == true;
            liveTvVideosEnable = configMap['livetvvideos'] ?? true;
            aiTagEnable = configMap['aitag'] ?? true;
            englishLanguageEnable = configMap['englishLanguage'] ?? true;
            liveTvCountEnable = configMap['livetvcount'] ?? true;

            log("AppConfig updated: folkNight=$folkNight, liveTvVideosEnable=$liveTvVideosEnable, aiTagEnable=$aiTagEnable, englishLanguageEnable=$englishLanguageEnable, liveTvCountEnable=$liveTvCountEnable");
            notifyListeners();

            getAllAiTags();
          }
        }
      }
    } catch (e, st) {
      log("Error fetching app config: $e", stackTrace: st);
    }
  }

  void isTabChange() {
    isSwitched = false;
    notifyListeners();
  }

  void switchChange(dynamic value) {
    isSwitched = !isSwitched;
    notifyListeners();
  }

  bool isReload = false;

  void isReloadData() {
    isReload = true;
    notifyListeners();
  }

  void isReloadFalse() {
    isReload = false;
    notifyListeners();
  }

  void isPlayingYoutube(bool value) {
    isPlaying = value;
    if (!value) {
      try {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      } catch (e) {
        log("Error pausing YouTube controller: $e");
      }
    }
    notifyListeners();
  }

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  void currentAiPostId(int value) {
    aiCurrentPostId = value;
    notifyListeners();
  }

  void youtubeInitial(String url) {
    String videoId = YoutubePlayer.convertUrlToId(url) ?? url;
    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: false,
        forceHD: false,
        disableDragSeek: true,
        isLive: false,
        showLiveFullscreenButton: false,
      ),
    );
  }

  void youtubeDispose() {
    log("Disposing YouTube controller");
    controller.dispose();
    notifyListeners();
  }

  void setSelectedTagId(dynamic id) {
    if (id == null || id == 0 || id == "0") {
      _selectedTagId = null;
    } else {
      _selectedTagId = id;
    }
    notifyListeners();
  }

  Future<void> getIndividualPost(dynamic postId, {bool isAds = false, bool isLink = false}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    log("getIndividualPost $postId");
    if (isAds == true) {
      clearSinglePost();
    } else {
      getAllPostList = [];
    }
    isPostLoading = true;
    String userId = preferences.getString("userId") ?? "0";
    Map<String, dynamic> body = {"user_id": userId, "isBigTv": "true"};
    try {
      Response response = await HomeRepo().getSinglePost(body, postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        if (isAds == false) {
          getAllPostList.add(response.data['data']);
          Future.delayed(
            const Duration(milliseconds: 100),
                () {
              if (!isAds) {
                getAllPost(isGetAllPost: true);
              }
              if (isLink) {
                EventRepo().addEvent({
                  "platform": Platform.isIOS ? "iOS" : "Android",
                  "comeFrom": "Notification",
                  "postId": postId.toString(),
                  "postTitle": response.data['data']['title'] ?? "",
                  "createAt": DateTime.now().toString()
                }, "opened_via_notification");
              } else {
                EventRepo().addEvent({
                  "platform": Platform.isIOS ? "iOS" : "Android",
                  "comeFrom": "Deeplink",
                  "postId": postId.toString(),
                  "postTitle": response.data['data']['title'] ?? "",
                  "createAt": DateTime.now().toString()
                }, "opened_via_deeplink");
              }
            },
          );
        } else {
          getSinglePostList = response.data['data'];
          if (isLink) {
            EventRepo().addEvent({
              "platform": Platform.isIOS ? "iOS" : "Android",
              "comeFrom": "Notification",
              "postId": postId.toString(),
              "postTitle": getSinglePostList['title'] ?? "",
              "createAt": DateTime.now().toString()
            }, "opened_via_notification");
          } else {
            EventRepo().addEvent({
              "platform": Platform.isIOS ? "iOS" : "Android",
              "comeFrom": "Deeplink",
              "postId": postId.toString(),
              "postTitle": getSinglePostList['title'] ?? "",
              "createAt": DateTime.now().toString()
            }, "opened_via_deeplink");
          }
        }
      }
    } on DioException catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          getAllPost(isGetAllPost: true);
        },
      );
      isPostLoading = false;
      notifyListeners();
    } catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          getAllPost(isGetAllPost: true);
        },
      );
      isPostLoading = false;
      notifyListeners();
    } finally {
      isPostLoading = false;
      isReload = false;
      notifyListeners();
    }
  }

  PageController? pageController = PageController();
  String? allPostLastId = "0";

  void scrollListener() {
    if (pageController!.position.atEdge) {
      bool isEnd = pageController!.position.pixels != 0;
      if (isEnd) {
        log("postId.toString() $postId");
        if (!isAiTagDataLoaded && allPostLastId != "0") {
          postId = "0";
          getAllPost(postIds: allPostLastId ?? "0");
        }
      }
    }
  }

  Future<void> getAllPost({String postIds = "0", bool isGetAllPost = false}) async {
    final context = mainNavigatorKey.currentContext;
    if (context != null) {
      context.read<RatingProvider>().ratingsList = [];
      context.read<RatingProvider>().ratedArticleIds = {};
      context.read<PollProvider>().clearData();
    }

    isHomeLoading = true;
    if (isGetAllPost == false && postIds == "0") {
      getAllPostList = [];
      _currentPageIndex = 0;
    }
    isBookMark = [];

    isWebView = false;
    webUrl = "";
    allPostLastId = "0";
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String langCode = preferences.getString("selectedLanguageCode") ?? "te";

    String? deviceId = preferences.getString("deviceId");
    String? userIdStr = preferences.getString("userId");
    int userId = 0;
    if (userIdStr != null && userIdStr.isNotEmpty) {
      userId = int.tryParse(userIdStr) ?? 0;
    }

    Map<String, dynamic> body = {
      "device_id": deviceId ?? "",
      "postId": int.tryParse(postIds) ?? 0,
      "locationIds": [],
      "categoriesId": [],
      "userId": userId,
      "isAdManager": false,
      "isBigTv": true,
      "lang": langCode,
      "isHomePost": true,
      "isHomePast": true,
    };
    log("all post body ${body.toString()}");
    try {
      Response response = await HomeRepo().getAllPosts(body);
      
      var responseData = response.data;
      List data = [];
      if (responseData is Map) {
         data = responseData['posts'] ?? responseData['data'] ?? [];
         isWebView = responseData['webView'] ?? false;
         webUrl = responseData['webUrl'] ?? "";
         allPostLastId = responseData['lastId']?.toString() ?? "0";
         if (responseData['ads_list'] != null) {
           getImageAdsList.addAll(responseData['ads_list']);
         }
      } else if (responseData is List) {
         data = responseData;
         // Setup simple pagination continuation if max limit is reached
         allPostLastId = data.length >= 100 ? "1" : "0";
      }

      // Extract homepost items from response and prepend them to the feed
      List homePosts = [];
      if (responseData is Map && responseData['homepost'] != null && responseData['homepost'] is List) {
        homePosts = responseData['homepost'];
      } else if (data.isNotEmpty && data[0] is Map && data[0]['homepost'] != null) {
        final raw = data[0]['homepost'];
        if (raw is List) {
          homePosts = raw;
        }
        // Remove the homepost wrapper element from regular data
        data = data.sublist(1);
      }
      log("Extracted homePosts count: ${homePosts.length}");

      // Extract top-level morefollow items if present
      List moreFollowList = [];
      if (responseData is Map) {
        final raw = responseData['morefollow'] ??
            responseData['more_follow'] ??
            responseData['moreFollow'] ??
            responseData['moreFollowTags'];
        if (raw is List) {
          moreFollowList = raw;
        }
      }

      // Filter out posts that are already present inside homePosts 3-grid card
      if (homePosts.isNotEmpty) {
        final homePostIds = homePosts
            .where((e) => e is Map && e['id'] != null)
            .map((e) => e['id'].toString())
            .toSet();
        if (homePostIds.isNotEmpty) {
          data.removeWhere((e) => e is Map && e['id'] != null && homePostIds.contains(e['id'].toString()));
        }
      }

      getAllPostList.addAll(data);
      log("Print all post ${data}");
      final seenIds = <int>{};
      getAllPostList.retainWhere((e) {
        if (e is! Map) return true;
        final typeStr = e['type']?.toString().toLowerCase() ?? '';
        final subTypeStr = e['subType']?.toString().toLowerCase() ?? '';
        final postTypeStr = e['post_type']?.toString().toLowerCase() ?? '';
        if (typeStr == 'morefollow' ||
            subTypeStr == 'morefollow' ||
            postTypeStr == 'morefollow' ||
            e['morefollow'] != null ||
            e['moreFollowTags'] != null) {
          return true;
        }
        if (typeStr == 'homepostgrid' ||
            subTypeStr == 'homepostgrid' ||
            postTypeStr == 'homepostgrid' ||
            e['homepost'] != null ||
            e['id'] == -999) {
          return false;
        }
        final id = e['id'];
        if (id == null) return true;
        if (id is! int) return true;
        if (id == 234000 || id == -998) return true;
        return seenIds.add(id);
      });

      // Ensure a morefollow recommendation card exists in the initial feed
      bool hasMoreFollow = getAllPostList.any((e) =>
          e is Map &&
          (e['type']?.toString().toLowerCase() == 'morefollow' ||
              e['subType']?.toString().toLowerCase() == 'morefollow' ||
              e['post_type']?.toString().toLowerCase() == 'morefollow' ||
              e['morefollow'] != null ||
              e['moreFollowTags'] != null));

      if (!hasMoreFollow && isGetAllPost == false && postIds == "0" && getAllPostList.isNotEmpty) {
        final tagsToInsert = moreFollowList.isNotEmpty
            ? moreFollowList
            : [
                {
                  "id": 1,
                  "morefollowId": 1,
                  "morefollowName": "డిఎస్సి",
                  "morefollowNameTranslations": {"te": "డిఎస్సి"},
                  "imageUrl": "https://chotanews-wordpress-files-mig.s3.ap-south-1.amazonaws.com/uploads/2026/09/dsc_tag.jpg",
                  "isActive": true,
                  "isFollowed": false
                },
                {
                  "id": 2,
                  "morefollowId": 2,
                  "morefollowName": "నేపాల్ వరదలు",
                  "morefollowNameTranslations": {"te": "నేపాల్ వరదలు"},
                  "imageUrl": "https://chotanews-wordpress-files-mig.s3.ap-south-1.amazonaws.com/uploads/2026/09/nepal_floods.jpg",
                  "isActive": true,
                  "isFollowed": false
                },
                {
                  "id": 3,
                  "morefollowId": 3,
                  "morefollowName": "క్రికెట్",
                  "morefollowNameTranslations": {"te": "క్రికెట్"},
                  "imageUrl": "",
                  "isActive": true,
                  "isFollowed": false
                },
                {
                  "id": 4,
                  "morefollowId": 4,
                  "morefollowName": "ట్రెండింగ్",
                  "morefollowNameTranslations": {"te": "ట్రెండింగ్"},
                  "imageUrl": "",
                  "isActive": true,
                  "isFollowed": false
                }
              ];

        final insertIdx = getAllPostList.length >= 3 ? 3 : getAllPostList.length;
        getAllPostList.insert(insertIdx, {
          'id': -998,
          'type': 'morefollow',
          'post_type': 'morefollow',
          'subType': 'morefollow',
          'isAd': false,
          'morefollow': tagsToInsert,
        });
      }

      // Prepend homePosts grid at position 0 (shown first in the feed)
      if (homePosts.isNotEmpty && isGetAllPost == false && postIds == "0") {
        getAllPostList.removeWhere((e) =>
            e is Map &&
            (e['id'] == -999 ||
                e['type'] == 'HomePostGrid' ||
                e['subType'] == 'HomePostGrid' ||
                e['post_type'] == 'HomePostGrid'));
        getAllPostList.insert(0, {
          'id': -999,
          'type': 'HomePostGrid',
          'post_type': 'HomePostGrid',
          'subType': 'HomePostGrid',
          'homepost': homePosts,
        });
      }

      TranslationService().preloadAllArticles(getAllPostList);
      notifyListeners();
    } on DioException catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } finally {
      isReload = false;
      isHomeLoading = false;
      notifyListeners();
    }
  }

  bool isAiTagsLoading = false;
  int currentIndex = 0;

  Future<void> getAllPostsByAiId(dynamic postId) async {
    isBookMark = [];
    getAllPostList = [];
    isHomeLoading = true;
    notifyListeners();
    currentIndex = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    Map<String, dynamic> body = {
      "deviceid": deviceId ?? "",
      "aitagid": postId,
      "user_id": userId ?? "",
      "isAdManager": "false",
      "isBigTv": "true",
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllAiTagsById(body);
      log(response.data.toString());
      List data = response.data;
      getAllPostList.addAll(data);
      TranslationService().preloadAllArticles(getAllPostList);
    } on DioException catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } finally {
      isHomeLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllAiTags() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String langCode = preferences.getString("selectedLanguageCode") ?? "te";
    getAllAiTagsList = [];

    if (!showTopNavTags) {
      log("Top nav tags disabled by app config (livetvvideos: $liveTvVideosEnable, aitag: $aiTagEnable)");
      notifyListeners();
      return;
    }

    try {
      Response response;
      if (liveTvVideosEnable) {
        response = await HomeRepo().getAllAiTags({});
      } else if (aiTagEnable) {
        response = await HomeRepo().getAiTags();
      } else {
        notifyListeners();
        return;
      }
      
      var responseData = response.data;
      if (responseData is String) {
        try { responseData = jsonDecode(responseData); } catch (_) {}
      }
      List data = responseData is List ? responseData : (responseData['data'] ?? []);
      
      getAllAiTagsList = data.map((e) {
        Map<String, dynamic> item = Map<String, dynamic>.from(e is Map ? e : {});
        item['aitagid'] = item['id'] ?? item['aitagid'];
        item['slug'] = item['slug'] ?? item['name'] ?? item['aitagname'] ?? item['id'];
        item['aitagname'] = item['name'] ?? item['aitagname'] ?? item['slug'];
        item['thumbnailUrl'] = item['thumbnailUrl'] ?? item['thumbnail_url'] ?? item['thumbnail'];
        if (item['aitagnameTranslations'] != null && item['aitagnameTranslations'][langCode] != null) {
          item['aitagname'] = item['aitagnameTranslations'][langCode];
        }
        return item;
      }).toList();
      
      log("Tags loaded (liveTvVideos: $liveTvVideosEnable, aiTag: $aiTagEnable): ${getAllAiTagsList.length} items");
    } on DioException catch (e, st) {
      log("Get Tags Api catch error $e", stackTrace: st);
    } catch (e, st) {
      log("Get Tags Api catch error $e", stackTrace: st);
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchVideosByTagSlug(String slug, {String? displayTitle, String? thumbnailUrl}) async {
    currentTagSlug = slug;
    currentTagTitle = displayTitle ?? slug;
    currentTagThumbnailUrl = thumbnailUrl;
    isTagVideosLoading = true;
    tagVideosList = [];

    // Pause any playing YouTube video controller to free SurfaceView buffers
    try {
      if (isPlaying) {
        controller.pause();
        isPlaying = false;
      }
    } catch (_) {}

    notifyListeners();

    try {
      final encodedSlug = Uri.encodeComponent(slug);
      Response response = await HomeRepo().getTagVideos(encodedSlug);
      var responseData = response.data;
      if (responseData is String) {
        try { responseData = jsonDecode(responseData); } catch (_) {}
      }
      List data = responseData is List ? responseData : (responseData['data'] ?? []);
      tagVideosList = data;
      log("Fetched ${tagVideosList.length} videos for tag slug: $slug");
    } on DioException catch (e, st) {
      log("Get Tag Videos Api catch error $e", stackTrace: st);
    } catch (e, st) {
      log("Get Tag Videos Api catch error $e", stackTrace: st);
    } finally {
      isTagVideosLoading = false;
      notifyListeners();
    }
  }

  Future<int?> incrementTagVideoView(String slug, String videoId) async {
    try {
      final encodedSlug = Uri.encodeComponent(slug);
      Response response = await HomeRepo().updateTagVideoView(encodedSlug, videoId);
      log("Update Tag Video View response [${response.statusCode}]: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        if (data != null && data is Map) {
          final resData = data['data'];
          if (resData != null && resData is Map && resData.containsKey('views')) {
            final viewsRaw = resData['views'];
            if (viewsRaw is int) return viewsRaw;
            if (viewsRaw is String) return int.tryParse(viewsRaw);
          }
        }
      }
    } catch (e, st) {
      log("Update Tag Video View catch error $e", stackTrace: st);
    }
    return null;
  }

  Future<void> getSurveyData() async {
    getAllSurveyDataList = [];
    try {
      Response response = await HomeRepo().surveyApi();
      getAllSurveyDataList.addAll(response.data['choices']);
      log(getAllSurveyDataList.toString());
    } on DioException catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } finally {
      notifyListeners();
    }
  }

  List isBookMark = [];

  void flipEvent(String pageName, dynamic id, dynamic val) async {
    AnalyticsService().trackArticlesRead();
    notifyListeners();
  }

  bool isBottomEnable = true;

  void pageChange({bool isValue = true}) {
    isBottomEnable = isValue;
    notifyListeners();
  }

  bool isAiTagDataLoaded = false;

  void aiTagDataLoaded(bool value) {
    isAiTagDataLoaded = value;
    if (value) {
      isBottomEnable = true;
    }
    notifyListeners();
  }

  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  void setCurrentPageIndex(int index) {
    if (_currentPageIndex != index) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  bool isHomePostGrid(dynamic article) {
    if (article is! Map) return false;
    return article['type'] == 'HomePostGrid' ||
        article['subType'] == 'HomePostGrid' ||
        article['post_type'] == 'HomePostGrid' ||
        article['homepost'] != null;
  }

  bool get isCurrentArticleGrid {
    if (selectedIndex != 0) return false;
    if (isAiTagDataLoaded) return false;
    if (getAllPostList.isEmpty) return false;
    if (_currentPageIndex >= 0 && _currentPageIndex < getAllPostList.length) {
      return isHomePostGrid(getAllPostList[_currentPageIndex]);
    }
    return false;
  }

  bool _isSubscribed = false;
  bool isComeFromLinkOrNotification = false;
  String? postId = "0";

  void subscribeToPushCallbacks() {
    if (_isSubscribed) return;
    _isSubscribed = true;
    log("pushActionStream: checking pending payloads");

    if (pendingPushPayload != null || pendingDeepLink != null) {
      Future.delayed(Duration.zero, () {
        handleNotificationTap(pendingPushPayload, deepLink: pendingDeepLink);
        pendingPushPayload = null;
        pendingDeepLink = null;
      });
    }
  }

  String? _extractPostIdSafely(Map<String, dynamic>? payload) {
    if (payload == null) return "0";
    
    String? foundId;
    void search(Map m) {
      m.forEach((k, v) {
        if (foundId != null) return;
        if (k == 'postId' || k == 'post_id') {
          foundId = v.toString();
        } else if (v is Map) {
          search(v);
        } else if (v is List) {
          for (var item in v) {
            if (item is Map) search(item);
          }
        }
      });
    }
    
    // Check WebEngage array style customData directly or inside 'data'
    try {
      List? customDataList;
      var customData = payload['customData'] ?? (payload['data'] != null ? payload['data']['customData'] : null);
      if (customData is String) {
        try {
          var decoded = jsonDecode(customData);
          if (decoded is List) {
            customDataList = decoded;
          } else if (decoded is Map) {
             search(decoded); // In case it's a map not list
          }
        } catch (e) {
          log("Error decoding WebEngage customData JSON string: $e");
        }
      } else if (customData is List) {
        customDataList = customData;
      }
      
      if (customDataList != null) {
        for (var item in customDataList) {
          if (item is Map && (item['key'] == 'postId' || item['key'] == 'post_id')) {
            return item['value'].toString();
          }
          // iOS WebEngage might just put the value in the first item without a key
          if (item is Map && item.containsKey('value') && !item.containsKey('key')) {
             return item['value'].toString();
          }
        }
      }
    } catch (e) {
      log("Error checking WebEngage customData: $e");
    }

    search(payload);
    return foundId ?? "0";
  }

  void handleNotificationTap(Map<String, dynamic>? messagePayload, {String? deepLink}) async {
    log("Notification tapped with payload: $messagePayload, deepLink: $deepLink");

    String? linkStr = deepLink;
    if (linkStr == null || linkStr.isEmpty) {
      if (messagePayload != null) {
        linkStr = messagePayload['deepLink'] ??
            messagePayload['deeplink'] ??
            messagePayload['url'] ??
            messagePayload['link'] ??
            messagePayload['click_action'];
      }
    }

    if (linkStr != null && linkStr.isNotEmpty && (linkStr.startsWith('http://') || linkStr.startsWith('https://') || linkStr.contains('://'))) {
      try {
        final uri = Uri.parse(linkStr);
        await routeDeepLink(uri, isFromNotification: true);
        return;
      } catch (e) {
        log("Error parsing deepLink string from notification: $e");
      }
    }

    // Fallback: extract postId from payload
    final String? extractedPostId = _extractPostIdSafely(messagePayload);
    if (extractedPostId != null && extractedPostId != "0") {
      await routeDeepLink(Uri.parse("https://app.bigtv24x7.com/individualPage?postId=$extractedPostId"), isFromNotification: true);
    }
  }

  StreamSubscription<Uri>? linkSubscription;
  PageController homePageController = PageController(initialPage: 0);
  bool isHomeScreen = false;

  Future<void> initDeepLinks() async {
    try {
      final initialUri = await AppLinks().getInitialLink();
      if (initialUri != null) {
        debugPrint('getInitialLink: $initialUri');
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(initialUri);
        });
      }
    } catch (e) {
      log("Error getting initial link: $e");
    }

    linkSubscription?.cancel();
    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      log("Error in deep link handling: $err");
    });
  }

  void _handleDeepLink(Uri uri) async {
    log("Deep link path: $uri");
    await routeDeepLink(uri, isFromNotification: false);
  }

  Future<void> routeDeepLink(Uri uri, {bool isFromNotification = false}) async {
    log("Handling Deep Link: $uri (isNotification: $isFromNotification)");

    // Wait if navigator is not yet mounted
    if (mainNavigatorKey.currentState == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mainNavigatorKey.currentState == null) {
        log("Navigator state is null, cannot route deep link");
        return;
      }
    }

    final path = uri.path.toLowerCase();
    final queryParams = uri.queryParameters;

    void popToRoot() {
      if (mainNavigatorKey.currentState != null) {
        mainNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
    }

    void switchTab(int index) {
      if (homePageController.hasClients) {
        try {
          homePageController.jumpToPage(index);
        } catch (e) {
          log("Error jumping to tab $index: $e");
        }
      }
      onItemTapped(index);
    }

    // 1. EPAPER DEEP LINK
    // Handles:
    // https://www.bigtv24x7.com/epaper?id=epaper_f5276469
    // https://app.bigtv24x7.com/epaper?id=epaper_f5276469
    // https://app.bigtv24x7.com/epaper?epaperId=...
    // https://www.bigtv24x7.com/epaper/epaper_f5276469
    final bool isEpaperLink = path.contains('epaper') ||
        queryParams.containsKey('epaperId') ||
        (queryParams['id'] != null && queryParams['id']!.toLowerCase().startsWith('epaper'));

    if (isEpaperLink) {
      log("Routing to Epaper deep link");
      popToRoot();
      switchTab(3);

      String? epaperId = queryParams['epaperId'] ?? queryParams['id'];
      if ((epaperId == null || epaperId.isEmpty) && uri.pathSegments.contains('epaper')) {
        final idx = uri.pathSegments.indexOf('epaper');
        if (idx + 1 < uri.pathSegments.length) {
          epaperId = uri.pathSegments[idx + 1];
        }
      }

      final context = mainNavigatorKey.currentContext;
      if (context != null) {
        final epaperProvider = context.read<EpaperProvider>();
        if (epaperProvider.allEpapers.isEmpty) {
          await epaperProvider.fetchEpapers();
        }

        if (epaperId != null && epaperId.isNotEmpty) {
          final matched = epaperProvider.allEpapers.firstWhere(
            (e) =>
                e is Map &&
                (e['_id']?.toString() == epaperId ||
                    e['id']?.toString() == epaperId ||
                    e['epaperId']?.toString() == epaperId),
            orElse: () => null,
          );

          if (matched != null && mainNavigatorKey.currentContext != null) {
            Navigator.push(
              mainNavigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) => EpaperDetailScreen(
                  epaper: Map<String, dynamic>.from(matched),
                ),
              ),
            );
          }
        }
      }
      return;
    }

    // 2. VIDEO TAGS / LIVE BIG TV DEEP LINK (e.g. DNA, SB, etc.)
    // Handles:
    // https://app.bigtv24x7.com/livebigtv?showname=DNA&postId=77e02f18-f278-4334-ad74-9bfbd22d0af4&videoId=4b43709723b0b870629678a48e4c2e5c
    // https://app.bigtv24x7.com/livebigtv?showname=SB
    // https://app.bigtv24x7.com/videotags?tag=DNA
    final bool isVideoTagLink = path.contains('livebigtv') ||
        path.contains('videotag') ||
        path.contains('video-tag') ||
        queryParams.containsKey('showname') ||
        queryParams.containsKey('tagSlug');

    if (isVideoTagLink) {
      log("Routing to Video Tag / Live Big TV deep link");
      popToRoot();
      switchTab(0);

      final String tagSlug = queryParams['showname'] ??
          queryParams['tagSlug'] ??
          queryParams['tag'] ??
          queryParams['slug'] ??
          queryParams['show'] ??
          "";

      final String? videoId = queryParams['videoId'] ?? queryParams['video_id'];
      final String? targetPostId = queryParams['postId'] ?? queryParams['post_id'];

      if (tagSlug.isNotEmpty) {
        setSelectedTagId(tagSlug);
        aiTagDataLoaded(true);
        pageChange(isValue: true);

        // Fetch videos for this tag
        await fetchVideosByTagSlug(tagSlug, displayTitle: tagSlug);

        // Scroll top navigation bar to the tag if available
        if (getAllAiTagsList.isNotEmpty) {
          int tagIndex = getAllAiTagsList.indexWhere((t) {
            if (t is! Map) return false;
            final s = (t['slug'] ?? t['name'] ?? t['aitagname'] ?? t['id'])?.toString();
            return s?.toLowerCase() == tagSlug.toLowerCase();
          });
          if (tagIndex != -1) {
            aiTagsScrollToCenter(tagIndex);
          }
        }

        // If specific video or post ID is given, find and play the video
        final String? lookupId = videoId ?? targetPostId;
        if (lookupId != null && lookupId.isNotEmpty && tagVideosList.isNotEmpty) {
          int vIndex = tagVideosList.indexWhere((v) {
            if (v is! Map) return false;
            return v['videoId']?.toString() == lookupId ||
                v['_id']?.toString() == lookupId ||
                v['id']?.toString() == lookupId ||
                v['postId']?.toString() == lookupId ||
                v['video_id']?.toString() == lookupId;
          });

          if (vIndex != -1 && mainNavigatorKey.currentContext != null) {
            Navigator.push(
              mainNavigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) => TagVideoPlayerScreen(
                  videos: tagVideosList,
                  initialIndex: vIndex,
                  tagTitle: currentTagTitle.isNotEmpty ? currentTagTitle : tagSlug,
                  tagThumbnailUrl: currentTagThumbnailUrl,
                ),
              ),
            );
          }
        }
      }
      return;
    }

    // 3. FOLK NIGHT / EVENTS DEEP LINK
    // Handles:
    // https://app.bigtv24x7.com/events?eventId=e4d962de-5393-4541-a792-4c23f1429f9c
    // https://app.bigtv24x7.com/folknight
    // https://app.bigtv24x7.com/folk
    final bool isEventsLink = path.contains('events') ||
        path.contains('folknight') ||
        path.contains('folk') ||
        queryParams.containsKey('eventId');

    if (isEventsLink) {
      log("Routing to Folk Night / Events deep link");
      popToRoot();
      switchTab(0);

      if (mainNavigatorKey.currentContext != null) {
        Navigator.push(
          mainNavigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => const FolkNightEventScreen(),
          ),
        );
      }
      return;
    }

    // 4. EDITORIAL DEEP LINK
    if (path.contains('editorial')) {
      log("Routing to Editorial deep link");
      popToRoot();
      switchTab(2);
      return;
    }

    // 5. REELS DEEP LINK
    if (path.contains('reels') || path.contains('reel') || path.contains('shorts')) {
      log("Routing to Reels deep link");
      popToRoot();
      switchTab(1);
      return;
    }

    // 6. POST / ARTICLE DEEP LINK (Default)
    // Handles:
    // https://app.bigtv24x7.com/individualPage?postId=214
    // https://www.bigtv24x7.com/posts?postId=214
    // https://app.bigtv24x7.com/posts?postId=214
    final String? pId = queryParams['postId'] ??
        queryParams['post_id'] ??
        queryParams['id'] ??
        (uri.pathSegments.isNotEmpty && int.tryParse(uri.pathSegments.last) != null ? uri.pathSegments.last : null);

    if (pId != null && pId.isNotEmpty && pId != "0") {
      log("Routing to Post ID: $pId");
      postId = pId;
      isComeFromLinkOrNotification = true;
      isAiTagDataLoaded = false;
      _selectedTagId = null;
      getAllAiTagsPostList = [];
      isHomeLoading = true;

      popToRoot();
      switchTab(0);
      getAllPostList = [];
      notifyListeners();

      await getIndividualPost(postId, isLink: isFromNotification);
      isHomeLoading = false;
      notifyListeners();
      return;
    }

    log("Deep link not matched to specific handler: $uri");
  }

  Future<void> getMobileNumber() async {
    try {
      String? token = await getAppFcmToken();
      if (token != null && token.isNotEmpty) {
        getUniqueDeviceId(token);
      }
    } catch (e) {
      log('Error getting push token: $e');
    }
  }

  final Map<int, GlobalKey> aiTagKeys = {};
  final ScrollController aiTagScrollController = ScrollController();

  void aiTagsScrollToCenter(int index) {
    final keyContext = aiTagKeys[index]?.currentContext;
    if (keyContext != null) {
      final RenderBox box = keyContext.findRenderObject() as RenderBox;
      final size = box.size;
      final position = box.localToGlobal(Offset.zero);

      final screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

      final itemCenter = position.dx + size.width / 2;
      final targetOffset = aiTagScrollController.offset + itemCenter - screenWidth / 2;

      aiTagScrollController.animateTo(
        targetOffset.clamp(
          0.0,
          aiTagScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> sendAdsDataSend(dynamic postId, dynamic title, dynamic postImage, bool isComeContest, String sourceUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId.toString(),
      "post_id": postId.toString(),
      "post_title": "$title",
      "contest_image_url": postImage.toString(),
    };

    log(body.toString());
    try {
      Response response = await HomeRepo().imageAdsSendData(body);
      if (response.statusCode == 200) {
        log("send data ${response.data}");
        if (await canLaunchUrl(Uri.parse(sourceUrl))) {
          await launchUrl(Uri.parse(sourceUrl));
        } else {
          log('Could not launch $sourceUrl');
        }
        if (mainNavigatorKey.currentContext != null) {
          if (isComeContest) {
            mainNavigatorKey.currentContext!.read<AdsContestProvider>().getContestList(mainNavigatorKey.currentContext);
          }
        }

        CustomToast.showSuccessToast(msg: "Your Successfully Joined The Contest");
        EventRepo().addEvent({
          "user_id": userId,
          "post_id": postId,
          "post_title": "$title",
          "contest_image_url": postImage,
        }, "submit_contest");
      } else {
        log("send data ${response.data}");
        // CustomToast.showErrorToast(msg: "${response.data['detail']}");
      }
    } on DioException catch (e, st) {
      log("ad post imager send data $e  --- $st");
    } catch (e, st) {
      log("ad post imager send data $e  --- $st");
    }
  }

  List getAdsDataList = [];
  bool isAdsDataLoading = false;

  Future<void> updateMoreFollowData(List<int> morefollowIds) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? deviceId = preferences.getString("deviceId");

    try {
      Response response = await BaseService().makeRequest(
        baseUrl: BaseUrls.baseUrlAwsDev,
        url: BaseUrls.updateMoreFollow,
        method: RequestType.post,
        body: {
          "device_id": deviceId ?? "",
          "user_id": userId ?? "",
          "morefollowIds": morefollowIds
        },
      );
      if (response.statusCode == 200) {
        log("updateMoreFollowData success: ${response.data}");
      }
    } on DioException catch (e, st) {
      log("updateMoreFollowData DioException: $e", stackTrace: st);
    } catch (e, st) {
      log("updateMoreFollowData error: $e", stackTrace: st);
    }
  }


  Future<void> getAdsSaveData() async {
    isAdsDataLoading = true;
    getAdsDataList = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    try {
      Response response = await BaseService().makeRequest(
        baseUrl: BaseUrls.baseUrlAwsDev,
        queryParameters: {"user_id": userId},
        url: BaseUrls.test,
        method: RequestType.get,
      );

      if (response.statusCode == 200) {
        getAdsDataList.addAll(response.data);
        log("LogsData ${getAdsDataList.length}");
        EventRepo().addEvent({"user_id": userId, "isCheck": true}, "check_contest");
      }
    } on DioException catch (e, st) {
      log("getAdsSaveData DioException: $e", stackTrace: st);
    } catch (e, st) {
      log("getAdsSaveData error: $e", stackTrace: st);
    } finally {
      isAdsDataLoading = false;
      notifyListeners();
    }
  }

  bool isAdLoaded = true;

  void isBannerAdLoaded(bool value) {
    isAdLoaded = value;
    if (value == true) {
      notifyListeners();
    }
  }

  bool isPdfSending = false;

  Future<void> createAndSharePdfs(BuildContext context, article) async {
    isPdfSending = true;
    notifyListeners();

    List imageData = article['gallery'] ?? [];
    try {
      final pdf = pw.Document();

      for (var item in imageData) {
        String imageUrl = item['Url'].toString();
        log("Pdf $imageUrl");
        if (imageUrl.isNotEmpty && imageUrl != 'null') {
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            final Uint8List responseData = response.bodyBytes;
            final pdfImage = pw.MemoryImage(responseData);

            pdf.addPage(
              pw.Page(
                build: (pw.Context context) {
                  return pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Image(
                      pdfImage,
                      fit: pw.BoxFit.contain,
                    ),
                  );
                },
              ),
            );
          } else {
            log("Failed to load image: $imageUrl");
          }
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/${article['id']}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      log("PDF saved at: $filePath");

      final String title = article['title']?.toString() ?? article['id'].toString();
      final String id = article['id']?.toString() ?? article['_id']?.toString() ?? '';
      String appLink = Platform.isIOS ? (article['linkURLIos']?.toString() ?? "") : (article['linkURLAndroid']?.toString() ?? "");
      if (appLink.isEmpty) {
        appLink = "https://www.bigtv24x7.com/posts?postId=$id";
      }
      final String shareText = "$title\n$appLink";
      
      try {
        if (Platform.isIOS) {
          final Size size = MediaQuery.of(context).size;
          await Share.shareXFiles([XFile(filePath)], text: shareText, sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
        } else {
          const platform = MethodChannel('com.chotanews/whatsapp');
          await platform.invokeMethod('shareToWhatsApp', {'imagePath': filePath, 'text': shareText});
        }
      } catch (e) {
        final Size size = MediaQuery.of(context).size;
        await Share.shareXFiles([XFile(filePath)], text: shareText, sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
      }
    } catch (e) {
      log("Error generating PDF: $e");
      CustomToast.showErrorToast(msg: "Failed to generate PDF");
    } finally {
      isPdfSending = false;
      notifyListeners();
    }
  }
  Future<void> sendDeviceDetailsApi({required String userId, required String deviceId, required String fcmToken, required String lan}) async {
    try {
      final deviceInfo = await getDeviceInfoData();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      
      String locationName = preferences.getString("locationNames") ?? "";
      String pincode = preferences.getString("pincode") ?? "";

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        bool hasRequestedLocation = preferences.getBool("hasRequestedLocation") ?? false;
        
        if (permission == LocationPermission.denied && !hasRequestedLocation) {
          permission = await Geolocator.requestPermission();
          await preferences.setBool("hasRequestedLocation", true);
        }

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            
            List<String> addressParts = [];
            if (place.street?.isNotEmpty == true) addressParts.add(place.street!);
            if (place.subLocality?.isNotEmpty == true && !addressParts.contains(place.subLocality)) addressParts.add(place.subLocality!);
            if (place.locality?.isNotEmpty == true && !addressParts.contains(place.locality)) addressParts.add(place.locality!);
            if (place.administrativeArea?.isNotEmpty == true && !addressParts.contains(place.administrativeArea)) addressParts.add(place.administrativeArea!);
            if (place.postalCode?.isNotEmpty == true && !addressParts.contains(place.postalCode)) addressParts.add(place.postalCode!);
            if (place.country?.isNotEmpty == true && !addressParts.contains(place.country)) addressParts.add(place.country!);

            String fullAddress = addressParts.join(", ");

            if (fullAddress.isNotEmpty) {
              locationName = fullAddress;
            }
            
            String pin = place.postalCode ?? "";
            if (pin.isNotEmpty) {
              pincode = pin;
            }
          }
        }
      } catch (e) {
        log("Error getting location from geocoding: $e");
      }

      Map<String, dynamic> body = {
        "user_id": int.tryParse(userId) ?? 0,
        "device_type": deviceInfo['device_type'],
        "device_id": deviceId,
        "fcm_token": fcmToken,
        "app_version": deviceInfo['app_version'],
        "os_version": deviceInfo['os_version'],
        "lan": lan,
        "location": locationName,
        "pincode": pincode
      };

      final startTime = DateTime.now();
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String prettyJson = encoder.convert(body);

      debugPrint("\n========================================================");
      debugPrint("🚀 [API REQUEST - deviceDetails]");
      debugPrint("📅 Date & Time : ${startTime.toIso8601String()}");
      debugPrint("🌐 Method      : POST");
      debugPrint("🔗 URL         : ${BaseUrls.newServerBaseUrl}${BaseUrls.deviceDetails}");
      debugPrint("📦 Request Body:\n$prettyJson");
      debugPrint("========================================================");

      final response = await HomeRepo().postDeviceDetails(body);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      debugPrint("\n========================================================");
      debugPrint("📥 [API RESPONSE - deviceDetails]");
      debugPrint("📅 Date & Time : ${endTime.toIso8601String()}");
      debugPrint("⏱️ Duration    : ${duration}ms");
      debugPrint("📊 Status Code : ${response.statusCode}");
      debugPrint("📄 Response Data:\n${response.data is Map || response.data is List ? encoder.convert(response.data) : response.data}");
      debugPrint("========================================================\n");
      log("Device details sent successfully");
    } catch (e) {
      debugPrint("\n========================================================");
      debugPrint("❌ [API ERROR - deviceDetails]");
      debugPrint("📅 Date & Time : ${DateTime.now().toIso8601String()}");
      debugPrint("⚠️ Error Details: $e");
      debugPrint("========================================================\n");
      log("Error sending device details: $e");
    }
  }

  /// WordPress Editorial API logic
  List<Map<String, dynamic>> editorialPosts = [];
  bool isEditorialLoading = false;
  bool isEditorialLoadingMore = false;
  int editorialCurrentPage = 1;
  bool hasMoreEditorial = true;

  String _cleanWpTitle(String rawTitle) {
    return rawTitle
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .trim();
  }

  String _extractWpImageUrl(Map<String, dynamic> item) {
    try {
      if (item['_embedded'] != null &&
          item['_embedded']['wp:featuredmedia'] != null &&
          (item['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
        final media = item['_embedded']['wp:featuredmedia'][0];
        if (media['source_url'] != null && media['source_url'].toString().isNotEmpty) {
          return media['source_url'].toString();
        }
      }
      if (item['yoast_head_json'] != null &&
          item['yoast_head_json']['og_image'] != null &&
          (item['yoast_head_json']['og_image'] as List).isNotEmpty) {
        final ogImg = item['yoast_head_json']['og_image'][0]['url'];
        if (ogImg != null && ogImg.toString().isNotEmpty) {
          return ogImg.toString();
        }
      }
      if (item['jetpack_featured_media_url'] != null &&
          item['jetpack_featured_media_url'].toString().isNotEmpty) {
        return item['jetpack_featured_media_url'].toString();
      }
      final String content = item['content']?['rendered']?.toString() ?? '';
      final RegExp regExp = RegExp(r'<img[^>]+src="([^">]+)"');
      final match = regExp.firstMatch(content);
      if (match != null && match.groupCount >= 1) {
        return match.group(1) ?? '';
      }
    } catch (e) {
      log("Error extracting WP image: $e");
    }
    return '';
  }

  String _formatWpDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return rawDate.split('T').first;
    }
  }

  Future<void> fetchEditorialPosts({bool refresh = false}) async {
    if (isEditorialLoading) return;

    if (refresh || editorialPosts.isEmpty) {
      isEditorialLoading = true;
      editorialCurrentPage = 1;
      hasMoreEditorial = true;
      notifyListeners();
    }

    try {
      final url = "https://www.bigtvlive.com/wp-json/wp/v2/posts?per_page=50&page=1&_embed";
      final response = await Dio().get(url);
      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data;
        final List<Map<String, dynamic>> parsed = [];
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            parsed.add({
              'id': item['id'],
              'title': _cleanWpTitle(item['title']?['rendered']?.toString() ?? ''),
              'content': item['content']?['rendered']?.toString() ?? '',
              'excerpt': item['excerpt']?['rendered']?.toString() ?? '',
              'image_url': _extractWpImageUrl(item),
              'publishDate': _formatWpDate(item['date']?.toString() ?? ''),
              'link': item['link']?.toString() ?? '',
              'raw_date': item['date']?.toString() ?? '',
            });
          }
        }
        editorialPosts = parsed;
        if (list.length < 50) {
          hasMoreEditorial = false;
        }
      }
    } catch (e, st) {
      log("Error fetching editorial posts: $e", stackTrace: st);
    } finally {
      isEditorialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreEditorialPosts() async {
    if (isEditorialLoading || isEditorialLoadingMore || !hasMoreEditorial) return;

    isEditorialLoadingMore = true;
    notifyListeners();

    final nextPage = editorialCurrentPage + 1;

    try {
      final url = "https://www.bigtvlive.com/wp-json/wp/v2/posts?per_page=50&page=$nextPage&_embed";
      final response = await Dio().get(url);
      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data;
        if (list.isEmpty) {
          hasMoreEditorial = false;
        } else {
          final List<Map<String, dynamic>> parsed = [];
          for (var item in list) {
            if (item is Map<String, dynamic>) {
              parsed.add({
                'id': item['id'],
                'title': _cleanWpTitle(item['title']?['rendered']?.toString() ?? ''),
                'content': item['content']?['rendered']?.toString() ?? '',
                'excerpt': item['excerpt']?['rendered']?.toString() ?? '',
                'image_url': _extractWpImageUrl(item),
                'publishDate': _formatWpDate(item['date']?.toString() ?? ''),
                'link': item['link']?.toString() ?? '',
                'raw_date': item['date']?.toString() ?? '',
              });
            }
          }
          editorialPosts.addAll(parsed);
          editorialCurrentPage = nextPage;
          if (list.length < 50) {
            hasMoreEditorial = false;
          }
        }
      } else {
        hasMoreEditorial = false;
      }
    } catch (e, st) {
      log("Error loading more editorial posts: $e", stackTrace: st);
      hasMoreEditorial = false;
    } finally {
      isEditorialLoadingMore = false;
      notifyListeners();
    }
  }
}
