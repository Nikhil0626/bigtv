// native_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  static const _adUnitId = 'ca-app-pub-3940256099942544/3986624511'; // Test ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        cornerRadius: 10.0,
        mainBackgroundColor: Color(0xFFFFFBED), // Light yellow background
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
    return Container(
      height: 350,
      child: _isAdLoaded
          ? AdWidget(ad: _nativeAd!)
          : PlaceholderAdWidget(), // Show placeholder while loading
    );
  }
}

// Placeholder widget for when ad is loading or fails to load
class PlaceholderAdWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFFFFBED), // Light yellow background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFFFFCC66), // Yellow-orange
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              'Ad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8),
          // Header section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.apps, color: Colors.grey[600]),
              ),
              SizedBox(width: 8),
              // Headline and advertiser
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Headline',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Advertiser',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 4),
                        Container(
                          width: 100,
                          height: 17,
                          color: Colors.amber, // Star rating placeholder
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Body text
          Text(
            'Body that is really really long and can take up to two lines or sometimes even more.',
            style: TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5),
          // Media view
          Center(
            child: Container(
              width: 250,
              height: 150,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Media Content',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          SizedBox(height: 7.5),
          // Footer section
          Row(
            children: [
              Text('Price', style: TextStyle(fontSize: 14)),
              SizedBox(width: 10),
              Text('Store', style: TextStyle(fontSize: 14)),
              Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  'Install',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}