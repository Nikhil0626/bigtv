import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManagerScreen extends StatefulWidget {
  const AdManagerScreen({super.key});

  @override
  _AdManagerScreenState createState() => _AdManagerScreenState();
}

class _AdManagerScreenState extends State<AdManagerScreen> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  @override
  void initState() {
    super.initState();
    loadBannerAd();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // You can safely access context or ancestors here if needed.
  }

  @override
  void dispose() {
    // Ensure the banner ad is disposed only if it is loaded
    if (_isAdLoaded) {
      _bannerAd.dispose();
    }
    super.dispose();
  }
  void loadBannerAd() {
    // final AdSize customAdSize = AdSize(width: 300, height: 250);
    _bannerAd = BannerAd(
      // adUnitId: '/21775744923/example/fixed-size-banner', // Dummy test Ad Unit ID (valid test ID from Google)
      // adUnitId: '/23299651439/chota_flutter', // Dummy test Ad Unit ID (valid test ID from Google)
      adUnitId: '/23032783179/PM_chotanews_N_IOS', // Dummy test Ad Unit ID (valid test ID from Google)
      // adUnitId: '/23299179262/chota_flutter', // Dummy test Ad Unit ID (valid test ID from Google)
      size: AdSize.fluid,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Banner ad loaded.  ${ad.responseInfo}');
          print('Banner ad loaded.  ${ad.responseInfo}');
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load banner ad: $error');
        },
      ),
    );
    _bannerAd.load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Example'),
      ),
      body: Center(
        child: _isAdLoaded?AdWidget(ad: _bannerAd):Container(height: 300,width: 250,color: Colors.greenAccent,) // Only display the ad when it is loaded

      ),
    );
  }
}


