import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../services/analytics_service.dart';
import '../../../services/deviice_details.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../home_repo/home_repo.dart';

class HomeProvider extends ChangeNotifier {
  List getAllPostList = [];
  List getAllAiTagsList = [];
  List getAllAiTagsPostList = [];
  List getAllSurveyDataList = [];

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
  late YoutubePlayerController controller;
  int? _selectedTagId;

  int? get selectedTagId => _selectedTagId;

  void onItemTapped(int index) {
    selectedIndex = index;
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
        autoPlay: false,
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
    notifyListeners();
  }

  Future getIndividualPost(postId, {bool isAds = false}) async {
    log("getIndividualPost ${postId}");
    if (isAds != true) {
      getAllPostList = [];
    }
    isPostLoading = true;
    // notifyListeners();
    try {
      Response response = await HomeRepo().getSinglePost(postId);
      log(response.data.toString());
      if (response.statusCode == 200) {
        if (isAds == false) {
          getAllPostList.add(response.data['data']);
          Future.delayed(
            Duration(milliseconds: 300),
            () {
              getAllPost(isGetAllPost: true);
            },
          );
        } else {
          getSinglePostList = response.data['data'];
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

  void scrollListener() {
    if (pageController!.position.atEdge) {
      bool isEnd = pageController!.position.pixels != 0;
      if (isEnd) {
        log("po)stId.toString()   $postId");
        getAllPost(postIds: getAllPostList.last['id'].toString() ?? "0");
      }
    }
  }

  Future getAllPost({String postIds = "0", bool isGetAllPost = false}) async {
    isHomeLoading = true;
    if (isGetAllPost == false && postIds == "0") {
      getAllPostList = [];
    }
    isBookMark = [];
    isWebView = false;
    webUrl = "";
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
      // postId = response.data['lastId'].toString() ?? "0";

      // log(postId.toString());
      adManageId = Platform.isIOS ? response.data['adUnits']['ios']['admanageid'] : response.data['adUnits']['android']['admanageid'];
      adManagerNativeId = Platform.isIOS ? response.data['adUnits']['ios']['admanagernativeid'] : response.data['adUnits']['android']['admanagernativeid'];
      adManagerBannerId = Platform.isIOS ? response.data['adUnits']['ios']['admanagerbannerid'] : response.data['adUnits']['android']['admanagerbannerid'];
      adMobNativeId = Platform.isIOS ? response.data['adUnits']['ios']['admobnativeid'] : response.data['adUnits']['android']['admobnativeid'];
      adMobBannerId = Platform.isIOS ? response.data['adUnits']['ios']['admobbannerid'] : response.data['adUnits']['android']['admobbannerid'];

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

      log("sfbsvfjhshfejsosevfuyesfuyiesdfkejswihfveuwfyiwe");
      log(getAllPostList.length.toString());

      isBookMark = getAllPostList.where((e) => e['isBookmarked'] == 1).map((e) => e['id'].toString()).toList();
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
    log("sbvjdshgurhgiurehiouerjgjer");
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
    getAllAiTagsList = [];
    try {
      Response response = await HomeRepo().getAllAiTags();
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
      Map<String, dynamic> messagePayload = event.payload!;
      log("pushActionStream: flutter test  11111 --- ${messagePayload["postId"]}");
      if (Platform.isIOS) {
        log("pushActionStream: flutter test  11111 ${messagePayload['data']['customData'][0]['value']}");
        postId = messagePayload['data']['customData'][0]['value'] ?? "0";
        isComeFromLinkOrNotification =true;
        getIndividualPost(postId);
        notifyListeners();
      } else {
        postId = messagePayload["postId"] ?? "0";
        isComeFromLinkOrNotification =true;
        getIndividualPost(postId);
        notifyListeners();
      }
    });

    _webEngagePlugin.pushActionStream.listen((event) {
      Map<String, dynamic>? messagePayload = event.payload;

      log("pushActionStream: flutter test  22222  ${messagePayload}");

      if (Platform.isIOS) {
        log("pushActionStream: flutter test  11111 ${messagePayload?['data']['customData'][0]['value']}");
        postId = messagePayload?['data']['customData'][0]['value'] ?? "0";
        isComeFromLinkOrNotification =true;
       getIndividualPost(postId);
        notifyListeners();
      } else {
        postId = messagePayload?["postId"] ?? "0";
        isComeFromLinkOrNotification =true;
        getIndividualPost(postId);
        notifyListeners();
      }
    });
  }

  StreamSubscription<Uri>? linkSubscription;

  Future<void> initDeepLinks(BuildContext context) async {
    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      _handleDeepLink(uri,context);
    }, onError: (err) {
      log("Error in deep link handling: $err");
    });
  }

  void _handleDeepLink(Uri uri,context) async {
    log("Deep link path: $uri");
    final String? id = uri.queryParameters['postId'];
    if (id != null) {
      postId = id;
      isComeFromLinkOrNotification = true;
      getIndividualPost(postId);
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
}
