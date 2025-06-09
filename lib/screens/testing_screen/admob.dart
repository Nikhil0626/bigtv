import 'package:flutter/material.dart';


import 'package:flutter/material.dart';

void main() {
  runApp(const InshortsApp());
}

class InshortsApp extends StatelessWidget {
  const InshortsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inshorts Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const InshortsHomePage(),
    );
  }
}

class NewsModel {
  final String title;
  final String imageUrl;
  final String content;
  final String source;

  const NewsModel({
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.source,
  });
}

class InshortsHomePage extends StatelessWidget {
  const InshortsHomePage({super.key});

  final List<NewsModel> newsList = const [
    NewsModel(
      title: "SpaceX Launches New Rocket",
      imageUrl: "https://picsum.photos/id/1011/800/400",
      content: "SpaceX successfully launched its Falcon 9 rocket carrying new Starlink satellites into orbit.",
      source: "Space.com",
    ),
    NewsModel(
      title: "Apple Announces iPhone 16",
      imageUrl: "https://picsum.photos/id/1015/800/400",
      content: "Apple unveiled the iPhone 16 with improved cameras and a new A18 chip.",
      source: "TechCrunch",
    ),
    NewsModel(
      title: "Monsoon Hits Kerala Early",
      imageUrl: "https://picsum.photos/id/1016/800/400",
      content: "The Indian Meteorological Department confirms early arrival of monsoon in Kerala.",
      source: "NDTV",
    ),
    NewsModel(
      title: "AI in Healthcare Advances",
      imageUrl: "https://picsum.photos/id/1020/800/400",
      content: "AI helps doctors diagnose rare conditions in record time using medical imaging.",
      source: "Healthline",
    ),
    NewsModel(
      title: "India Wins T20 Series",
      imageUrl: "https://picsum.photos/id/1024/800/400",
      content: "India defeats Australia 3-2 in the final T20 match with a last-over thriller.",
      source: "ESPN",
    ),
    NewsModel(
      title: "Google Launches Gemini AI",
      imageUrl: "https://picsum.photos/id/1027/800/400",
      content: "Gemini AI, Google’s new assistant, is designed to rival ChatGPT and Copilot.",
      source: "Google Blog",
    ),
    NewsModel(
      title: "Global Oil Prices Surge",
      imageUrl: "https://picsum.photos/id/1033/800/400",
      content: "Oil prices climb amid tensions in the Middle East and supply concerns.",
      source: "Reuters",
    ),
    NewsModel(
      title: "Dinosaur Fossil Found in Argentina",
      imageUrl: "https://picsum.photos/id/1040/800/400",
      content: "A newly found fossil sheds light on a species that lived 80 million years ago.",
      source: "National Geographic",
    ),
    NewsModel(
      title: "NASA Plans Moon Base by 2030",
      imageUrl: "https://picsum.photos/id/1041/800/400",
      content: "NASA reveals roadmap for a sustainable moon base within the next decade.",
      source: "NASA",
    ),
    NewsModel(
      title: "Climate Change Warning from UN",
      imageUrl: "https://picsum.photos/id/1050/800/400",
      content: "The UN issues a critical warning about accelerating climate change effects.",
      source: "UN Report",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return NewsFullPage(news: newsList[index]);
        },
      ),
    );
  }
}

class NewsFullPage extends StatelessWidget {
  final NewsModel news;

  const NewsFullPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const PageScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (news.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.network(
                    news.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.content,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Source: ${news.source}",
                      style:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class Admob extends StatefulWidget {
//   @override
//   _AdmobState createState() => _AdmobState();
// }
//
// class _AdmobState extends State<Admob> {
//   late BannerAd _bannerAd;
//   bool _isAdLoaded = false;
//   @override
//   void initState() {
//     super.initState();
//     loadBannerAd();
//   }
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // You can safely access context or ancestors here if needed.
//   }
//
//   @override
//   void dispose() {
//     // Ensure the banner ad is disposed only if it is loaded
//     if (_isAdLoaded) {
//       _bannerAd.dispose();
//     }
//     super.dispose();
//   }
//   void loadBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: 'ca-app-pub-2405357352181832/9297875326', // Dummy test Ad Unit ID (valid test ID from Google)
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isAdLoaded = true;
//           });
//           print('Banner ad loaded.');
//         },
//         onAdFailedToLoad: (ad, error) {
//           print('Failed to load banner ad: $error');
//         },
//       ),
//     );
//     _bannerAd.load();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AdMob Example'),
//       ),
//       body: Center(
//         child: Column(
//           children: <Widget>[
//             const Expanded(child: Center(child: Text('Your Content Here'))),
//             if (_isAdLoaded) // Only display the ad when it is loaded
//               Container(
//                 height: 50,
//                 child: AdWidget(ad: _bannerAd),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// Consumer<HomeProvider>(builder: (_, homeProvide, __) {
// return InkWell(
// onTap: () {
// log("Refresh");
//
// homeProvide.isReloadData();
// if (widget.isaiTags) {
// homeProvide.getAllPostsByAiId(widget.aiTagId.toString()).then(
// (value) {
// homeProvide.isReloadFalse();
// },
// );
// } else {
// homeProvide.getAllPostList = [];
// homeProvide.getAllPost();
// }
// },
// child: SizedBox(
// width: 24,
// child: SvgPicture.asset("assets/svg/new_refresh.svg",
// height: 20, width: 20, color: widget.article['subType'] == "BigBlackStandard" ? Colors.white : Colors.grey),
// ),
// );
// }),