import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:chotanews/aggricator_screens/contest_screen/contest_screen.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../globel_keys/globel_keys.dart';
import '../../../services/analytics_service.dart';
import '../../../services/deviice_details.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../contest_screen/contest_provider.dart';
import '../../events_data/event_repo.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../home_repo/home_repo.dart';

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

  int? get selectedTagId => _selectedTagId;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void isImageAd() {
    isImageAdClose = true;
    notifyListeners();
  }

  void isTabChange() {
    isSwitched = false;
    notifyListeners();
  }

  void switchChange(value) {
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

  void isPlayingYoutube(value) {
    isPlaying = value;
    notifyListeners();
  }

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  void currentAiPostId(value) {
    aiCurrentPostId = value;
    notifyListeners();
  }

  void youtubeInitial(url) {
    controller = YoutubePlayerController(
      initialVideoId: url, // Example YouTube video ID
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: false,
        forceHD: false,
        disableDragSeek: true,
        isLive: false,
        showLiveFullscreenButton: false,
        // hideControls: true,
      ),
    );
    // notifyListeners();
  }

  void youtubeDispose() {
    log("sbfjhsfnfdsfjsdbnf  ");
    controller.dispose();
    notifyListeners();
  }

  void setSelectedTagId(int id) {
    _selectedTagId = id;
    // final index = getAllAiTagsList.indexWhere((tag) => tag['aitagid'] == id);
    // if (index > 0) {
    //   final selectedTag = getAllAiTagsList.removeAt(index);
    //   getAllAiTagsList.insert(0, selectedTag);
    // }

    notifyListeners();
  }

  Future getIndividualPost(postId, {bool isAds = false, bool isLink = false}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    log("getIndividualPost ${postId}");
    if (isAds != true) {
      getAllPostList = [];
    }
    isPostLoading = true;
    String userId = preferences.getString("userId")??"0";
    Map<String, dynamic> body = {"user_id": userId.toString()};
    try {
      Response response = await HomeRepo().getSinglePost(body,postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        if (isAds == false) {
          getAllPostList.add(response.data['data']);
          Future.delayed(
            Duration(milliseconds: 100),
            () {
              getAllPost(isGetAllPost: true);
              if (isLink) {
                EventRepo().addEvent({
                  "platform": Platform.isIOS ? "iOS" : "Android",
                  "comeFrom": "Notification",
                  "postId": postId.toString() ?? "000",
                  "postTitle": response.data['data']['title'] ?? "",
                  "createAt": DateTime.now().toString()
                }, "opened_via_notification");
              } else {
                EventRepo().addEvent({
                  "platform": Platform.isIOS ? "iOS" : "Android",
                  "comeFrom": "Deeplink",
                  "postId": postId.toString() ?? "000",
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
              "postId": postId.toString() ?? "000",
              "postTitle": getSinglePostList['title'] ?? "",
              "createAt": DateTime.now().toString()
            }, "opened_via_notification");
          } else {
            EventRepo().addEvent({
              "platform": Platform.isIOS ? "iOS" : "Android",
              "comeFrom": "Deeplink",
              "postId": postId.toString() ?? "000",
              "postTitle": getSinglePostList['title'] ?? "",
              "createAt": DateTime.now().toString()
            }, "opened_via_deeplink");
          }
        }
      }
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
      // getAllPostList = [];
      Future.delayed(
        Duration(milliseconds: 300),
        () {
          getAllPost(isGetAllPost: true);
        },
      );
      isPostLoading = false;
      notifyListeners();
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
      // getAllPostList = [];
      Future.delayed(
        Duration(milliseconds: 300),
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
        log("po)stId.toString()   $postId");
        if (!isAiTagDataLoaded && allPostLastId != "0") {
          postId = "0";
          getAllPost(postIds: allPostLastId ?? "0");
        }
      }
    }
  }

  Future getAllPost({String postIds = "0", bool isGetAllPost = false}) async {
    mainNavigatorKey.currentContext?.read<RatingProvider>().ratingsList = [];
    mainNavigatorKey.currentContext?.read<RatingProvider>().ratedArticleIds = {};
    mainNavigatorKey.currentContext?.read<PollProvider>().clearData();
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
    List<int> locationIds = locationId.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Location IDs: $locationIds ==== ${getAllPostList.length}');

    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<int> categoriesIds = categoriesId.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Category IDs: $categoriesIds');

    Map<String, dynamic> body = {"device_id": deviceId, "postId": postIds, "locationIds": locationIds, "categoriesId": categoriesIds, "userId": userId ?? 0, "isAdManager": true};
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
      getImageAdsList.addAll(response.data['ads_list']);
      getRecommendedPostList.addAll(response.data['ad_homepage_data'] ?? []);
      log(" hello hai ${adMobBannerId.toString()} --- $adMobNativeId");
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
          "post_name": "సివిల్స్-తుది-ఫలితాలు-వి",
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
      notifyListeners();
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isReload = false;
      isHomeLoading = false;
      notifyListeners();
    }
  }

  bool isAiTagsLoading = false;
  int currentIndex = 0;

  Future getAllPostsByAiId(postId) async {
    isBookMark = [];
    getAllPostList = [];
    // getAllAiTagsPostList = [];
    // isAiTagsLoading = true;
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
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().getAllAiTagsById(body);
      log(response.data.toString());
      List data = response.data;

      getAllPostList.addAll(data);

      isBookMark = getAllPostList.where((e) => e['isBookmarked'] == 1).map((e) => e['id'].toString()).toList();
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isHomeLoading = false;
      notifyListeners();
    }
  }

  Future getAllAiTags() async {
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
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      // isHomeLoading = false;
      notifyListeners();
    }
  }

  Future getSurveyData() async {
    getAllSurveyDataList = [];
    try {
      Response response = await HomeRepo().surveyApi();
      getAllSurveyDataList.addAll(response.data['choices']);
      log(getAllSurveyDataList.toString());
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      notifyListeners();
    }
  }

  List isBookMark = [];

  void isBookMarkPost(val, context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? deviceId = sp.getString("deviceId");
    log(val['id'].toString());
    if (!isBookMark.contains(val['id'].toString())) {
      isBookMark.add(val['id'].toString());
      Provider.of<SettingsProvider>(context, listen: false).saveBookmarks(val['id'].toString(), context, 1);
      sendLikeDetails(userId, val, true, val['title'].toString());
      log(isBookMark.toString());
    } else {
      Provider.of<SettingsProvider>(context, listen: false).saveBookmarks(val['id'].toString(), context, 0);
      isBookMark.remove(val['id'].toString());

      sendLikeDetails(userId, val['id'].toString(), false, val['title'].toString());
      log(isBookMark.toString());
    }

    notifyListeners();
  }

  void flipEvent(pageName, id, val) async {
    AnalyticsService().trackArticlesRead();
    notifyListeners();
  }

  void addOneMoreArticle() {
    final newArticle = {
      "id": 10101010,
      "postOrder": 10101010,
      "author": 0,
      "title": "Completed",
      "content": "",
      "created": "",
      "guid": "",
      "post_type": "",
      "post_name": "",
      "post_mime_type": "",
      "totalLikes": 0,
      "totalViews": 0,
      "totalComments": 0,
      "image_url": "",
      "video_url": "",
      "downloadUrl": null,
      "gallery": null,
      "type": "Completed",
      "totalShares": 0,
      "isReporter": 0,
      "reportedBy": "",
      "categoryName": "",
      "postUrl": "",
      "subType": "",
      "isStickyPost": null,
      "adPosition": "",
      "linkURLAndroid": "",
      "links": [],
      "isBookmarked": 0
    };

    getAllAiTagsPostList.add(newArticle);
    notifyListeners();
  }

  bool isBottomEnable = true;

  void pageChange({bool isValue = true}) {
    isBottomEnable = isValue;
    notifyListeners();
  }

  bool isAiTagDataLoaded = false;

  void aiTagDataLoaded(value) {
    isAiTagDataLoaded = value;
    notifyListeners();
  }

  final WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
  bool _isSubscribed = false;
  bool isComeFromLinkOrNotification = false;
  String? postId = "0";

  void subscribeToPushCallbacks() {
    if (_isSubscribed) return;
    _isSubscribed = true;
    log("pushActionStream: flutter test 0000");

    _webEngagePlugin.pushStream.listen((event) {
      // Map<String, dynamic> messagePayload = event.payload!;
      // log("pushActionStream: flutter test  11111 --- ${messagePayload["postId"]}");
      // if (Platform.isIOS) {
      //   log("pushActionStream: flutter test  11111 ${messagePayload['data']['customData'][0]['value']}");
      //   postId = messagePayload['data']['customData'][0]['value'] ?? "0";
      //   isComeFromLinkOrNotification = true;
      //   getIndividualPost(postId);
      //    EventRepo().addEvent({
      //    "platform":"iOS",
      //    "comeFrom":"Notification",
      //     "postId": postId.toString()??"000",
      //     "createAt": DateTime.now().toString()
      //   }, "opened_via_notification");
      //   notifyListeners();
      // } else {
      //   postId = messagePayload["postId"] ?? "0";
      //   isComeFromLinkOrNotification = true;
      //   getIndividualPost(postId);
      //   EventRepo().addEvent({
      //     "platform":"Android",
      //     "comeFrom":"Notification",
      //     "postId": postId.toString()??"000",
      //     "createAt": DateTime.now().toString()
      //   }, "opened_via_notification");
      //   notifyListeners();
      // }
      _handleNotificationTap(event.payload);
    });

    _webEngagePlugin.pushActionStream.listen((event) {
      // Map<String, dynamic>? messagePayload = event.payload;
      //
      // log("pushActionStream: flutter test  22222  ${messagePayload}");
      //
      // if (Platform.isIOS) {
      //   log("pushActionStream: flutter test  11111 ${messagePayload?['data']['customData'][0]['value']}");
      //   postId = messagePayload?['data']['customData'][0]['value'] ?? "0";
      //   isComeFromLinkOrNotification = true;
      //   getIndividualPost(postId);
      //   notifyListeners();
      // } else {
      //   postId = messagePayload?["postId"] ?? "0";
      //   isComeFromLinkOrNotification = true;
      //   getIndividualPost(postId);
      //   notifyListeners();
      // }
      _handleNotificationTap(event.payload);
    });
  }

  void _handleNotificationTap(Map<String, dynamic>? messagePayload) async {
    log("Notification tapped with payload: $messagePayload");

    // Extract post ID from notification payload
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

    // Navigate to home screen first if needed
    Navigator.of(mainNavigatorKey.currentContext!, rootNavigator: true).popUntil((route) => route.isFirst);
    homePageController.jumpToPage(0);
    // Reset post list and load the specific post
    getAllPostList = [];
    // postId ="0";
    notifyListeners();

    // Wait for home screen to be ready
    // await Future.delayed(const Duration(milliseconds: 100));
    //
    // // Load and display the post
    await getIndividualPost(postId, isLink: true);

    // Additional delay to ensure UI is ready
    // await Future.delayed(const Duration(milliseconds: 300));

    // Show the post detail view
    // _showPostDetailView();
  }

  StreamSubscription<Uri>? linkSubscription;
  late PageController homePageController;
  bool isHomeScreen = false;

  Future<void> initDeepLinks(BuildContext context) async {
    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      homePageController.jumpToPage(0);

      isHomeLoading = true;
      getAllPostList = [];
      postId = "0";
      // if (isHomeScreen == false) {
      //   Navigator.pop(mainNavigatorKey.currentContext!);
      // }
      setSelectedTagId(0);
      aiTagDataLoaded(false);
      _handleDeepLink(uri, context);
    }, onError: (err) {
      log("Error in deep link handling: $err");
    });
  }

  void _handleDeepLink(Uri uri, context) async {
    log("Deep link path: $uri");
    final String? id = uri.queryParameters['postId'];
    if (id != null) {
      postId = id;
      isComeFromLinkOrNotification = true;
      mainNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      //
      Navigator.of(mainNavigatorKey.currentContext!, rootNavigator: true).popUntil((route) => route.isFirst);
      getIndividualPost(postId, isLink: false);

      notifyListeners();
    }
  }

  getMobileNumber() async {
    WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      log('APNS Token: $apnsToken');
      getUniqueDeviceId(apnsToken ?? "");
    } else if (Platform.isAndroid) {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        getUniqueDeviceId(token);
        log('FCM Token: $token');
        _webEngagePlugin.tokenInvalidatedCallback(_onTokenInvalidated);
        WebEngagePlugin.setPushToken(token);
      }
    }
  }

  void _onTokenInvalidated(Map<String, dynamic>? message) {
    print("tokenInvalidated callback received $message");
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

  void sendAdsDataSend(postId, title, postImage, isComeContest, sourceUrl) async {
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
        if (isComeContest) {
          mainNavigatorKey.currentContext!.read<AdsContestProvider>().getContestList(mainNavigatorKey.currentContext);
        } else {
          Navigator.push(
              mainNavigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) => ContestScreen(),
              ));
        }
        if (await canLaunchUrl(Uri.parse(sourceUrl))) {
          await launchUrl(Uri.parse(sourceUrl));
        } else {
          throw 'Could not launch $sourceUrl';
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

  Future sendDataToads(body) async {
    try {
      Response response = await BaseService().makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.test, method: RequestType.post, body: body);
      log("RK RES ${response.data}");
    } on DioException catch (e, st) {
      log("sfjsyfgheyuifaeiyufha $e ksjfkuefh $st");
    } catch (e, st) {
      log("sfjsyfgheyuifaeiyufha $e ksjfkuefh $st");
    }
  }

  List getAdsDataList = [];
  bool isAdsDataLoading = false;

  Future getAdsSaveData() async {
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
      log("sfjsyfgheyuifaeiyufha $e ksjfkuefh $st");
    } catch (e, st) {
      log("sfjsyfgheyuifaeiyufha $e ksjfkuefh $st");
    } finally {
      isAdsDataLoading = false;
      notifyListeners();
    }
  }

  bool isAdLoaded = true;

  void isBannerAdLoaded(value) {
    isAdLoaded = value;
    if (value == true) {
      notifyListeners();
    }
  }
}
