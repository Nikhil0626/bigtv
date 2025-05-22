
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdSwiperScreen extends StatelessWidget {
  const AdSwiperScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ads = List.generate(5, (index) => const NativeAdCard());

    return Scaffold(
      appBar: AppBar(title: const Text("Ads Only Swiper")),
      body: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return ads[index];
        },
        itemCount: ads.length,
        scrollDirection: Axis.vertical,
        loop: true,
        autoplay: false,
      ),
    );
  }
}




class NativeAdCard extends StatefulWidget {
  const NativeAdCard({Key? key}) : super(key: key);

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _nativeAd = NativeAd(
      adUnitId: '/21775744923/example/native',
      factoryId: 'adFactoryExample', // This must match your custom native factory ID
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('NativeAd failed to load: $error');
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
      height: 300,
      margin: const EdgeInsets.all(12),
      child: AdWidget(ad: _nativeAd!),
    )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
