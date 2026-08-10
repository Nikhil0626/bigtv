import 'package:flutter/material.dart';

class BannerAdsProvider with ChangeNotifier {
  static final BannerAdsProvider _instance = BannerAdsProvider._internal();
  factory BannerAdsProvider() => _instance;
  BannerAdsProvider._internal();

  dynamic get currentAd => null;
  bool get hasAds => false;
  bool get isLoading => false;

  Future<void> loadBannerAd({
    required String adUnitId,
    bool isAdManager = false,
  }) async {}

  void rotateAd() {}
  void disposeAllAds() {}
}
