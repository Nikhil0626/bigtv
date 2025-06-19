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
SettingsProvider? settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(listen: false,context);
    super.initState();
    _loadBannerAd(context);
  }

  void _loadBannerAd(BuildContext context) async {
    final AdSize customAdSize = AdSize(width: 320, height: 50);

    String? from = DateTime.now().toString();

    settingsProvider?.bannerAd = BannerAd(
      adUnitId: context.read<HomeProvider>().adManagerBannerId,
      size: customAdSize,
      request: const AdManagerAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          final to = DateTime.now().toString();
          setState(() {
            settingsProvider?.bannerAd = ad as BannerAd;
            settingsProvider?.bannerAdsLoading = BannerAdsLoading.success;
          });

          await EventRepo().addEvent({
              "sdkRequestStartTime": from,
              "sdkRequestReceivedTime": to,
              "adsRenderingTime": DateTime.now().difference(DateTime.parse(to)).inMicroseconds.toString(),
              "createAt": DateTime.now().toString(),
              "adResponse": ad.responseInfo.toString(),
            },"ads_success");
        },
        onAdFailedToLoad: (ad, error) async {
          final to = DateTime.now().toString();

          await EventRepo().addEvent({
            "sdkRequestStartTime": from,
            "sdkRequestReceivedTime": to,
            "adsRenderingTime": "0",
            "createAt": DateTime.now().toString(),
            "adResponse": error.responseInfo.toString(),
          },"ads_failure");
          ad.dispose();
          setState(() {
            settingsProvider?.bannerAdsLoading = BannerAdsLoading.fail;
          });
        },
      ),
    );

    settingsProvider?.bannerAd?.load();
  }

  @override
  void dispose() {
    super.dispose();
    settingsProvider?.bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (settingsProvider?.bannerAdsLoading) {
      case BannerAdsLoading.loading:
        return const Center(child: Banner300x50sizeLoading());
      case BannerAdsLoading.success:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: settingsProvider?.bannerAd != null ? AdWidget(ad: settingsProvider!.bannerAd!) : const SizedBox.shrink(),
        );
      case BannerAdsLoading.fail:
        return const SizedBox.shrink();
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}




