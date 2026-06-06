import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import 'package:chotanews/aggricator_screens/contest_screen/contest_provider.dart';
import 'package:chotanews/aggricator_screens/contest_screen/contest_screen.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/features/home/data/repositories/home_repo.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/services/deviice_details.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];
  List getRecommendedPostList = [];
  List getAllAiTagsList = [];
  List getAllAiTagsPostList = [];
  List getAllSurveyDataList = [];
  List getImageAdsList = [];

  String adManageId = "";
  String adManagerNativeId = "";
  String adManagerBannerId = "";
  String adMobNativeId = "";
  String adMobBannerId = "";
  String adMobStickBannerId = "";
  String adManagerStickBannerId = "";

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
  int? _selectedTagId;

  bool isVideoPlaying = false;
  bool isVideosMuted = false;
  late VideoPlayerController videoController;

  int? get selectedTagId => _selectedTagId;

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
    controller = YoutubePlayerController(
      initialVideoId: url,
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

  void setSelectedTagId(int id) {
    _selectedTagId = id;
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
              if (!isLink && !isAds) {
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
          if (!isLink) {
            getAllPost(isGetAllPost: true);
          }
        },
      );
      isPostLoading = false;
      notifyListeners();
    } catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          if (!isLink) {
            getAllPost(isGetAllPost: true);
          }
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
    }
    isBookMark = [];
    getRecommendedPostList = [];
    isWebView = false;
    webUrl = "";
    allPostLastId = "0";
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? deviceId = preferences.getString("deviceId");
    String locationId = preferences.getString("locationId") ?? "";
    List<int> locationIds = locationId.split(',').where((e) =>
    e
        .trim()
        .isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Location IDs: $locationIds ==== ${getAllPostList.length}');

    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<int> categoriesIds = categoriesId.split(',').where((e) =>
    e
        .trim()
        .isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Category IDs: $categoriesIds');

    Map<String, dynamic> body = {"device_id": deviceId, "postId": postIds, "locationIds": locationIds, "categoriesId": categoriesIds, "userId": userId ?? 0, "isAdManager": true, "isBigTv": true};
    log("all post body ${body.toString()}");
    try {
      Response response = await HomeRepo().getAllPosts(body);
      List data = response.data['posts'];

      isWebView = response.data['webView'];
      webUrl = response.data['webUrl'];
      allPostLastId = response.data['lastId'].toString();
      adManageId = Platform.isIOS ? response.data['adUnits']['ios']['admanageid'] : response.data['adUnits']['android']['admanageid'];
      adManagerNativeId = Platform.isIOS ? response.data['adUnits']['ios']['admanagernativeid'] : response.data['adUnits']['android']['admanagernativeid'];
      adManagerBannerId = Platform.isIOS ? response.data['adUnits']['ios']['admanagerbannerid'] : response.data['adUnits']['android']['admanagerbannerid'];
      adMobNativeId = Platform.isIOS ? response.data['adUnits']['ios']['admobnativeid'] : response.data['adUnits']['android']['admobnativeid'];
      adMobBannerId = Platform.isIOS ? response.data['adUnits']['ios']['admobbannerid'] : response.data['adUnits']['android']['admobbannerid'];

      adMobStickBannerId = Platform.isIOS ? response.data['adUnits']['ios']['admobstickyid'] : response.data['adUnits']['android']['admobstickyid'];
      adManagerStickBannerId = Platform.isIOS ? response.data['adUnits']['ios']['admanagerstickyid'] : response.data['adUnits']['android']['admanagerstickyid'];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mainNavigatorKey.currentContext != null) {
          final bannerAdsProvider = Provider.of<AdMobBannerProvider>(mainNavigatorKey.currentContext!, listen: false);
          bannerAdsProvider.loadAd320x50ManagerBanner(0, AdSize.banner);
        }
      });

      getImageAdsList.addAll(response.data['ads_list']);
      getRecommendedPostList.addAll(response.data['ad_homepage_data'] ?? []);
      log("adMobStickBannerId: $adMobStickBannerId --- $adManagerStickBannerId");
      if (isWebView) {
        getAllPostList.insert(0, {
          "id": 000000,
          "postOrder": 00000,
          "author": 9,
          "title": "WebUrl",
          "content": "Hello",
          "created": "2025-04-22T08:36:04",
          "guid": "",
          "post_type": "post",
          "post_name": "WebUrl",
          "post_mime_type": "",
          "totalLikes": 8,
          "totalViews": 14104,
          "totalComments": 0,
          "image_url": "",
          "video_url": "",
          "downloadUrl": null,
          "gallery": null,
          "type": "WebUrl",
          "totalShares": 0,
          "isReporter": 0,
          "reportedBy": "",
          "categoryName": "నేషనల్",
          "postUrl": "",
          "subType": "",
          "isStickyPost": 0,
          "adPosition": null,
          "linkURLAndroid": "https://apps.signitivessoft.com/e6979_aW5kaXZpZHVhbFBhZ2U?eeb65_cG9zdElk=e9f48_Mzk1MjY1OQ",
          "linkURLIos": "https://apps.signitivessoft.com/e6979_aW5kaXZpZHVhbFBhZ2U?eeb65_cG9zdElk=e9f48_Mzk1MjY1OQ",
          "links": [],
          "categoryId": 2,
          "isBookmarked": 0
        });
      }
      getAllPostList.addAll(data);

      final seenIds = <int>{};
      getAllPostList.retainWhere((e) {
        final id = e['id'] as int;
        if (id == 234000) return true;
        return seenIds.add(id);
      });

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
      "isAdManager": "true",
      "isBigTv": "true",
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllAiTagsById(body);
      log(response.data.toString());
      List data = response.data;
      getAllPostList.addAll(data);
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
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    getAllAiTagsList = [];
    Map<String, dynamic> body = {
      "deviceid": deviceId ?? "",
      "userid": userId ?? "",
    };
    try {
      Response response = await HomeRepo().getAllAiTags(body);
      getAllAiTagsList.addAll(response.data);
      log(getAllAiTagsList.toString());
    } on DioException catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } catch (e, st) {
      log("Get News Api catch error $e", stackTrace: st);
    } finally {
      notifyListeners();
    }
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
    notifyListeners();
  }

  final WebEngagePlugin _webEngagePluginInstance = WebEngagePlugin();
  bool _isSubscribed = false;
  bool isComeFromLinkOrNotification = false;
  String? postId = "0";

  void subscribeToPushCallbacks() {
    if (_isSubscribed) return;
    _isSubscribed = true;
    log("pushActionStream: subscribing");

    _webEngagePluginInstance.pushStream.listen((event) {
      _handleNotificationTap(event.payload);
    });

    _webEngagePluginInstance.pushActionStream.listen((event) {
      _handleNotificationTap(event.payload);
    });
  }

  void _handleNotificationTap(Map<String, dynamic>? messagePayload) async {
    log("Notification tapped with payload: $messagePayload");

    if (Platform.isIOS) {
      postId = messagePayload?['data']['customData'][0]['value'] ?? "0";
    } else {
      postId = messagePayload?["postId"] ?? "0";
    }

    if (postId == "0") return;

    isComeFromLinkOrNotification = true;
    isAiTagDataLoaded = false;
    _selectedTagId = null;
    getAllAiTagsPostList = [];
    isHomeLoading = true;

    if (mainNavigatorKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mainNavigatorKey.currentContext == null) return;
    }

    Navigator.of(mainNavigatorKey.currentContext!, rootNavigator: true).popUntil((route) => route.isFirst);
    homePageController.jumpToPage(0);
    getAllPostList = [];
    notifyListeners();

    await getIndividualPost(postId, isLink: true);
  }

  StreamSubscription<Uri>? linkSubscription;
  late PageController homePageController;
  bool isHomeScreen = false;

  Future<void> initDeepLinks() async {
    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      homePageController.jumpToPage(0);

      isHomeLoading = true;
      getAllPostList = [];
      postId = "0";
      setSelectedTagId(0);
      aiTagDataLoaded(false);
      _handleDeepLink(uri);
    }, onError: (err) {
      log("Error in deep link handling: $err");
    });
  }

  void _handleDeepLink(Uri uri) async {
    log("Deep link path: $uri");
    final String? id = uri.queryParameters['postId'];
    if (id != null) {
      postId = id;
      isComeFromLinkOrNotification = true;
      if (mainNavigatorKey.currentState != null) {
        mainNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
      if (mainNavigatorKey.currentContext != null) {
        Navigator.of(mainNavigatorKey.currentContext!, rootNavigator: true).popUntil((route) => route.isFirst);
      }
      getIndividualPost(postId, isLink: false);
      notifyListeners();
    }
  }

  Future<void> getMobileNumber() async {
    final plugin = WebEngagePlugin();
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      log('APNS Token: $apnsToken');
      getUniqueDeviceId(apnsToken ?? "");
    } else if (Platform.isAndroid) {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        getUniqueDeviceId(token);
        log('FCM Token: $token');
        plugin.tokenInvalidatedCallback(_onTokenInvalidated);
        WebEngagePlugin.setPushToken(token);
      }
    }
  }

  void _onTokenInvalidated(Map<String, dynamic>? message) {
    log("tokenInvalidated callback received $message");
    WebEngagePlugin.setSecureToken("siva kumar", message.toString());
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
          } else {
            Navigator.push(
                mainNavigatorKey.currentContext!,
                MaterialPageRoute(
                  builder: (context) => const ContestScreen(),
                ));
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
        CustomToast.showErrorToast(msg: "${response.data['detail']}");
      }
    } on DioException catch (e, st) {
      log("ad post imager send data $e  --- $st");
    } catch (e, st) {
      log("ad post imager send data $e  --- $st");
    }
  }

  List getAdsDataList = [];
  bool isAdsDataLoading = false;

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
}
