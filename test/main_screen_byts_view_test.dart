import 'dart:io';

import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_repo/rating_repo.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews_screen.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/gallery_screen.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/home/data/repositories/home_repo.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/infocus_bar_widget.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_byts_view.dart';
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:chotanews/services/translation_service.dart';
import 'package:chotanews/utils/botton_actions.dart';
import 'package:chotanews/utils/translated_text.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubRatingRepo extends RatingRepo {
  @override
  Future getReviews(dynamic postId, [Map<String, dynamic>? queryParams]) async {
    return dio.Response(
      requestOptions: dio.RequestOptions(path: '/moviereviews/$postId'),
      statusCode: 200,
      data: <String, dynamic>{'reviews': []},
    );
  }
}

class _FakeHomeRepo extends HomeRepo {
  bool shouldThrow = false;
  List<Map<String, dynamic>> nextPosts = const [];
  List<Map<String, dynamic>> nextAiTagPosts = const [];
  int getAllPostsCalls = 0;
  int getAllAiTagsByIdCalls = 0;
  Duration delay = Duration.zero;

  @override
  Future getAllPosts(queryParams) async {
    getAllPostsCalls++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldThrow) {
      throw dio.DioException(
        requestOptions: dio.RequestOptions(path: '/allposts'),
      );
    }
    return dio.Response(
      requestOptions: dio.RequestOptions(path: '/allposts'),
      statusCode: 200,
      data: <String, dynamic>{'posts': nextPosts},
    );
  }

  @override
  Future getMoreFollowTags({Map<String, dynamic>? queryParams}) async {
    return dio.Response(
      requestOptions: dio.RequestOptions(path: '/morefollow'),
      statusCode: 200,
      data: const [],
    );
  }

  @override
  Future getAllAiTagsById(body) async {
    getAllAiTagsByIdCalls++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldThrow) {
      throw dio.DioException(
        requestOptions: dio.RequestOptions(path: '/aitag/content'),
      );
    }
    return dio.Response(
      requestOptions: dio.RequestOptions(path: '/aitag/content'),
      statusCode: 200,
      data: nextAiTagPosts,
    );
  }
}

class _TestHomeProvider extends HomeProvider {
  int getAllPostCalls = 0;
  int getAllPostsByAiIdCalls = 0;
  int pageChangeCalls = 0;
  List<Map<String, dynamic>> stubMovieReviews = [];

  @override
  List<Map<String, dynamic>> getAllMovieReviews() => stubMovieReviews;

  @override
  Future<void> fetchDynamicMovieReviews({bool refresh = false}) async {}

  @override
  Future<void> getAllPost({
    String postIds = "0",
    bool isGetAllPost = false,
  }) async {
    getAllPostCalls++;
    isReloadFalse();
  }

  @override
  Future<void> getAllPostsByAiId(dynamic postId) async {
    getAllPostsByAiIdCalls++;
    isReloadFalse();
  }

  @override
  void pageChange({bool isValue = true}) {
    pageChangeCalls++;
    super.pageChange(isValue: isValue);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late Directory tempDir;
  final List<Map<String, dynamic>> dispatchedShares = [];

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('main_screen_byts_test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      return tempDir.path;
    });
  });

  tearDownAll(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathProviderChannel, null);
    ContentShareDispatcher.debugShareOverride = null;
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  setUp(() {
    dispatchedShares.clear();
    ContentShareDispatcher.debugShareOverride = ({
      required String shareText,
      required String subject,
      required bool isWhatsAppOnly,
      String? imagePath,
    }) async {
      dispatchedShares.add({
        'shareText': shareText,
        'subject': subject,
        'isWhatsAppOnly': isWhatsAppOnly,
        'imagePath': imagePath,
      });
    };
    SharedPreferences.setMockInitialValues({
      'selectedLanguageCode': 'te',
      'userId': '0',
      'deviceId': 'test_device',
    });
  });

  tearDown(() {
    ContentShareDispatcher.debugShareOverride = null;
  });

  void setViewport(
    WidgetTester tester, {
    Size logicalSize = const Size(360, 806),
    double bottomPadding = 24.0,
    double textScale = 1.0,
  }) {
    tester.view.physicalSize = Size(
      logicalSize.width * 2.0,
      logicalSize.height * 2.0,
    );
    tester.view.devicePixelRatio = 2.0;
    tester.view.padding = FakeViewPadding(
      top: 24.0 * 2.0,
      bottom: bottomPadding * 2.0,
    );
    tester.view.viewPadding = FakeViewPadding(
      top: 24.0 * 2.0,
      bottom: bottomPadding * 2.0,
    );
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
      tester.view.resetViewPadding();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
  }

  Widget buildHarness({
    required Widget child,
    required HomeProvider homeProvider,
    ThemeData? theme,
    bool withBottomNavOverlay = false,
  }) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
          ChangeNotifierProvider<BookmarksProvider>(
            create: (_) => BookmarksProvider(),
          ),
          ChangeNotifierProvider<VideoProvider>(
            create: (_) => VideoProvider(),
          ),
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(),
          ),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme,
          home: Scaffold(
            body: withBottomNavOverlay
                ? Consumer<HomeProvider>(
                    builder: (context, provider, _) => Stack(
                      children: [
                        child,
                        if (provider.isBottomEnable)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {},
                              child: Container(
                                color: Colors.red,
                                child: const SafeArea(
                                  top: false,
                                  child: SizedBox(
                                    height: 50,
                                    child: Center(child: Text('Bottom Nav')),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> buildArticle({
    String type = 'Standard',
    String subType = 'Standard',
    String title = 'Tirumala Devotees Insurance Announcement From Government',
    String? content,
    List<String>? bulletPoints,
    List<Map<String, dynamic>>? links,
    String reportedBy = 'Reporter',
    int isReporter = 0,
    bool isWebPost = false,
  }) {
    return <String, dynamic>{
      'id': 101,
      'type': type,
      'subType': subType,
      'title': title,
      'content': content ??
          List.generate(
            24,
            (i) =>
                'Line ${i + 1}: Detailed news report covering key developments and citizen welfare programs across districts.',
          ).join(' '),
      'image_url': '',
      'created': '2026-09-17T10:00:00Z',
      'isStickyPost': 0,
      'isReporter': isReporter,
      'reportedBy': reportedBy,
      'isWebPost': isWebPost,
      'postUrl': 'https://example.com/news/101',
      'linkURLAndroid': 'https://example.com/app/101',
      'linkURLIos': 'https://example.com/app/101',
      if (bulletPoints != null) 'bulletPoints': bulletPoints,
      if (links != null) 'links': links,
    };
  }

  group('MainScreenBytView overflow & button interaction', () {
    testWidgets(
      'very long news truncates without scrolling or overflow and bottom buttons work',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle(isWebPost: true);

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsNothing);

        final reloadFinder = find.byKey(const Key('news_card_reload_button'));
        final whatsappFinder =
            find.byKey(const Key('news_card_whatsapp_button'));
        expect(reloadFinder, findsOneWidget);
        expect(whatsappFinder, findsOneWidget);

        final reloadRect = tester.getRect(reloadFinder);
        final whatsappRect = tester.getRect(whatsappFinder);
        expect(reloadRect.bottom, lessThanOrEqualTo(806.0 - 24.0));
        expect(whatsappRect.bottom, lessThanOrEqualTo(806.0 - 24.0));

        await tester.tap(reloadFinder);
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
        expect(homeProvider.pageChangeCalls, equals(0));

        await tester.tap(whatsappFinder);
        await tester.pump();
        expect(homeProvider.pageChangeCalls, equals(0));
        expect(dispatchedShares, hasLength(1));
        expect(dispatchedShares.first['isWhatsAppOnly'], isTrue);
      },
    );

    testWidgets(
      'buttons stay above bottom navigation bar when isBottomEnable is true and still work when toggled',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = true;
        final article = buildArticle();

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            withBottomNavOverlay: true,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final reloadFinder = find.byKey(const Key('news_card_reload_button'));
        final whatsappFinder =
            find.byKey(const Key('news_card_whatsapp_button'));

        // Bottom nav occupies bottom 50 + 24 = 74 logical pixels (y >= 732).
        final reloadRectOpen = tester.getRect(reloadFinder);
        final whatsappRectOpen = tester.getRect(whatsappFinder);
        expect(reloadRectOpen.bottom, lessThanOrEqualTo(732.0));
        expect(whatsappRectOpen.bottom, lessThanOrEqualTo(732.0));

        // Tapping Reload hits Reload directly even while bottom nav is visible.
        await tester.tap(reloadFinder);
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));

        // Hide bottom nav and verify buttons shift down cleanly and still work.
        homeProvider.pageChange(isValue: false);
        await tester.pump();
        expect(tester.takeException(), isNull);

        final reloadRectClosed = tester.getRect(reloadFinder);
        expect(reloadRectClosed.bottom, greaterThan(reloadRectOpen.bottom));
        expect(reloadRectClosed.bottom, lessThanOrEqualTo(806.0 - 24.0));

        await tester.tap(reloadFinder);
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(2));
      },
    );

    testWidgets(
      '50% BigTvSpecial post on compact dark screen does not overflow and buttons work',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 600),
          bottomPadding: 20.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle(subType: 'BigTvSpecial');

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            theme: AppTheme.darkTheme,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsNothing);

        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'long bullet points article clips cleanly without scrolling or overflow and buttons work',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 760),
          bottomPadding: 16.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle(
          subType: 'Standard',
          content: 'Key highlights from the cabinet briefing today:',
          bulletPoints: List.generate(
            18,
            (i) => 'Bullet point ${i + 1}: Major infrastructure announcement.',
          ),
        );

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'Image post keeps Reload and WhatsApp buttons above bottom nav bar and clickable',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = true;
        final article = buildArticle(type: 'Image', subType: 'Standard');

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            withBottomNavOverlay: true,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final whatsappFinder =
            find.byKey(const Key('image_card_whatsapp_button'));
        expect(whatsappFinder, findsOneWidget);
        expect(tester.getRect(whatsappFinder).bottom, lessThanOrEqualTo(732.0));

        await tester.tap(find.byIcon(Icons.refresh_rounded));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));

        await tester.tap(whatsappFinder);
        await tester.pump();
        expect(dispatchedShares, hasLength(1));
        expect(dispatchedShares.first['isWhatsAppOnly'], isTrue);
      },
    );

    testWidgets(
      'long RichText post with links clips cleanly without overflow and buttons work',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 760),
          bottomPadding: 16.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle(
          content:
              'Read full notice at <link1>Official Portal</link1>. ${List.generate(22, (i) => 'Clause ${i + 1}: Additional regulatory updates for citizens.').join(' ')}',
          links: [
            {'key': 'link1', 'value': 'https://example.com/notice'},
          ],
        );

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsNothing);

        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'extreme tight viewport still prevents overflow and keeps footer clickable',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 380),
          bottomPadding: 8.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle();

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'short news keeps footer compact right below text and buttons work',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle(
          title: 'Short Headline',
          content: 'Brief two line summary.',
        );

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final reloadFinder = find.byKey(const Key('news_card_reload_button'));
        // Short news footer should sit near the content rather than pinned to the bottom edge.
        expect(tester.getRect(reloadFinder).bottom, lessThan(600.0));

        await tester.tap(reloadFinder);
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'long reporter name ellipsizes horizontally without pushing footer buttons off-screen',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 16.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle(
          content: 'Short summary.',
          isReporter: 1,
          reportedBy:
              'Very Long Senior Special Correspondent Bureau Name Hyderabad',
        );

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final whatsappFinder =
            find.byKey(const Key('news_card_whatsapp_button'));
        expect(tester.getRect(whatsappFinder).right, lessThanOrEqualTo(360.0));

        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'isMainScreen mode, sticky post, AI tag reload, and loading spinner work cleanly',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 20.0,
        );
        final homeProvider = _TestHomeProvider()
          ..getAllPostList = [{}, {}, {}]
          ..isBottomEnable = true
          ..aiTagDataLoaded(true)
          ..setSelectedTagId(42);
        final article = buildArticle()..['isStickyPost'] = 1;

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(
              article: article,
              isMainScreen: true,
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final reloadFinder = find.byKey(const Key('news_card_reload_button'));
        // isMainScreen ignores HomeView bottom bar offset and sits near padding.bottom.
        expect(tester.getRect(reloadFinder).bottom, greaterThan(732.0));
        expect(tester.getRect(reloadFinder).bottom, lessThanOrEqualTo(806.0 - 20.0));

        await tester.tap(reloadFinder);
        await tester.pump();
        expect(homeProvider.getAllPostsByAiIdCalls, equals(1));

        // Keep the refresh icon visible instead of swapping to a circular loader when isReload is true.
        homeProvider.isReloadData();
        await tester.pump();
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // When isAiTagDataLoaded is true but selectedTagId is null/0, reload falls back to getAllPost.
        homeProvider
          ..isReloadFalse()
          ..setSelectedTagId(0);
        await tester.tap(reloadFinder);
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
        expect(homeProvider.getAllPostsByAiIdCalls, equals(1));
      },
    );

    testWidgets(
      'Refresh button clears loading spinner after real HomeProvider reload for AI tags and errors',
      (tester) async {
        setViewport(tester, logicalSize: const Size(360, 806));
        final fakeRepo = _FakeHomeRepo()
          ..delay = const Duration(milliseconds: 40)
          ..nextAiTagPosts = [
            buildArticle()..['id'] = 202..['title'] = 'Refreshed AI Post',
            buildArticle()..['id'] = 203..['title'] = 'Second AI Post',
          ];
        final homeProvider = HomeProvider(homeRepo: fakeRepo)
          ..getAllPostList = [
            buildArticle()..['id'] = 101,
            buildArticle()..['id'] = 102,
          ]
          ..isInitialHomeLoaded = true
          ..aiTagDataLoaded(true)
          ..setSelectedTagId(42);

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: homeProvider.getAllPostList.first),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();

        // Refresh icon stays visible while request is in flight (no circular loader), and duplicate taps are ignored.
        expect(homeProvider.isReload, isTrue);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(fakeRepo.getAllAiTagsByIdCalls, equals(1));

        // Once AI-tag fetch completes, spinner disappears cleanly.
        await tester.pump(const Duration(milliseconds: 60));
        expect(homeProvider.isReload, isFalse);
        expect(homeProvider.isHomeLoading, isFalse);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(homeProvider.getAllPostList.first['id'], equals(202));

        // Now test failed feed refresh: spinner still stops and existing posts are preserved.
        homeProvider.aiTagDataLoaded(false);
        fakeRepo.shouldThrow = true;
        await tester.tap(find.byKey(const Key('news_card_reload_button')));
        await tester.pump();
        expect(homeProvider.isReload, isTrue);
        await tester.pump(const Duration(milliseconds: 60));
        expect(homeProvider.isReload, isFalse);
        expect(homeProvider.isHomeLoading, isFalse);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        expect(homeProvider.getAllPostList, hasLength(2));
        expect(homeProvider.getAllPostList.first['id'], equals(202));
      },
    );

    testWidgets(
      'Gallery post replaces Like action with Reload button that triggers reload',
      (tester) async {
        setViewport(tester, logicalSize: const Size(360, 806));
        final homeProvider = _TestHomeProvider();
        final galleryArticle = <String, dynamic>{
          'id': 305,
          'type': 'Gallery',
          'subType': 'Gallery',
          'title': 'Photo Gallery',
          'gallery': const <dynamic>[],
        };

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: FullPageCarousel(
              isHome: true,
              imageUrls: const <dynamic>[],
              postDetails: galleryArticle,
              autoPlay: false,
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const Key('gallery_card_reload_button')),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is BottomActions && w.label == 'లైక్',
          ),
          findsNothing,
        );

        await tester.tap(find.byKey(const Key('gallery_card_reload_button')));
        await tester.pump();
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'BigTvPostLogo aligns flush to bottom-right corner above red divider without bottom spacing',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 20.0,
        );
        final homeProvider = _TestHomeProvider();

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: buildArticle()),
          ),
        );
        await tester.pump();

        final logoFinder = find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName ==
                  'assets/images/BigTvPostLogo.png',
        );
        final dividerFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.color == const Color(0xFFED1C24) &&
              w.constraints?.maxHeight == 4.0,
        );

        expect(logoFinder, findsOneWidget);
        expect(dividerFinder, findsOneWidget);

        final logoWidget = tester.widget<Image>(logoFinder);
        expect(logoWidget.height, isNull);
        expect(logoWidget.alignment, equals(Alignment.bottomRight));

        final logoRect = tester.getRect(logoFinder);
        final dividerRect = tester.getRect(dividerFinder);
        expect(logoRect.bottom, closeTo(dividerRect.top, 0.1));
        expect(logoRect.right, closeTo(360.0, 0.1));
      },
    );
  });

  group('InFocusBarWidget & TranslatedText layout', () {
    testWidgets(
      'InFocusBarWidget INFOCUS badge fits without overflow even with larger text scale and resets on tap',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          textScale: 1.4,
        );
        final homeProvider = _TestHomeProvider()
          ..aiTagEnable = true
          ..aiTagDataLoaded(true)
          ..setSelectedTagId(1)
          ..getAllAiTagsList = [
            {
              'aitagid': 1,
              'aitagname': 'DNA',
              'description': 'BIG TV DNA Show Details',
              'thumbnailUrl': '',
            },
          ];

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: const InFocusBarWidget(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('INFOCUS'), findsOneWidget);

        await tester.tap(find.text('INFOCUS'));
        await tester.pump();
        expect(homeProvider.isAiTagDataLoaded, isFalse);
        expect(homeProvider.getAllPostCalls, equals(1));
      },
    );

    testWidgets(
      'InFocusBarWidget renders shimmer while loading and shrinks when empty',
      (tester) async {
        setViewport(tester, logicalSize: const Size(360, 806));
        final homeProvider = _TestHomeProvider()
          ..aiTagEnable = true
          ..isAiTagsLoading = true;

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: const InFocusBarWidget(),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        homeProvider.isAiTagsLoading = false;
        homeProvider.notifyListeners();
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('INFOCUS'), findsNothing);
      },
    );

    testWidgets(
      'TranslatedText uses cached translation without setState and respects height bounds',
      (tester) async {
        setViewport(tester, logicalSize: const Size(360, 806));
        const srcText =
            'Source news line one two three four five six seven eight nine ten';
        const dstText =
            'Translated news line one two three four five six seven eight nine ten';
        await TranslationService().preloadArticle({
          'content': srcText,
          'translations': {
            'en': {'content': dstText},
          },
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 140,
                height: 44,
                child: TranslatedText(
                  srcText,
                  translate: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, height: 1.2),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.data, equals(dstText));
        expect(textWidget.maxLines, isNotNull);
      },
    );

    testWidgets(
      'TranslatedText returns zero-size widget when constrained height is zero',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 0,
                child: TranslatedText(
                  'Hidden text',
                  translate: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(Text), findsNothing);
      },
    );

    testWidgets(
      'TranslatedText updates cleanly on didUpdateWidget when translate toggles',
      (tester) async {
        const srcText = 'Original Telugu headline';
        const dstText = 'Translated English headline';
        await TranslationService().preloadArticle({
          'content': srcText,
          'translations': {
            'en': {'content': dstText},
          },
        });

        Widget buildSubject(bool translate) {
          return MaterialApp(
            home: Scaffold(
              body: TranslatedText(
                srcText,
                translate: translate,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildSubject(false));
        expect(find.text(srcText), findsOneWidget);

        await tester.pumpWidget(buildSubject(true));
        await tester.pumpAndSettle();
        expect(find.text(dstText), findsOneWidget);
      },
    );

    testWidgets(
      'MainScreenBytView shows multiple lines (not a single ellipsized line) when medium article fits available height',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        const mediumContent =
            'First sentence covering policy decisions taken today across the state.';
        final article = buildArticle(
          title: 'Policy Announcement Today',
          content: mediumContent,
        );

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final bodyTextFinder = find.text(mediumContent);
        expect(bodyTextFinder, findsOneWidget);

        final renderParagraph =
            tester.renderObject<RenderParagraph>(bodyTextFinder);
        // Must wrap across multiple lines (> 60 logical px), never collapse to 1 line (~24px).
        expect(renderParagraph.size.height, greaterThan(60.0));
        expect(renderParagraph.didExceedMaxLines, isFalse);
      },
    );

    testWidgets(
      'MainScreenBytView shows max fitting lines with ellipsis overflow in English translated mode',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        const srcTitle = 'Telugu headline';
        const dstTitle = 'Government Announces Major Infrastructure Plan';
        const srcContent = 'Telugu body content';
        final dstContent = List.generate(
          20,
          (i) => 'English translated sentence ${i + 1} with policy details.',
        ).join(' ');
        await TranslationService().preloadArticle({
          'title': srcTitle,
          'content': srcContent,
          'translations': {
            'en': {'title': dstTitle, 'content': dstContent},
          },
        });
        final homeProvider = _TestHomeProvider()
          ..isBottomEnable = false
          ..isEnglishMode = true;
        final article = buildArticle(
          title: srcTitle,
          content: srcContent,
        );

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final bodyTextFinder = find.text(dstContent);
        expect(bodyTextFinder, findsOneWidget);

        final bodyWidget = tester.widget<Text>(bodyTextFinder);
        expect(bodyWidget.overflow, equals(TextOverflow.ellipsis));
        expect(bodyWidget.maxLines, isNotNull);
        expect(bodyWidget.maxLines!, greaterThan(5));

        final renderParagraph =
            tester.renderObject<RenderParagraph>(bodyTextFinder);
        expect(renderParagraph.didExceedMaxLines, isTrue);
        expect(renderParagraph.size.height, greaterThan(150.0));
      },
    );

    testWidgets(
      'MainScreenBytView shows max fitting lines with ellipsis overflow for very long news',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final homeProvider = _TestHomeProvider()..isBottomEnable = false;
        final article = buildArticle();

        await tester.pumpWidget(
          buildHarness(
            homeProvider: homeProvider,
            child: MainScreenBytView(article: article),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final bodyTextFinder = find.text(article['content'] as String);
        expect(bodyTextFinder, findsOneWidget);

        final bodyWidget = tester.widget<Text>(bodyTextFinder);
        expect(bodyWidget.overflow, equals(TextOverflow.ellipsis));
        expect(bodyWidget.maxLines, isNotNull);
        expect(bodyWidget.maxLines!, greaterThan(5));

        final renderParagraph =
            tester.renderObject<RenderParagraph>(bodyTextFinder);
        expect(renderParagraph.didExceedMaxLines, isTrue);
        expect(renderParagraph.size.height, greaterThan(150.0));
      },
    );

    testWidgets(
      'TranslatedText with overflow ellipsis wraps multi-line in unbounded height instead of collapsing to 1 line',
      (tester) async {
        const longText =
            'Line one wraps cleanly into line two and line three inside an unbounded vertical parent.';
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 160,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TranslatedText(
                      longText,
                      translate: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final renderParagraph = tester.renderObject<RenderParagraph>(
          find.text(longText),
        );
        expect(renderParagraph.size.height, greaterThan(50.0));
        expect(renderParagraph.didExceedMaxLines, isFalse);
      },
    );
  });

  group('MovieReviewsScreen individual post view layout', () {
    testWidgets(
      'MovieRatings post starts below swipe header without top bar overlap and toggles to/from grid view',
      (tester) async {
        setViewport(
          tester,
          logicalSize: const Size(360, 806),
          bottomPadding: 24.0,
        );
        final ratingProvider = RatingProvider(ratingRepo: _StubRatingRepo());
        final homeProvider = _TestHomeProvider()
          ..stubMovieReviews = [
            {
              'id': 501,
              'movie_name': 'Ramayanam',
              'genre': 'మైథాలజీ',
              'certification': 'UA',
              'chotaMeter': '4.2/5',
              'description': 'Classic epic cinematic retelling.',
              'image_url': '',
              'externalRatings': [
                {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
                {'platform_name': 'BookMyShow', 'platform_rating': '8/10'},
              ],
            },
          ];

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, _) => MultiProvider(
              providers: [
                ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
                ChangeNotifierProvider<RatingProvider>.value(
                  value: ratingProvider,
                ),
                ChangeNotifierProvider<SettingsProvider>(
                  create: (_) => SettingsProvider(),
                ),
              ],
              child: const MaterialApp(
                home: MovieReviewsScreen(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(tester.takeException(), isNull);
        final headerFinder =
            find.byKey(const Key('movie_reviews_swipe_header'));
        final postFinder = find.byType(MovieRatings);
        expect(headerFinder, findsOneWidget);
        expect(postFinder, findsOneWidget);

        final headerRect = tester.getRect(headerFinder);
        final postRect = tester.getRect(postFinder);
        // Header stays cleanly above the post with zero overlap.
        expect(headerRect.top, equals(0.0));
        expect(postRect.top, greaterThanOrEqualTo(headerRect.bottom));
        expect(postRect.bottom, lessThanOrEqualTo(806.0));

        // Toggle to grid view and tap item back to individual swipe view.
        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(GridView), findsOneWidget);

        await tester.tap(find.text('Ramayanam').first);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(MovieRatings), findsOneWidget);
        expect(
          tester.getRect(find.byType(MovieRatings)).top,
          greaterThanOrEqualTo(tester.getRect(headerFinder).bottom),
        );
      },
    );
  });
}
