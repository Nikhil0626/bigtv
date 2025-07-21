// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class BannerAdWidget extends StatefulWidget {
//   const BannerAdWidget({super.key});
//
//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState();
// }
//
// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   late BannerAd _bannerAd;
//   bool _isLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _bannerAd = BannerAd(
//       adUnitId: "ca-app-pub-3940256099942544/6300978111", // ✅ Test Ad Unit ID
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (_) {
//           setState(() {
//             _isLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('❌ Failed to load banner ad: $error');
//           ad.dispose();
//         },
//       ),
//     )..load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _isLoaded
//         ? SizedBox(
//       width: _bannerAd.size.width.toDouble(),
//       height: _bannerAd.size.height.toDouble(),
//       child: AdWidget(ad: _bannerAd),
//     )
//         : const SizedBox(height: 50); // Placeholder height
//   }
//
//   @override
//   void dispose() {
//     _bannerAd.dispose();
//     super.dispose();
//   }
// }
//
//
//
//
//
// class BannerListPage extends StatelessWidget {
//   BannerListPage({super.key});
//
//   final List<String> items = List.generate(50, (index) => 'Item ${index + 1}');
//
//   bool _isAdIndex(int index) => (index + 1) % 4 == 0;
//
//   @override
//   Widget build(BuildContext context) {
//     final int adCount = (items.length /4).floor();
//     final int totalListItems = items.length + adCount;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Banner Ad ListView')),
//       body: ListView.builder(
//         itemCount: totalListItems,
//         itemBuilder: (context, index) {
//           if (_isAdIndex(index)) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: 10),
//               child: BannerAdWidget(),
//             );
//           } else {
//             // Calculate actual index in items list
//             final int actualIndex = index - (index ~/ 4);
//             return ListTile(
//               title: Text(items[actualIndex]),
//               leading: const Icon(Icons.label_outline),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BannerAdService {
  static final BannerAdService _instance = BannerAdService._internal();
  factory BannerAdService() => _instance;

  BannerAdService._internal();

  final Map<int, BannerAd> _adInstances = {};
  final Map<int, bool> _adLoaded = {};

  BannerAd? getAdForIndex(int index) {
    return _adInstances[index];
  }

  bool isAdLoaded(int index) => _adLoaded[index] ?? false;

  void loadAdForIndex(int index, VoidCallback onAdLoaded) {
    if (_adInstances.containsKey(index)) return;

    final ad = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _adLoaded[index] = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Failed to load ad at $index: $error");
          ad.dispose();
        },
      ),
    );

    ad.load();
    _adInstances[index] = ad;
  }

  void disposeAll() {
    for (var ad in _adInstances.values) {
      ad.dispose();
    }
    _adInstances.clear();
    _adLoaded.clear();
  }
}


class BannerAdHolder extends StatefulWidget {
  final int index;
  const BannerAdHolder({super.key, required this.index});

  @override
  State<BannerAdHolder> createState() => _BannerAdHolderState();
}

class _BannerAdHolderState extends State<BannerAdHolder>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdProvider>(context, listen: false);
    provider.loadAd(widget.index, () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<AdProvider>(context);
    final ad = provider.getAd(widget.index);
    final loaded = provider.isAdLoaded(widget.index);

    if (ad != null && loaded) {
      return SizedBox(
        width: 320,
        height: 50,
        child: AdWidget(ad: ad),
      );
    }

    return const SizedBox(
      height: 50,
      child: Center(child: CircularProgressIndicator(strokeWidth: 1)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}





class BannerListPage extends StatefulWidget {
  const BannerListPage({super.key});

  @override
  State<BannerListPage> createState() => _BannerListPageState();
}

class _BannerListPageState extends State<BannerListPage> {
  final List<String> _sampleItems = List.generate(50, (i) => 'Item ${i + 1}');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdProvider>(context, listen: false).setItems(_sampleItems);
    });
  }

  @override
  void dispose() {
    Provider.of<AdProvider>(context, listen: false).disposeAds();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ListView with Banner Ads')),
      body: ListView.builder(
        itemCount: adProvider.totalItemCount,
        itemBuilder: (context, index) {
          if (adProvider.isAdIndex(index)) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BannerAdHolder(index: index),
            );
          } else {
            final actualIndex = adProvider.actualItemIndex(index);
            return ListTile(
              title: Text(adProvider.items[actualIndex]),
              leading: const Icon(Icons.article),
            );
          }
        },
      ),
    );
  }
}





class AdProvider extends ChangeNotifier {
  final int adInterval;
  final String adUnitId;
  List<String> _items = [];

  final Map<int, BannerAd> _adCache = {};
  final Map<int, bool> _adLoaded = {};

  AdProvider({
    this.adInterval = 2,
    // this.adUnitId = 'ca-app-pub-3940256099942544/6300978111', // Test ID
    this.adUnitId = 'ca-app-pub-2405357352181832/9297875326', // Test ID
  });

  // Setup your content list
  void setItems(List<String> items) {
    _items = items;
    notifyListeners();
  }

  List<String> get items => _items;

  // Index utilities
  bool isAdIndex(int index) => (index + 1) % adInterval == 0;

  int get adCount => (_items.length / adInterval).floor();

  int get totalItemCount => _items.length + adCount;

  int actualItemIndex(int index) => index - (index ~/ adInterval);

  // Ad loading & caching
  BannerAd? getAd(int index) => _adCache[index];

  bool isAdLoaded(int index) => _adLoaded[index] ?? false;

  void loadAd(int index, VoidCallback onLoaded) {
    if (_adCache.containsKey(index)) return;

    final ad = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _adLoaded[index] = true;
          notifyListeners();
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Ad failed at $index: $error');
          ad.dispose();
        },
      ),
    );

    ad.load();
    _adCache[index] = ad;
  }

  void disposeAds() {
    for (final ad in _adCache.values) {
      ad.dispose();
    }
    _adCache.clear();
    _adLoaded.clear();
  }
}
