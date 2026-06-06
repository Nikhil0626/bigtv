import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../ad_provider/ad_mob_banner_provider.dart';
import '../recommended_news.dart';
import 'ios_ads_view.dart';
import '../../../core/theme/theme_extensions.dart';

class AndroidAdsView extends StatelessWidget {
  final dynamic article;
  final int index;

  const AndroidAdsView({super.key, required this.article, required this.index});

  @override
  Widget build(BuildContext context) {
    final adsList = context.read<AdMobBannerProvider>().ads.values.toList();
    int adIndex = ((index + 1) ~/ 5) - 1;

    log("AndroidAdsView rebuild: adsList length ${adsList.length}, adIndex $adIndex");

    if (adsList.isEmpty || adIndex < 0 || adIndex >= adsList.length || adsList[adIndex] == null) {
      return IosAdsWidgetScreen(article: article);
    }

    final ad = adsList[adIndex];

    if (ad is BannerAd || ad is AdManagerBannerAd) {
      return Container(
        color: context.backgroundColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  height: 250,
                  width: 300,
                  alignment: Alignment.center,
                  child: AdWidget(ad: ad!),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: RecommendedNews(
                rList: article['homepage'] ?? [],
              ),
            ),
          ],
        ),
      );
    } else if (ad is NativeAd) {
      return Container(
        color: context.backgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AdWidget(ad: ad),
      );
    } else {
      return IosAdsWidgetScreen(article: article);
    }
  }
}
