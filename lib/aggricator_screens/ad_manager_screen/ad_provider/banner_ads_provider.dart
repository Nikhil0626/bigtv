
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';


import 'dart:async';



class BannerAdsProvider with ChangeNotifier {
  static final BannerAdsProvider _instance = BannerAdsProvider._internal();
  factory BannerAdsProvider() => _instance;
  BannerAdsProvider._internal();

  final List<BannerAd> _loadedAds = [];
  final int _maxCachedAds = 3;
  bool _isLoading = false;
  int _currentAdIndex = 0;

  BannerAd? get currentAd => _loadedAds.isNotEmpty ? _loadedAds[_currentAdIndex] : null;
  bool get hasAds => _loadedAds.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> loadBannerAd({
    required String adUnitId,
    bool isAdManager = false,
  }) async {
    if (_isLoading || _loadedAds.length >= _maxCachedAds) return;

    _isLoading = true;
    notifyListeners();
    final from = DateTime.now().toString();

    final BannerAd ad = BannerAd(
      adUnitId:  mainNavigatorKey.currentContext!.read<HomeProvider>().adMobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loadedAds.add(ad as BannerAd);
          _isLoading = false;
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
        onAdImpression: (ad) => _logAdImpression(ad as BannerAd, isAdManager),
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
}
