
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'dart:async';

import '../../../globel_keys/globel_keys.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';


class BannerAdsProvider with ChangeNotifier {
  static final BannerAdsProvider _instance = BannerAdsProvider._internal();
  factory BannerAdsProvider() => _instance;
  BannerAdsProvider._internal();

  final List<BannerAd> _loadedAds = [];
  final int _maxCachedAds = 3;
  bool _isLoading = false;
  int _currentAdIndex = 0;
  BuildContext? _context;
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;
  void setContext(BuildContext context) {
    _context = context;
  }

  BannerAd? get currentAd => _loadedAds.isNotEmpty ? _loadedAds[_currentAdIndex] : null;
  bool get hasAds => _loadedAds.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> loadBannerAd({
    required String adUnitId,
    bool isAdManager = false,
  }) async {
    requestInitiated = DateTime.now();

    if (_isLoading || _loadedAds.length >= _maxCachedAds) return;

    _isLoading = true;
    notifyListeners();
    final from = DateTime.now().toString();

    final BannerAd ad = BannerAd(
      adUnitId:  mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId??"" ,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loadedAds.add(ad as BannerAd);
          _isLoading = false;
          responseReceived = DateTime.now();
          notifyListeners();

          // Pre-load next ads if needed
          if (_loadedAds.length < _maxCachedAds) {
            loadBannerAd(adUnitId: adUnitId, isAdManager: isAdManager);
          }

          _logAdEvent(
            from: from,
            isAdManager: isAdManager,
            response: ad.responseInfo.toString(),
            eventType: "ads_success",
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoading = false;
          notifyListeners();

          _logAdEvent(
            from: from,
            isAdManager: isAdManager,
            response: error.responseInfo?.toString() ?? error.toString(),
            eventType: "ads_failure",
          );
        },
        onAdClosed: (ad) => ad.dispose(),
        onAdImpression: (ad){
          adRendered = DateTime.now();
          impressionLogged = DateTime.now();
          _logAdImpression(ad as BannerAd, isAdManager);
          _logLatencyMetrics(ad);

        },
      ),
    );

    await ad.load();
  }

  void rotateAd() {
    if (_loadedAds.isEmpty) return;

    _currentAdIndex = (_currentAdIndex + 1) % _loadedAds.length;
    notifyListeners();

    // Load more ads if cache is getting low
    if (_loadedAds.length < _maxCachedAds && !_isLoading) {
      // final provider = _context?.read<Banner300x50SizeProvider>();
      // if (provider != null) {
      //   loadBannerAd(adUnitId: provider.adMobBannerId, isAdManager: false);
      // }
    }
  }

  void disposeAllAds() {
    for (final ad in _loadedAds) {
      ad.dispose();
    }
    _loadedAds.clear();
    _currentAdIndex = 0;
    _isLoading = false;
    // notifyListeners();
  }

  void _logAdEvent({
    required String from,
    required bool isAdManager,
    required String response,
    required String eventType,
  }) {
    EventRepo().addEvent({
      "sdkRequestStartTime": from,
      "sdkRequestReceivedTime": DateTime.now().toString(),
      "adsRenderingTime": "0",
      "createAt": DateTime.now().toString(),
      "adSource": isAdManager ? "AdManager" : "AdMob",
      "adResponse": response,
    }, eventType);
  }

  void _logAdImpression(BannerAd ad, bool isAdManager) {
    EventRepo().addEvent({
      "adSource": isAdManager ? "AdManager" : "AdMob",
      "adUnitId": ad.adUnitId,
      "impressionTime": DateTime.now().toString(),
    }, "ad_impression");
  }

  void _logLatencyMetrics(Ad ad) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    if (requestInitiated != null && responseReceived != null && adCreativeDownloaded != null && adRendered != null && impressionLogged != null) {
      final requestLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final loadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      // final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      // final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;
      final sdkReadyLatency = responseReceived!.difference(requestInitiated!).inMilliseconds;
      final creativeDownloadLatency = adCreativeDownloaded!.difference(responseReceived!).inMilliseconds;
      final renderLatency = adRendered!.difference(adCreativeDownloaded!).inMilliseconds;
      final totalLatency = impressionLogged!.difference(requestInitiated!).inMilliseconds;

      mainNavigatorKey.currentContext!
          .read<HomeProvider>()
          .sendDataToads({
        "ad_source": 'BannerAdsProvider',
        "user_id":userId.toString(),
        "sdk_ready_time": sdkReadyLatency.toString(),
        "creative_download": creativeDownloadLatency.toString(),
        "render_time": renderLatency.toString(),
        "total_time": totalLatency.toString(),
        "data": "${ad.responseInfo}",
      });
    }
  }
}
