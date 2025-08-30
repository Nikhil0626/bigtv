
import 'dart:developer';

import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../home_screen/home_provider/home_provider.dart';
import '../../settings_screen/settings_view/feedback_view.dart';
import '../../../utils/app_colors.dart';


import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ad300x250Widget extends StatefulWidget {
  const Ad300x250Widget({super.key});

  @override
  State<Ad300x250Widget> createState() => _Ad300x250WidgetState();
}

class _Ad300x250WidgetState extends State<Ad300x250Widget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
  DateTime? impressionLogged;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    requestInitiated = DateTime.now();

    _bannerAd = BannerAd(
      size: const AdSize(width: 300, height: 250), // ✅ 300×250 size
      // adUnitId: "ca-app-pub-3940256099942544/2934735716", // ✅ Test Ad Unit
      adUnitId: "ca-app-pub-2405357352181832/9414144917", // ✅ Test Ad Unit
      // adUnitId:  context.read<HomeProvider>().adMobBannerId, // ✅ Test Ad Unit
      // adUnitId:     context.read<HomeProvider>().adManagerBannerId,// ✅ Test Ad Unit
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          responseReceived ??= DateTime.now();
          adCreativeDownloaded ??= DateTime.now();
          adRendered = DateTime.now();

          setState(() => _isAdLoaded = true);
          // _logLatencies();
        },

        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Ad failed to load: $error");
          ad.dispose();
        },
        onAdImpression: (ad) {
          impressionLogged = DateTime.now();
          _logLatencies(ad);
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  void _logLatencies(Ad ad) {
    Clipboard.setData(ClipboardData(text: ad.responseInfo.toString()));
    if (requestInitiated != null) {
      debugPrint("📊 Ad Latency Metrics:");
      if (responseReceived != null) {
        debugPrint("⏱ Request Latency: ${responseReceived!.difference(requestInitiated!).inMilliseconds} ms");
      }
      if (adCreativeDownloaded != null && responseReceived != null) {
        debugPrint("⏱ Load Latency: ${adCreativeDownloaded!.difference(responseReceived!).inMilliseconds} ms");
      }
      if (adRendered != null && adCreativeDownloaded != null) {

        debugPrint("⏱ Render Latency: ${adRendered!.difference(adCreativeDownloaded!).inMilliseconds} ms");
      }
      if (impressionLogged != null) {
        debugPrint("⏱ Total Latency: ${impressionLogged!.difference(requestInitiated!).inMilliseconds} ms");
      }

    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isAdLoaded
          ? SizedBox(
        width: 300,
        height: 250,
        child: AdWidget(ad: _bannerAd!),
      )
          : const CircularProgressIndicator(),
    );
  }
}



class RateYourApp extends StatelessWidget {
  const RateYourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Card(
        color: AppColors.adsBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rate your experience\nwith chota news?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              height(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) =>
                      Icon(
                        Icons.star,
                        color: AppColors.ratingColor,
                        size: 40,
                      ),
                ),
              ),
              height(height: 4.h),
              Text(
                'Awesome, liked it',
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              height(height: 6.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForm()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SurveyCards extends StatefulWidget {
  const SurveyCards({super.key});

  @override
  State<SurveyCards> createState() => _SurveyCardsState();
}

class _SurveyCardsState extends State<SurveyCards> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_,homeProvider,__) {
        return ClipRRect(
          child: Card(
            color: AppColors.adsBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Are liking our app?',
                      textAlign: TextAlign.center,
                      style: newAppFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemCount: homeProvider.getAllSurveyDataList.length,
                        itemBuilder: (context, index) {
                    return Container(height: 30,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(width: 1, color: AppColors.borderColor)),
                        child: Text(
                            'Are liking our app?',
                            textAlign: TextAlign.center,
                            style: newAppFont(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            )));
                  },))
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}


class ShareYourApp extends StatelessWidget {
  const ShareYourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Card(
        color: AppColors.adsBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Are you liking our app?',
                    textAlign: TextAlign.center,
                    style: newAppFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                height(height: 4.h),
                Text(
                  "Share the ChotaNewsApp_\nStay updated,with your \n friends & family!",
                  style: newAppFont(fontSize: 14, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                height(height: 12.h),
                ElevatedButton(
                  onPressed: () {
                    Share.share("Check out this app: https://play.google.com/store/apps/details?id=com.chotanews");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Share App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// class Ad300x250Widget extends StatefulWidget {
//   const Ad300x250Widget({super.key});
//
//   @override
//   State<Ad300x250Widget> createState() => _AdManagerNative300x250State();
// }
//
// class _AdManagerNative300x250State extends State<Ad300x250Widget> {
//   AdManagerBannerAd? _bannerAd;
//   bool _isAdLoaded = false;
//
//   DateTime? requestInitiated;
//   DateTime? responseReceived;
//   DateTime? adCreativeDownloaded;
//   DateTime? adRendered;
//   DateTime? impressionLogged;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }
//
//   void _loadAd() {
//     requestInitiated = DateTime.now();
//
//     _bannerAd = AdManagerBannerAd(
//       adUnitId: "ca-app-pub-2405357352181832/7643871122", // ✅ Your Ad Manager native ad unit ID
//       sizes: [AdSize(width: 300, height: 250)], // Fixed 300×250 size
//       listener: AdManagerBannerAdListener(
//         onAdLoaded: (ad) {
//           responseReceived ??= DateTime.now();
//           adCreativeDownloaded ??= DateTime.now();
//           adRendered = DateTime.now();
//
//           setState(() => _isAdLoaded = true);
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint("❌ Ad failed to load: $error");
//           ad.dispose();
//         },
//         onAdImpression: (ad) {
//           impressionLogged = DateTime.now();
//           _logLatencies(ad);
//         },
//       ),
//       request: const AdManagerAdRequest(),
//     )..load();
//   }
//
//   void _logLatencies(Ad ad) {
//     Clipboard.setData(ClipboardData(text: ad.responseInfo.toString()));
//
//     if (requestInitiated != null) {
//       debugPrint("📊 Ad Latency Metrics:");
//       if (responseReceived != null) {
//         debugPrint("⏱ Request Latency: ${responseReceived!.difference(requestInitiated!).inMilliseconds} ms");
//       }
//       if (adCreativeDownloaded != null && responseReceived != null) {
//         debugPrint("⏱ Load Latency: ${adCreativeDownloaded!.difference(responseReceived!).inMilliseconds} ms");
//       }
//       if (adRendered != null && adCreativeDownloaded != null) {
//         debugPrint("⏱ Render Latency: ${adRendered!.difference(adCreativeDownloaded!).inMilliseconds} ms");
//       }
//       if (impressionLogged != null) {
//         debugPrint("⏱ Total Latency: ${impressionLogged!.difference(requestInitiated!).inMilliseconds} ms");
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: _isAdLoaded
//           ? SizedBox(
//         width: 300,
//         height: 250,
//         child: AdWidget(ad: _bannerAd!),
//       )
//           : const CircularProgressIndicator(),
//     );
//   }
// }
