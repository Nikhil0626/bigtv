import 'dart:developer';

import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loading_screen/Banner300x50Size_loading.dart';
import '../../utils/app_enums.dart';
import '../event_repo.dart';
import '../home_screen/home_provider/home_provider.dart';

class Banner300x50Size extends StatefulWidget {
  const Banner300x50Size({super.key});

  @override
  State<Banner300x50Size> createState() => _Banner300x50SizeState();
}

class _Banner300x50SizeState extends State<Banner300x50Size> {
  BannerAd? _bannerAd;
  BannerAdsLoading _loadingState = BannerAdsLoading.loading;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    final AdSize customAdSize = AdSize(width: 320, height: 50);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    String? deviceId = prefs.getString("deviceId");
    String? from = DateTime.now().toString();
log("wfnewfefefniin  ${context.read<HomeProvider>().adManagerBannerId}");
    final ad = BannerAd(
      adUnitId: context.read<HomeProvider>().adManagerBannerId,
      size: customAdSize,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          final to = DateTime.now().toString();
          setState(() {
            _bannerAd = ad as BannerAd;
            _loadingState = BannerAdsLoading.success;
          });

          await EventRepo().addEvent({
            'key': 'ads_success',
            'metadata': {
              "sdkRequestStartTime": from,
              "sdkRequestReceivedTime": to,
              "adsRenderingTime": DateTime.now().difference(DateTime.parse(to)).inMicroseconds,
              "createAt": DateTime.now().toString(),
              "adResponse": ad.responseInfo.toString(),
            },
            'userId': userId,
            'deviceId': deviceId,
          });
        },
        onAdFailedToLoad: (ad, error) async {
          final to = DateTime.now().toString();
          await EventRepo().addEvent({
            'key': 'ads_failure',
            'metadata': {
              "sdkRequestStartTime": from,
              "sdkRequestReceivedTime": to,
              "adsRenderingTime": 0,
              "createAt": DateTime.now().toString(),
              "adResponse": error.responseInfo.toString(),
            },
            'userId': userId,
            'deviceId': deviceId,
          });
          ad.dispose();
          setState(() {
            _loadingState = BannerAdsLoading.fail;
          });
        },
      ),
    );

    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadingState) {
      case BannerAdsLoading.loading:
        return const Center(child: Banner300x50sizeLoading());
      case BannerAdsLoading.success:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: _bannerAd != null ? AdWidget(ad: _bannerAd!) : const SizedBox.shrink(),
        );
      case BannerAdsLoading.fail:
        return const SizedBox.shrink();
    }
  }
}




