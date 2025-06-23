import 'dart:developer';
import 'dart:io';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_background_view.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_view.dart';
import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_model/bookmarks_model.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/webengage_event_tracks.dart';
import '../../home_screen/home_provider/home_provider.dart';

class SettingsProvider extends ChangeNotifier {
  List<BookmarksModel> getAllBookmarkList = [];
  bool isMainLoading = false;
  bool isOthersSelected = false;
  List feedbackList = [];
  List<String> selectedFeedbackList = [];
  TextEditingController feedbackController = TextEditingController();
  List profileList = [];
  List<String> selectedProfileList = [];
  TextEditingController profileController = TextEditingController();

  bool isBookMarkLoading = false;

  Future getAllBookMarks({String id = "0"}) async {
    isBookMarkLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {"user_id": userId, "last_bookmark_id": id};
    try {
      log("body $body");
      Response response = await SettingsRepo().bookMarks(body);
      log("body ${response.data}");
      if (response.statusCode == 200) {
        List data = response.data['bookMarks'];
        getAllBookmarkList = data
            .map(
              (e) => BookmarksModel.fromJson(e),
            )
            .toList();
        log(response.data.toString());
      }
    } catch (e, st) {
      log("kjsbdcjksjksdhbcfk${e.toString()} -- ${st}");
    } finally {
      isBookMarkLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBookmarks(String postId, context, isBookMark) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? loginType = preferences.getString("loginType");

    if (loginType == "login") {
      Map<String, dynamic> body = {"post_id": postId, "user_id": userId, "bookmark": isBookMark};
      try {
        log("body $body");
        Response response = await SettingsRepo().saveBookMarks(body);
        if (response.statusCode == 200) {
          if (isBookMark == 1) {
            // CustomToast.showSuccessToast(msg: "Bookmark added",);
          } else {
            // CustomToast.showErrorToast(msg: "Bookmark removed", );
          }
        }
      } catch (e) {
        log("Error: $e");
      } finally {
        notifyListeners();
      }
    } else {
      Provider.of<AuthenticationProvider>(context, listen: false).setLogOutStatus(context, false);
    }
  }

  Future<void> postLike(String postId, isLike) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {"deviceId": deviceId, "postId": postId, "userId": userId??0, "isLiked": isLike};
    try {
      log("body $body");
      Response response = await SettingsRepo().liked(body);
      if (response.statusCode == 200) {}
    } catch (e) {
      log("Error: $e");
    } finally {
      notifyListeners();
    }
  }

  List<String> isLikeList = [];

  void isLikePost(val) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final userId = sp.getString("userId")??0;
    log(val['id'].toString());
    if (!isLikeList.contains(val['id'].toString())) {
      isLikeList.add(val['id'].toString());
      postLike(val['id'].toString(), true);
      sendLikeDetails(userId??0, val, true, val['title'].toString());
      log(isLikeList.toString());
    } else {
      postLike(val['id'].toString(), false);
      isLikeList.remove(val['id'].toString());

      sendLikeDetails(userId, val['id'].toString(), false, val['title'].toString());
      log(isLikeList.toString());
    }

    notifyListeners();
  }

  Future getFeedBack() async {
    isFeedbackLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId ?? "0",
      "device_id": deviceId,
    };

    try {
      Response response = await SettingsRepo().getFeedBack(body);
      if (response.statusCode == 200) {
        feedbackList.addAll(response.data['feedback_options']);

        log("Like posted successfully: ${response.data}");
      } else {
        log("Failed to post like: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isFeedbackLoading = false;
      notifyListeners();
    }
  }

  bool isFeedbackLoading = false;

  Future postFeedBack(
    rating,
  ) async {
    isFeedbackLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");

    String? userId = preferences.getString("userId");
    List selectedCategoryIds = feedbackList.where((item) => selectedFeedbackList.contains(item['optionText'].toString())).map((item) => item['optionId'].toString()).toList();

    Map<String, dynamic> body = {"device_id": deviceId, "user_id": userId, "user_rating": rating, "comment_ids": selectedCategoryIds, "custom_comment": feedbackController.text ?? ""};

    log(body.toString());
    try {
      Response response = await SettingsRepo().postFeedBack(body);
      if (response.statusCode == 200) {
        CustomToast.showSuccessToast(msg: response.data['message']);
        selectedFeedbackList = [];
        log("Like posted successfully: ${response.data}");
      } else {
        log("Failed to post like: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: " Feedback not submitted");
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isOthersSelected = false;

      isFeedbackLoading = false;
      notifyListeners();
    }
  }

  void addToSelectedEngagements(String profileName) {
    if (profileName == "Others") {
      isOthersSelected = !isOthersSelected;
    }
    log(profileName);
    if (!selectedFeedbackList.contains(profileName)) {
      selectedFeedbackList.add(profileName);
      log(selectedFeedbackList.toString());
      notifyListeners(); // Notify listeners if using ChangeNotifier
    } else {
      selectedFeedbackList.remove(profileName);
      notifyListeners();
    }
  }


  String? to = '';
  String? from = '';
  String? renderTime = '';
  BannerAdsLoading bannerAdsLoading = BannerAdsLoading.loading;
  late BannerAd bannerAd;

  void loadBannerAd(BuildContext context) async{

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? userId= sharedPreferences.getString("userId");
    String? deviceId= sharedPreferences.getString("deviceId");
    from =  DateTime.now().toString();
    bannerAdsLoading = BannerAdsLoading.loading;

    log(userId.toString());
    log(deviceId.toString());
    final AdSize customAdSize = AdSize(width: 300, height: 50);
    bannerAd = BannerAd(
      // adUnitId: "/22387492205,23277683599/id1631068092.Banner1.1747894331",
      adUnitId: context.read<HomeProvider>().adManagerBannerId,
      size: customAdSize,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async{
          to =  DateTime.now().toString();
          print(ad.responseInfo.toString());
          bannerAdsLoading = BannerAdsLoading.success;
          Map<String, dynamic> newEvent = {
            "sdkRequestStartTime":from,
            "sdkRequestReceivedTime":to,
            "adsRenderingTime":DateTime.now().difference(DateTime.parse(to!)).inMicroseconds.toString(),
            "createAt":DateTime.now().toString(),
            "adResponse":ad.responseInfo.toString(),
          };
          print("All Events: $newEvent");
           EventRepo().addEvent(newEvent,"ads_success");

          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) async{
          to =  DateTime.now().toString();
          if (kDebugMode) {
            print(error.responseInfo.toString());
          }
          bannerAdsLoading = BannerAdsLoading.fail;
          Map<String, dynamic> newEvent = {
            "sdkRequestStartTime":from,
            "sdkRequestReceivedTime":to,
            "adsRenderingTime":"0",
            "createAt":DateTime.now().toString(),
            "adResponse":error.responseInfo.toString(),
          };
          print("All Events: ${newEvent}");
          await EventRepo().addEvent(newEvent,"ads_failure");
          ad.dispose();
          notifyListeners();
        },
      ),
    )..load();
  }

}
