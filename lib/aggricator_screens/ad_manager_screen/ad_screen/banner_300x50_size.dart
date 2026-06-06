import 'dart:developer';
import 'dart:io';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class Banner300x50Size extends StatefulWidget {
  const Banner300x50Size({super.key});
  @override
  State<Banner300x50Size> createState() => _Banner300x50SizeState();
}

class _Banner300x50SizeState extends State<Banner300x50Size> {
  BannerAd? _adMobBanner;
  AdManagerBannerAd? _adManagerBanner;
  BannerAd? _displayedAd;
  BannerAdsLoading _loadingState = BannerAdsLoading.loading;
  bool _adMobFailed = false;
  bool _adManagerFailed = false;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int count = 0;
  String? mySource;

  @override
  void initState() {
    super.initState();
    count = 0;
    _loadBothAdsInParallel();
  }

  void _loadBothAdsInParallel() {
    _loadAdManagerBanner();
  }

  void _loadAdMobBanner() {
    final fromTime = DateTime.now().toString();
    final adUnitId = mainNavigatorKey.currentContext!.read<HomeProvider>().adMobStickBannerId;

    log('AdMob Banner Ad Unit ID: $adUnitId');

    _adMobBanner = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _handleAdLoaded(ad as BannerAd, "AdMob", fromTime);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          _adMobFailed = true;
          count += 1;

          _handleAdFailed("AdMob", error.message, fromTime);

          if (count < 6) {
            Future.delayed(
              const Duration(seconds: 5),
                  () {
                _loadAdManagerBanner();
              },
            );
          }
        },
        onAdOpened: (Ad ad) {
          _logAdEvent("onAdOpened");
        },
        onAdClosed: (Ad ad) {
          _logAdEvent("onAdClosed");
        },
        onAdImpression: (Ad ad) {
          _logAdEvent("onAdImpression");
        },
        onAdClicked: (Ad ad) {
          _logAdEvent("onAdClicked");
        },
      ),
    )..load();
  }

  void _loadAdManagerBanner() {
    final fromTime = DateTime.now().toString();

    _adManagerBanner?.dispose();

    _adManagerBanner = AdManagerBannerAd(
      adUnitId: mainNavigatorKey.currentContext!.read<HomeProvider>().adManagerStickBannerId,
      sizes: [AdSize.banner],
      request: const AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdClosed: (ad) {
          ad.dispose();
          _logAdEvent("onAdClosed");
        },
        onAdOpened: (ad) => _logAdEvent("onAdOpened"),
        onAdImpression: (ad) {
          _logAdEvent("onAdImpression");
        },
        onAdClicked: (ad) => _logAdEvent("onAdClicked"),
        onAdLoaded: (ad) {
          _handleAdLoaded(ad, "AdManager", fromTime);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _adManagerFailed = true;
          _handleAdFailed("AdManager",
              error.responseInfo?.toString() ?? 'No info', fromTime);
          Future.delayed(
            const Duration(seconds: 5),
                () {
              log("Hello count increase $count");
              _loadAdMobBanner(); // fallback
            },
          );
        },
      ),
    )..load();
  }

  Future<void> _logAdEvent(String eventType) async {
    await analytics.logEvent(
      name: eventType,
      parameters: {
        "event": eventType,
        "platform": Platform.isIOS ? "ios" : "android",
        "timestamp": DateTime.now().toString(),
      },
    );
  }

  void _handleAdLoaded(ad, String source, String fromTime) async {
    if (_displayedAd == null && mounted) {
      final toTime = DateTime.now().toString();
      context.read<HomeProvider>().isBannerAdLoaded(true);

      mySource = source;

      if (source == "AdMob") {
        _displayedAd = ad;
        _adManagerBanner?.dispose();
        _adManagerBanner = null;
        log("Success AdMob");
      } else {
        _adManagerBanner = ad;
        _adMobBanner?.dispose();
        _adMobBanner = null;
        log("Success Ad Manager");
      }
      setState(() {
        _loadingState = BannerAdsLoading.success;
      });
      await analytics.logEvent(
        name: 'ads_success',
        parameters: {
          "sdkRequestStartTime": fromTime,
          "sdkRequestReceivedTime": toTime,
          "adsRenderingTime": DateTime.now()
              .difference(DateTime.parse(toTime))
              .inMicroseconds
              .toString(),
          "createAt": DateTime.now().toString(),
          "adSource": source,
          "adResponse": "",
          "platform": Platform.isIOS ? "ios" : "android",
        },
      );
    } else {
      ad.dispose();
    }
  }

  void _handleAdFailed(String source, String response, String fromTime) async {
    final toTime = DateTime.now().toString();

    await analytics.logEvent(
      name: 'ads_failure',
      parameters: {
        "sdkRequestStartTime": fromTime,
        "sdkRequestReceivedTime": toTime,
        "adsRenderingTime": "0",
        "createAt": DateTime.now().toString(),
        "adSource": source,
        "adResponse": "Success",
        "platform": Platform.isIOS ? "ios" : "android",
      },
    );

    if (_adMobFailed && _adManagerFailed && _displayedAd == null) {
      setState(() {
        _loadingState = BannerAdsLoading.fail;
      });
    }
  }

  @override
  void dispose() {
    _adMobBanner?.dispose();
    _adManagerBanner?.dispose();
    _displayedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("RK Ad Rebuild $mySource ${_loadingState.name}");
    switch (_loadingState) {
      case BannerAdsLoading.loading:
        return const SizedBox.shrink();
      case BannerAdsLoading.success:
        return Center(
            child: SizedBox(
                width: 320,
                height: 50,
                child: _displayedAd != null || _adManagerBanner != null
                    ? Center(
                    child: AdWidget(
                        ad: mySource == "AdMob"
                            ? _displayedAd!
                            : _adManagerBanner!))
                    : const SizedBox.shrink()));
      case BannerAdsLoading.fail:
        return const SizedBox.shrink();
    }
  }
}
