// // Copyright 2024 Sarbagya Dhaubanjar. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// import 'package:flutter/material.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
//
// const List<String> _videoIds = [
//   'j4lDDQTKN8s',
//   'bmgia-h1qNg',
//   'Cohbiz2lOQI',
//   'CoNgsfBbxJk',
//   'c9gzcPkSdw0',
//   'UEA_uwpvqtI',
//   'j61j9X4xCnA',
// ];
//
// ///
// class VideoListPage extends StatefulWidget {
//   ///
//   const VideoListPage({super.key});
//
//   @override
//   State<VideoListPage> createState() => _VideoListPageState();
// }
//
// class _VideoListPageState extends State<VideoListPage> {
//   late final List<YoutubePlayerController> _controllers;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controllers = List.generate(
//       _videoIds.length,
//           (index) {
//         final controller = YoutubePlayerController.fromVideoId(
//           videoId: _videoIds[index],
//           autoPlay: false,
//           params: const YoutubePlayerParams(showFullscreenButton: true),
//         );
//         controller.setFullScreenListener(
//               (_) async {
//             final videoData = await controller.videoData;
//             final startSeconds = await controller.currentTime;
//
//             if (!mounted) return;
//
//             final currentTime = await FullscreenYoutubePlayer.launch(
//               context,
//               videoId: videoData.videoId,
//               startSeconds: startSeconds,
//             );
//
//             if (currentTime != null) {
//               controller.seekTo(seconds: currentTime);
//             }
//           },
//         );
//
//         return controller;
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video List Demo'),
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(16),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: MediaQuery.sizeOf(context).width > 500 ? 2 : 1,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//           childAspectRatio: 16 / 9,
//         ),
//         itemCount: _controllers.length,
//         itemBuilder: (context, index) {
//           final controller = _controllers[index];
//
//           return YoutubePlayer(
//             key: ObjectKey(controller),
//             aspectRatio: 16 / 9,
//             enableFullScreenOnVerticalDrag: false,
//             controller: controller,
//             keepAlive: true,
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     for (final controller in _controllers) {
//       controller.close();
//     }
//
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await MobileAds.instance.initialize();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Swipe News with Ads',
//       debugShowCheckedModeBanner: false,
//       home: const NewsSwipeScreen(),
//     );
//   }
// }

class BannerAdController {
  late BannerAd _bannerAd;
  bool isAdLoaded = false;

  void init() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAdLoaded = true;
          debugPrint('✅ Banner preloaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('❌ Failed to load banner: $error');
        },
      ),
    )..load();
  }

  BannerAd? get ad => isAdLoaded ? _bannerAd : null;

  void dispose() {
    _bannerAd.dispose();
  }
}

class NewsSwipeScreen extends StatefulWidget {
  const NewsSwipeScreen({super.key});

  @override
  State<NewsSwipeScreen> createState() => _NewsSwipeScreenState();
}

class _NewsSwipeScreenState extends State<NewsSwipeScreen> {
  final BannerAdController adController = BannerAdController();
  final List<String> articles = List.generate(
    10,
        (index) => "News Article ${index + 1}\n\n" +
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 4,
  );

  @override
  void initState() {
    super.initState();
    adController.init(); // Preload ad at start
  }

  @override
  void dispose() {
    adController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: articles.length + 1, // Extra for ad page
      itemBuilder: (context, index) {
        if (index == 4) {
          // Show ad on 5th page
          return Scaffold(
            appBar: AppBar(title: const Text("Sponsored")),
            body: Center(
              child: adController.ad != null
                  ? AdWidget(ad: adController.ad!)
                  : const CircularProgressIndicator(),
            ),
          );
        } else {
          // Show article
          int articleIndex = index > 4 ? index - 1 : index; // Adjust index after ad
          return Scaffold(
            appBar: AppBar(title: Text("Article ${articleIndex + 1}")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  articles[articleIndex],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
