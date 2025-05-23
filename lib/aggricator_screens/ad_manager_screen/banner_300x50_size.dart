import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../utils/app_enums.dart';

class Banner300x50Size extends StatefulWidget {
  const Banner300x50Size({super.key});

  @override
  State<Banner300x50Size> createState() => _Banner300x50SizeState();
}

class _Banner300x50SizeState extends State<Banner300x50Size> {
  bool _isBannerAdLoaded = false;
  SettingsProvider? settingsProvider;

  @override
  void initState() {
  settingsProvider = Provider.of<SettingsProvider>(context,listen: false);
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isBannerAdLoaded) {
      settingsProvider?.loadBannerAd(context);
      _isBannerAdLoaded = true;
    }
  }

  @override
  void dispose() {
    settingsProvider?.bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, settingProvider, __) {
        switch (settingProvider.bannerAdsLoading) {
          case BannerAdsLoading.loading:
            return const Center(child: AppLoadingScreen());
          case BannerAdsLoading.success:
            return SizedBox(
              width: 300,
              height: 50,
              child: AdWidget(ad: settingProvider.bannerAd),
            );
          case BannerAdsLoading.fail:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}


