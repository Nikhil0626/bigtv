import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FullScreenNativeAd extends StatefulWidget {
  @override
  _FullScreenNativeAdState createState() => _FullScreenNativeAdState();
}

class _FullScreenNativeAdState extends State<FullScreenNativeAd> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: '/1234567890/test_native_ad_unit',
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),// ✅ GAM test ad unit ID
      // factoryId: 'fullScreen', // ✅ Match with native factory registration
      request: AdManagerAdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Failed to load native ad: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isAdLoaded
          ? Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: AdWidget(ad: _nativeAd!),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
