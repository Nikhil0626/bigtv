import 'package:chotanews/features/bookmarks/data/models/bookmark_post_model.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/search_discover_screen.dart';
import 'package:chotanews/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubBookmarksProvider extends BookmarksProvider {
  final List<BookmarkPostModel> _stubBookmarks;
  final int _stubTotal;
  final bool _stubLoggedIn;

  _StubBookmarksProvider({
    List<BookmarkPostModel> bookmarks = const [],
    int totalBookmarks = 0,
    bool isLoggedIn = true,
  })  : _stubBookmarks = bookmarks,
        _stubTotal = totalBookmarks,
        _stubLoggedIn = isLoggedIn;

  @override
  List<BookmarkPostModel> get bookmarks => _stubBookmarks;

  @override
  int get totalBookmarks => _stubTotal;

  @override
  bool get isLoggedIn => _stubLoggedIn;

  @override
  bool get isLoading => false;

  @override
  bool get isMoreLoading => false;

  @override
  Future<void> fetchBookmarks({bool refresh = false}) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'BookmarksScreen hides WhatsApp icon in list items and hides bookmark count in header',
      (tester) async {
    tester.view.physicalSize = const Size(1236, 2745);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final samplePost = BookmarkPostModel(
      id: 101,
      title: 'Bookmarked Sample Article',
      content: 'Sample content',
      imageUrl: '',
      created: '',
      postUrl: 'https://app.bigtv24x7.com/individualPage?postId=101',
      linkUrlAndroid: '',
      linkUrlIos: '',
      type: 'Standard',
      subType: 'Standard',
      categoryName: ['తాజా వార్తలు'],
      isBookmarked: true,
      totalLikes: 0,
      totalViews: 0,
      totalComments: 0,
      totalShares: 0,
      rawJson: {'id': 101, 'title': 'Bookmarked Sample Article'},
    );

    final bookmarksProvider = _StubBookmarksProvider(
      bookmarks: [samplePost],
      totalBookmarks: 7,
      isLoggedIn: true,
    );
    final homeProvider = HomeProvider()..langCode = 'te';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 690),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider<BookmarksProvider>.value(
              value: bookmarksProvider,
            ),
            ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
          ],
          child: const MaterialApp(
            home: BookmarksScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('బుక్‌మార్క్‌లు'), findsOneWidget);
    expect(find.text('7'), findsNothing);
    expect(find.text('Bookmarked Sample Article'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_remove_rounded), findsOneWidget);

    final whatsAppImages = tester.widgetList<Image>(find.byType(Image)).where(
          (img) =>
              img.image is AssetImage &&
              (img.image as AssetImage).assetName ==
                  'assets/images/WhatsApp_icon.png',
        );
    expect(whatsAppImages, isEmpty);
  });

  testWidgets(
      'SearchDiscoverScreen hides bookmark count next to Bookmarks label',
      (tester) async {
    tester.view.physicalSize = const Size(1236, 2745);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeProvider = HomeProvider()..langCode = 'te';
    final notifProvider = NotificationsProvider();
    final bookmarksProvider = _StubBookmarksProvider(
      totalBookmarks: 12,
      isLoggedIn: true,
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 690),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
            ChangeNotifierProvider<NotificationsProvider>.value(
              value: notifProvider,
            ),
            ChangeNotifierProvider<BookmarksProvider>.value(
              value: bookmarksProvider,
            ),
          ],
          child: const MaterialApp(
            home: SearchDiscoverScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('బుక్‌మార్క్స్'), findsOneWidget);
    expect(find.text('బుక్‌మార్క్స్ (12)'), findsNothing);
  });
}

