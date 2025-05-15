import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';



class NewsItem {
 final String title;

 NewsItem(this.title);
}

class TestState extends StatelessWidget {
 const TestState({super.key});

 @override
 Widget build(BuildContext context) {
  return MaterialApp(
   home: NewsFeedPage(),
  );
 }
}

class NewsFeedPage extends StatefulWidget {
 @override
 _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
 List<dynamic> feedList = [];
 Map<int, dynamic> loadedAds = {}; // index -> NativeAd or BannerAd

 @override
 void initState() {
  super.initState();
  fetchNewsAndLoadAds();
 }

 Future<void> fetchNewsAndLoadAds() async {
  // Simulated API data
  List<NewsItem> newsList = List.generate(50, (index) => NewsItem("News #${index + 1}"));
  feedList = [];

  for (int i = 0; i < newsList.length; i++) {
   feedList.add(newsList[i]);

   if ((i + 1) % 5 == 0) {
    int adIndex = feedList.length;

    // Insert ad marker
    feedList.add({'adSlot': true, 'index': adIndex});

    // Load native ad
    NativeAd nativeAd = NativeAd(
     adUnitId: '/21775744923/example/native',
     factoryId: 'adFactoryExample',
     request: AdRequest(),
     listener: NativeAdListener(
      onAdLoaded: (ad) {
       setState(() {
        loadedAds[adIndex] = ad;
       });
      },
      onAdFailedToLoad: (ad, error) {
       ad.dispose();
       // Load banner fallback
       BannerAd bannerAd = BannerAd(
        adUnitId: '/21775744923/example/banner',
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(
         onAdLoaded: (ad) {
          setState(() {
           loadedAds[adIndex] = ad;
          });
         },
         onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // Both ads failed; fallback will show news
         },
        ),
       )..load();
      },
     ),
    )..load();
   }
  }

  setState(() {});
 }

 @override
 void dispose() {
  for (var ad in loadedAds.values) {
   ad.dispose();
  }
  super.dispose();
 }

 NewsItem getFallbackNewsForIndex(int index) {
  int backtrack = index - 1;
  while (backtrack >= 0) {
   if (feedList[backtrack] is NewsItem) {
    return feedList[backtrack];
   }
   backtrack--;
  }
  return NewsItem("Fallback News");
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(title: const Text('News + Ads')),
   body: ListView.builder(
    itemCount: feedList.length,
    itemBuilder: (context, index) {
     final item = feedList[index];

     if (item is NewsItem) {
      return NewsItemWidget(news: item);
     }

     if (item is Map && item['adSlot'] == true) {
      final adObject = loadedAds[index];

      if (adObject is NativeAd) {
       return Container(
        height: 330,
        padding: const EdgeInsets.all(8),
        child: AdWidget(ad: adObject),
       );
      } else if (adObject is BannerAd) {
       return Container(
        height: 50,
        padding: const EdgeInsets.all(8),
        child: AdWidget(ad: adObject),
       );
      } else {
       return NewsItemWidget(news: getFallbackNewsForIndex(index));
      }
     }

     return const SizedBox.shrink();
    },
   ),
  );
 }
}

class NewsItemWidget extends StatelessWidget {
 final NewsItem news;

 const NewsItemWidget({super.key, required this.news});

 @override
 Widget build(BuildContext context) {
  return ListTile(
   title: Text(news.title),
   tileColor: Colors.grey[100],
  );
 }
}
