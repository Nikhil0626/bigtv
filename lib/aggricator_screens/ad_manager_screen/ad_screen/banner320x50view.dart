import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../utils/keep_alive_page.dart';

class Banner320x50view extends StatefulWidget {
  const Banner320x50view({super.key});

  @override
  State<Banner320x50view> createState() => _Banner320x50viewState();
}

class _Banner320x50viewState extends State<Banner320x50view> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdMobBannerProvider>(builder: (_, adMobBannerProvider, __) {
      final adsList = adMobBannerProvider.ads.values.toList();
      return adsList[0] != null?AdWidget(ad: adsList[0]):SizedBox.shrink();
    });
  }
}
