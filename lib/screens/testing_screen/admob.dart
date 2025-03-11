import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Admob extends StatefulWidget {
  @override
  _AdmobState createState() => _AdmobState();
}

class _AdmobState extends State<Admob> {
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
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Dummy test Ad Unit ID (valid test ID from Google)
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Banner ad loaded.');
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
        child: Column(
          children: <Widget>[
            const Expanded(child: Center(child: Text('Your Content Here'))),
            if (_isAdLoaded) // Only display the ad when it is loaded
              Container(
                height: 50,
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }
}
