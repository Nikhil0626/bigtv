import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../services/analytics_service.dart';
import '../../services/webengage_event_tracks.dart';
import '../settings_screen/settings_provider/settings_provider.dart';

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

  Future getIndividualPost(postId, {bool isAds = false}) async {
    log("getIndividualPost ${postId}");
    if(isAds !=true) {
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
              getAllPost( isGetAllPost: true);
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
          getAllPost( isGetAllPost: true);
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
          getAllPost( isGetAllPost: true);
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

  Future getAllPost({String postId = "0", bool isGetAllPost = false}) async {
    if (isGetAllPost == false && postId =="0") {
      getAllPostList = [];
    }
    isBookMark = [];
    isWebView = false;
    webUrl = "";
    isHomeLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? deviceId = preferences.getString("deviceId");
    String locationId = preferences.getString("locationId") ?? "";
    List<int> locationIds = locationId.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Location IDs: $locationIds');

    String categoriesId = preferences.getString("categoriesId") ?? "";
    List<int> categoriesIds = categoriesId.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    log('Category IDs: $categoriesIds');

    Map<String, dynamic> body = {
      "device_id": deviceId,
      "postId": postId,
      "locationIds": locationIds,
      "categoriesId": categoriesIds,
      "userId": userId ?? 0,
      "isAdManager":true
    };
    log("allpost body ${body.toString()}");
    try {
      Response response = await HomeRepo().getAllPosts(body);
      List data = response.data['posts'];
      isWebView = response.data['webView'];
      webUrl = response.data['webUrl'];
      adManageId =Platform.isIOS?response.data['adUnits']['ios']['admanageid']: response.data['adUnits']['android']['admanageid'];
      adManagerNativeId =Platform.isIOS?response.data['adUnits']['ios']['admanagernativeid']: response.data['adUnits']['android']['admanagernativeid'];
      adManagerBannerId = Platform.isIOS?response.data['adUnits']['ios']['admanagerbannerid']:response.data['adUnits']['android']['admanagerbannerid'];
      adMobNativeId = Platform.isIOS?response.data['adUnits']['ios']['admobnativeid']:response.data['adUnits']['android']['admobnativeid'];
      adMobBannerId = Platform.isIOS?response.data['adUnits']['ios']['admobbannerid']:response.data['adUnits']['android']['admobbannerid'];

      // if (isWebView) {
      // Create the custom map once
      // Map<String, dynamic> webUrlPost = {
      //   "id": 000000,
      //   "postOrder": 00000,
      //   "author": 9,
      //   "title": "GoogleAds",
      //   "content": "Hello",
      //   "created": "2025-04-22T08:36:04",
      //   "guid": "",
      //   "post_type": "post",
      //   "post_name": "సివిల్స్-తుది-ఫలితాలు-వి",
      //   "post_mime_type": "",
      //   "totalLikes": 8,
      //   "totalViews": 14104,
      //   "totalComments": 0,
      //   "image_url": "",
      //   "video_url": "",
      //   "downloadUrl": null,
      //   "gallery": null,
      //   "type": "GoogleAds",
      //   "totalShares": 0,
      //   "isReporter": 0,
      //   "reportedBy": "",
      //   "categoryName": "నేషనల్",
      //   "postUrl": "",
      //   "subType": "",
      //   "isStickyPost": 0,
      //   "isHomeScreen": [
      //     {
      //       "id": 4067654,
      //       "postOrder": 852068,
      //       "author": 24,
      //       "title": "కొత్త రేషన్‌కార్డులపై మరో అప్డేట్",
      //       "content": "AP: కొత్త రేషన్‌‌కార్డుల దరఖాస్తులపై ప్రభుత్వం కీలక ప్రకటన చేసింది. గత ప్రభుత్వ హయాంలో రేషన్‌ కార్డుల కోసం దరఖాస్తు చేసుకున్న వారు మళ్లీ దరఖాస్తు చేసుకోవాల్సిన అవసరం లేదని ప్రభుత్వ వర్గాలు తెలిపాయి. వైసీపీ హయాంలో వచ్చిన దరఖాస్తుల్లో 3.36 లక్షల దరఖాస్తులు పెండింగ్‌లో ఉన్నాయని, అవి ప్రస్తుతం ప్రభుత్వ పరిశీలనలో ఉన్నట్టు పేర్కొన్నాయి.",
      //       "created": "2025-05-11T06:40:44",
      //       "guid": "https://chotanews.azurewebsites.net/?p=4067654",
      //       "post_type": "post",
      //       "post_name": "కొత్త-రేషన్‌కార్డులపై-మర",
      //       "post_mime_type": "",
      //       "totalLikes": 5,
      //       "totalViews": 1787,
      //       "totalComments": 0,
      //       "image_url": "https://chotanews.azureedge.net/media/2025/03/RATION-CARDS.jpg",
      //       "video_url": null,
      //       "downloadUrl": null,
      //       "gallery": null,
      //       "type": "Standard",
      //       "totalShares": 0,
      //       "isReporter": 0,
      //       "reportedBy": "",
      //       "categoryName": "నేషనల్",
      //       "postUrl": null,
      //       "subType": "",
      //       "isStickyPost": 0,
      //       "adPosition": null,
      //       "linkURLAndroid": "https://app.chotanews.com/individualPage?postId=4067654",
      //       "linkURLIos": "https://app.chotanews.com/individualPage?postId=4067654",
      //       "links": [],
      //       "categoryId": 2,
      //       "isBookmarked": 0
      //     },
      //     {
      //       "id": 4067186,
      //       "postOrder": 851931,
      //       "author": 9,
      //       "title": "‘ఛోటా న్యూస్’ యాప్ న్యూ అప్‌డేట్",
      //       "content": "గ్లోబల్ టు లోకల్ వార్తలను అందరికంటే ముందుగా క్లుప్తంగా 45 పదాల్లో మీకు అందిస్తోంది ‘ఛోటా న్యూస్’యాప్. అందుకే ఇప్పుడు తెలుగువారి కొత్త అలవాటుగా ‘ఛోటా న్యూస్’ యాప్ సరికొత్తగా మారింది. ఈ యాప్‌ న్యూ అప్‌డేట్ కోసం మీరు వెంటనే ఈ లింక్ <link1>క్లిక్</link1> చేయండి.",
      //       "created": "2025-05-11T04:46:23",
      //       "guid": "https://chotanews.azurewebsites.net/?p=4067186",
      //       "post_type": "post",
      //       "post_name": "ఛోటా-న్యూస్-యాప్-న్యూ-అ-15",
      //       "post_mime_type": "",
      //       "totalLikes": 6,
      //       "totalViews": 14192,
      //       "totalComments": 0,
      //       "image_url": "https://chotanews.azureedge.net/media/2025/05/wed-68202b896f8f2.jpeg",
      //       "video_url": "",
      //       "downloadUrl": null,
      //       "gallery": null,
      //       "type": "Standard",
      //       "totalShares": 0,
      //       "isReporter": 0,
      //       "reportedBy": "",
      //       "categoryName": "చోటా స్పెషల్",
      //       "postUrl": "",
      //       "subType": "StandardLink",
      //       "isStickyPost": 1,
      //       "adPosition": null,
      //       "linkURLAndroid": "https://app.chotanews.com/individualPage?postId=4067186",
      //       "linkURLIos": "https://app.chotanews.com/individualPage?postId=4067186",
      //       "links": [
      //         {
      //           "id": "link1",
      //           "value": "https://play.google.com/store/apps/details?id=com.chotanews"
      //         }
      //       ],
      //       "categoryId": 18,
      //       "isBookmarked": 0
      //     },
      //     {
      //       "id": 4067634,
      //       "postOrder": 852065,
      //       "author": 24,
      //       "title": "సూర్యకు గిఫ్ట్‌ ఇచ్చిన 'రెట్రో' డిస్ట్రిబ్యూటర్‌",
      //       "content": "నటుడు సూర్య కథానాయకుడిగా నటించిన తాజా చిత్రం రెట్రో. ఇటీవల విడుదలైన ఈ మూవీ సక్సెస్‌ ఫుల్‌గా రన్‌ అవుతున్న విషయం తెలిసిందే. ఈ మూవీని శక్తి ఫిలిమ్‌ ఫ్యాక్టరీ సంస్థ అధినేత శక్తి వేలన్‌ తమిళనాడులో డిస్ట్రిబ్యూట్ చేశారు. మూవీ లాభాలు తెచ్చిపెట్టడంతో సూర్యకు కానుకగా వజ్రపు ఉంగరాన్ని శక్తి వేలన్‌ అందించారు. ఆ ఉంగరాన్ని సూర్య తిరిగి వేలన్‌కే ఇచ్చేశారు.",
      //       "created": "2025-05-11T06:37:25",
      //       "guid": "https://chotanews.azurewebsites.net/?p=4067634",
      //       "post_type": "post",
      //       "post_name": "సూర్యకు-గిఫ్ట్‌-ఇచ్చిన-ర",
      //       "post_mime_type": "",
      //       "totalLikes": 6,
      //       "totalViews": 1602,
      //       "totalComments": 0,
      //       "image_url": "https://chotanews.azureedge.net/media/2025/05/fdbfbfhbthb.jpg",
      //       "video_url": "",
      //       "downloadUrl": null,
      //       "gallery": null,
      //       "type": "Standard",
      //       "totalShares": 0,
      //       "isReporter": 0,
      //       "reportedBy": "",
      //       "categoryName": "ఎంటర్‌టైన్‌మెంట్",
      //       "postUrl": "",
      //       "subType": "",
      //       "isStickyPost": 0,
      //       "adPosition": null,
      //       "linkURLAndroid": "https://app.chotanews.com/individualPage?postId=4067634",
      //       "linkURLIos": "https://app.chotanews.com/individualPage?postId=4067634",
      //       "links": [],
      //       "categoryId": 10,
      //       "isBookmarked": 0
      //     }
      //   ],
      //   "adPosition": null,
      //   "linkURLAndroid": "https://apps.signitivessoft.com/e6979_aW5kaXZpZHVhbFBhZ2U?eeb65_cG9zdElk=e9f48_Mzk1MjY1OQ",
      //   "linkURLIos": "https://apps.signitivessoft.com/e6979_aW5kaXZpZHVhbFBhZ2U?eeb65_cG9zdElk=e9f48_Mzk1MjY1OQ",
      //   "links": [],
      //   "categoryId": 2,
      //   "isBookmarked": 0
      // };

      // Create a new list and insert the webUrlPost after every 4 items

      // List modifiedList = [];
      // for (int i = 0; i < data.length; i++) {
      //   modifiedList.add(data[i]);
      //   if ((i + 1) % 4 == 0) {
      //     modifiedList.add(Map<String, dynamic>.from(webUrlPost));
      //   }
      // }

      // List finalList = [];
      // for (int i = 0; i < data.length; i++) {
      //   finalList.add(data[i]);
      //
      //   // Insert ad placeholder after every 4 real items (5th position)
      //   if ((i + 1) % 5 == 0) {
      //     int adIndex = finalList.length; // position after insertion
      //     finalList.add({"type": "ad_placeholder", "adIndex": adIndex});
      //     _loadAdForPosition(adIndex);
      //   }
      // }

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

  // Map<int, Widget> adWidgets = {};
  //
  // void _loadAdForPosition(int index) {
  //   NativeAd nativeAd = NativeAd(
  //     adUnitId: '/21775744923/example/native',
  //     factoryId: 'adFactoryExample',
  //     request: AdRequest(),
  //     listener: NativeAdListener(
  //       onAdLoaded: (ad) {
  //         adWidgets[index] = SizedBox(
  //           height: 600,
  //           width: 400,
  //           child: AdWidget(ad: ad as NativeAd),
  //         );
  //         notifyListeners();
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         _loadBannerAdForPosition(index);
  //       },
  //     ),
  //   );
  //   nativeAd.load();
  // }
  //
  // void _loadBannerAdForPosition(int index) {
  //
  //   BannerAd bannerAd = BannerAd(
  //     adUnitId: '/21775744923/example/banner',
  //     size: AdSize.banner,
  //     request: AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         adWidgets[index] = SizedBox(
  //           height: 50,
  //           child: AdWidget(ad: ad as BannerAd),
  //         );
  //         notifyListeners();
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         adWidgets[index] = const SizedBox();
  //         notifyListeners();
  //       },
  //     ),
  //   );
  //   bannerAd.load();
  // }

  bool isAiTagsLoading = false;
  int currentIndex = 0;

  Future getAllPostsByAiId(postId) async {
    log("sbvjdshgurhgiurehiouerjgjer");
    isBookMark = [];
    getAllAiTagsPostList = [];
    isAiTagsLoading = true;
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

      getAllAiTagsPostList.addAll(data);

      isBookMark = getAllAiTagsPostList.where((e) => e['isBookmarked'] == 1).map((e) => e['id'].toString()).toList();
    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    } finally {
      isAiTagsLoading = false;
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
      EventRepo().sendEvent({
        "key": "bookmark_article",
        "data": {"device_id": deviceId ?? "", "userId": userId, "postId": val['id'].toString(), "isBookMark": true, "source_from": "news"}
      });
      isBookMark.add(val['id'].toString());
      Provider.of<SettingsProvider>(context, listen: false).saveBookmarks(val['id'].toString(), context, 1);
      sendLikeDetails(userId, val, true, val['title'].toString());
      log(isBookMark.toString());
    } else {
      Provider.of<SettingsProvider>(context, listen: false).saveBookmarks(val['id'].toString(), context, 0);
      isBookMark.remove(val['id'].toString());
      EventRepo().sendEvent({
        "key": "bookmark_article",
        "data": {"device_id": "$deviceId", "userId": userId, "postId": val['id'].toString(), "isBookMark": false, "source_from": "news"}
      });
      sendLikeDetails(userId, val['id'].toString(), false, val['title'].toString());
      log(isBookMark.toString());
    }

    notifyListeners();
  }

  void flipEvent(pageName, id, val) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    String? deviceId = sp.getString("deviceId");
    print("set change value $val");
    EventRepo().sendEvent({
      "key": "flip_count",
      "data": {
        "device_id": deviceId,
        "userId": userId,
        "isFlip": val,
        "source_name": pageName,
        "postId": id,
      }
    });
    AnalyticsService().trackArticlesRead();
    notifyListeners();
  }
}
