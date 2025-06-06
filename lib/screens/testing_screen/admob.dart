import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaginatedPageView(),
    );
  }
}

class PaginatedPageView extends StatefulWidget {
  const PaginatedPageView({super.key});

  @override
  _PaginatedPageViewState createState() => _PaginatedPageViewState();
}

class _PaginatedPageViewState extends State<PaginatedPageView> {
  final PageController _pageController = PageController();

  List<String> _items = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Initial data load
    _pageController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Listener to detect when user scrolls near the end
  void _scrollListener() {
    if (_pageController.position.atEdge) {
      bool isEnd = _pageController.position.pixels != 0;
      if (isEnd && !_isLoading && _hasMore) {
        _fetchData();
      }
    }
  }

  // Simulate API call to fetch data with pagination
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate API response for new page data
    List<String> newFetchedItems = List.generate(
      _pageSize,
          (index) => 'Item ${( _currentPage * _pageSize ) + index + 1}',
    );

    // Simulate end of data after 200 items (for example)
    if (_currentPage >= 3) {
      newFetchedItems = [];
    }

    setState(() {
      _isLoading = false;
      if (newFetchedItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage++;
        _items.addAll(newFetchedItems);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated PageView')),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      _items[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),

          // Loading indicator at bottom center
          if (_isLoading)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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