import 'dart:developer';

import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/features/reels/data/models/reels_model.dart';
import 'package:chotanews/features/reels/data/repositories/reels_repository.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ReelsProviders extends ChangeNotifier {
  static const String _likedReelsKey = "cached_liked_reels_ids";

  bool reelsLoading = true;
  List<ReelsModel> getAllReelsList = [];
  List<String> isLikeList = [];
  bool isMuted = false;
  String? reelsLanguage;

  ReelsProviders() {
    loadCachedLikedReels();
  }

  Future<void> loadCachedLikedReels() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");
      List<String>? globalLikes = prefs.getStringList(_likedReelsKey);
      List<String>? userLikes;
      if (userId != null && userId.isNotEmpty) {
        userLikes = prefs.getStringList("${_likedReelsKey}_$userId");
      }

      final Set<String> combined = {};
      if (globalLikes != null) combined.addAll(globalLikes);
      if (userLikes != null) combined.addAll(userLikes);

      isLikeList = combined.toList();
      log("Loaded ${isLikeList.length} cached liked reels: $isLikeList");
      notifyListeners();
    } catch (e) {
      log("Error loading cached liked reels: $e");
    }
  }

  bool isReelLiked(String reelId) {
    return isLikeList.contains(reelId);
  }

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  Future getAllReels({String postId = "0"}) async {
    reelsLoading = true;
    notifyListeners();
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String langCode = preferences.getString("selectedLanguageCode") ?? "te";
      final currentLang = (langCode == 'ml') ? 'ml' : 'te';
      reelsLanguage = currentLang;

      final Map<String, dynamic> queryParams = {
        'lang': currentLang,
        'segregated': 'false',
      };
      if (currentLang != 'ml') {
        queryParams['language'] = currentLang;
        queryParams['lan'] = currentLang;
      }

      Response response = await ReelsRepo().getAllReels(queryParams);

      if (response.statusCode == 200 && response.data != null) {
        dynamic responseData = response.data;
        List rawList = [];

        if (responseData is Map && responseData['data'] is List) {
          rawList = responseData['data'] as List;
        } else if (responseData is Map && responseData['data'] is Map) {
          final mapData = responseData['data'] as Map;
          final langList = mapData[currentLang] ?? mapData[langCode];
          if (langList is List) {
            rawList = langList;
          }
        } else if (responseData is List) {
          rawList = responseData;
        }

        log("Fetched ${rawList.length} reels from pravasamedia API for lang: $currentLang");
        getAllReelsList = rawList
            .map((e) => ReelsModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } on DioException catch (e, st) {
      log("dio error --- ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("catch error --- ${e.toString()} ---- ${st.toString()}");
    } finally {
      reelsLoading = false;
      notifyListeners();
    }
  }

  void isLikePost(val) async {
    final String reelId = val is ReelsModel
        ? val.id.toString()
        : (val is Map ? (val['id']?.toString() ?? '') : val.toString());
    if (reelId.isEmpty) return;

    final String content = val is ReelsModel
        ? val.content
        : (val is Map ? (val['description'] ?? val['title'] ?? val['content'] ?? '').toString() : '');

    final bool isCurrentlyLiked = isLikeList.contains(reelId);
    final bool newLikeState = !isCurrentlyLiked;

    if (newLikeState) {
      if (!isLikeList.contains(reelId)) {
        isLikeList.add(reelId);
      }
    } else {
      isLikeList.remove(reelId);
    }

    notifyListeners();

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? userId = sp.getString("userId");

      await sp.setStringList(_likedReelsKey, isLikeList);
      if (userId != null && userId.isNotEmpty) {
        await sp.setStringList("${_likedReelsKey}_$userId", isLikeList);
      }
      log("Persisted ${isLikeList.length} liked reels to preferences");

      postLike(reelId, newLikeState);
      sendLikeDetails(userId, reelId, newLikeState, content);
      log("Synced like state $newLikeState for reel $reelId");
    } catch (e) {
      log("Error syncing like details: $e");
    }
  }

  Future<void> postLike(String postId, isLike) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "deviceId": deviceId ?? "",
      "postId": postId,
      "userId": userId ?? "",
      "isLiked": isLike
    };
    try {
      log("body $body");
      Response response = await SettingsRepo().liked(body);
      if (response.statusCode == 200) {}
    } catch (e) {
      log("Error: $e");
    }
  }

  void clearLikesOnLogout() {
    isLikeList = [];
    notifyListeners();
  }

  late ReelsModel reelData;

  bool isReelDataLoading = false;

  Future getIndividualReelData(String postId) async {
    isReelDataLoading = true;
    try {
      Map<String, dynamic> body = {"id": postId};
      Response response = await ReelsRepo().getSingleReelData(body);
      if (response.statusCode == 200) {
        reelData = ReelsModel.fromJson(response.data['data']);
        notifyListeners();
      }

    } on DioException catch (e, st) {
      log("Dio Exception -- ${e.toString()}/// ${st.toString()}");
    } catch (e, st) {
      log("Catch Exception -- ${e.toString()}/// ${st.toString()}");
    } finally {
      isReelDataLoading = false;
      notifyListeners();
    }
    return reelData;
  }
}
