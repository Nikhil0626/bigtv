import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/main.dart';
import 'package:app_links/app_links.dart';

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
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';



class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];

  List getAllAiTagsList = [];
  List getAllAiTagsPostList = [];
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
  int? _selectedTagId;

  bool isVideoPlaying = false;
  bool isVideosMuted = false;
  late VideoPlayerController videoController;

  int? get selectedTagId => _selectedTagId;

  String langCode = 'te';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    langCode = prefs.getString("selectedLanguageCode") ?? "te";
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


      getAllPostList.addAll(data);
      log("Print all post ${data}");
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
      "isAdManager": "false",
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
    String langCode = preferences.getString("selectedLanguageCode") ?? "te";
    getAllAiTagsList = [];
    Map<String, dynamic> body = {
      "lang": langCode,
    };
    try {
      Response response = await HomeRepo().getAllAiTags(body);
      
      var responseData = response.data;
      if (responseData is String) {
        try { responseData = jsonDecode(responseData); } catch (_) {}
      }
      List data = responseData is List ? responseData : (responseData['data'] ?? []);
      
      getAllAiTagsList = data.map((e) {
        if (e['aitagnameTranslations'] != null && e['aitagnameTranslations'][langCode] != null) {
          e['aitagname'] = e['aitagnameTranslations'][langCode];
        }
        return e;
      }).toList();
      
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

    if (deepLink != null && deepLink.isNotEmpty) {
      try {
        Uri uri = Uri.parse(deepLink);
        final String? id = uri.queryParameters['postId'] ?? uri.queryParameters['post_id'];
        if (id != null) {
          postId = id;
        } else {
          postId = _extractPostIdSafely(messagePayload);
        }
      } catch (e) {
        postId = _extractPostIdSafely(messagePayload);
      }
    } else {
      postId = _extractPostIdSafely(messagePayload);
    }

    if (postId == "0" || postId == null) return;

    isComeFromLinkOrNotification = true;
    isAiTagDataLoaded = false;
    _selectedTagId = null;
    getAllAiTagsPostList = [];
    isHomeLoading = true;

    if (mainNavigatorKey.currentState == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mainNavigatorKey.currentState == null) {
        isHomeLoading = false;
        notifyListeners();
        return;
      }
    }

    mainNavigatorKey.currentState!.popUntil((route) => route.isFirst);
    if (homePageController.hasClients) {
      homePageController.jumpToPage(0);
    }
    getAllPostList = [];
    notifyListeners();

    await getIndividualPost(postId, isLink: true);
    isHomeLoading = false;
    notifyListeners();
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

    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
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
    final String? id = uri.queryParameters['postId'] ?? uri.queryParameters['post_id'];
    if (id != null) {
      postId = id;
      isComeFromLinkOrNotification = true;
      if (mainNavigatorKey.currentState != null) {
        mainNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
      if (homePageController.hasClients) {
        try {
          if (homePageController.positions.length == 1) {
            homePageController.jumpToPage(0);
          }
        } catch (e) {
          log("Error jumping to page: $e");
        }
      }
      await getIndividualPost(postId, isLink: false);
      isHomeLoading = false;
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
      final String appLink = Platform.isIOS ? (article['linkURLIos']?.toString() ?? "") : (article['linkURLAndroid']?.toString() ?? "");
      final String postUrl = article['postUrl']?.toString() ?? "";
      String shareText = "$title\n${postUrl.isNotEmpty ? postUrl + '\n' : ''}$appLink";

      if (postUrl.contains("youtube.com") || postUrl.contains("youtu.be")) {
        shareText = "$title\n$appLink";
      }
      
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

      await HomeRepo().postDeviceDetails(body);
      log("Device details sent successfully");
    } catch (e) {
      log("Error sending device details: $e");
    }
  }
}
