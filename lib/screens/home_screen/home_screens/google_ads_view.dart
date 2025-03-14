import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdsView extends StatefulWidget {
  const GoogleAdsView({super.key});

  @override
  State<GoogleAdsView> createState() => _GoogleAdsViewState();
}

class _GoogleAdsViewState extends State<GoogleAdsView> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-2405357352181832/9820571770', // Your Ad Unit ID
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _nativeAd = null;
            });
          }
          print('Ad failed to load: $error');
        },
      ),
      nativeTemplateStyle:
      NativeTemplateStyle(templateType: TemplateType.small),
    )..load();
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return SizedBox.shrink();
    }

    return AdWidget(ad: _nativeAd!);
  }

  @override
  void dispose() {
    log("hello siva ads close");
    _nativeAd?.dispose(); // Null check before disposing
    super.dispose();
  }
}
