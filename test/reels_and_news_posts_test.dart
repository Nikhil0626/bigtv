import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/home/data/repositories/news_post_repo.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/providers/news_posts_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/features/reels/data/models/reels_model.dart';
import 'package:chotanews/features/reels/data/repositories/reels_repository.dart';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:chotanews/features/reels/presentation/screens/reels_view.dart';
import 'package:chotanews/features/reels/presentation/widgets/reels_screen_preview.dart';
import 'package:chotanews/utils/app_no_data.dart';

class _FakeVideoPlayerController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  int initializeCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  int seekCalls = 0;
  bool disposed = false;
  final Future<void> Function()? onInitialize;

  _FakeVideoPlayerController({this.onInitialize})
      : super(
          const VideoPlayerValue(
            duration: Duration(seconds: 30),
            size: Size(720, 1280),
            isInitialized: false,
            isPlaying: false,
          ),
        );

  @override
  int get playerId => VideoPlayerController.kUninitializedPlayerId;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    if (onInitialize != null) {
      await onInitialize!();
    }
    if (!disposed) {
      value = value.copyWith(isInitialized: true);
    }
  }

  @override
  Future<void> play() async {
    playCalls++;
    if (!disposed) {
      value = value.copyWith(isPlaying: true);
    }
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    if (!disposed) {
      value = value.copyWith(isPlaying: false);
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekCalls++;
    if (!disposed) {
      value = value.copyWith(position: position);
    }
  }

  @override
  Future<void> setLooping(bool looping) async {
    if (!disposed) {
      value = value.copyWith(isLooping: looping);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    if (!disposed) {
      value = value.copyWith(volume: volume);
    }
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestTabHomeProvider extends HomeProvider {
  Completer<Map<String, dynamic>?>? liveTvCompleter;
  int fetchLiveTvCalls = 0;
  int getAllPostCalls = 0;

  @override
  Future<Map<String, dynamic>?> fetchLiveTvStream({
    String? targetLangCode,
  }) async {
    fetchLiveTvCalls++;
    if (liveTvCompleter != null) {
      return liveTvCompleter!.future;
    }
    return null;
  }

  @override
  Future<void> getAllPost({
    String postIds = "0",
    bool isGetAllPost = false,
  }) async {
    getAllPostCalls++;
  }

  @override
  void flipEvent(String pageName, dynamic id, dynamic val) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'userId': 'user_test_123',
      'deviceId': 'device_test_456',
      'selectedLanguageCode': 'te',
      'eventsEnable': false,
    });
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('wakelock_plus'),
      (_) async => null,
    );
  });

  group('ReelsRepo Tests', () {
    test('getAllReels dispatches request and returns Response', () async {
      final repo = ReelsRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': []},
              ),
            );
          },
        ),
      );

      final resp = await repo.getAllReels({'limit': 10});
      expect(resp.statusCode, equals(200));
      expect(resp.data, isNotNull);
    });

    test('getSingleReelData dispatches request and returns Response', () async {
      final repo = ReelsRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'_id': 'reel_1', 'title': 'Test Reel'}},
              ),
            );
          },
        ),
      );

      final resp = await repo.getSingleReelData({'id': 'reel_1'});
      expect(resp.statusCode, equals(200));
      expect(resp.data['data']['_id'], equals('reel_1'));
    });

    test('postLikes dispatches post request', () async {
      final repo = ReelsRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'liked'},
              ),
            );
          },
        ),
      );

      final resp = await repo.postLikes({'reel_id': 'reel_1', 'like': true});
      expect(resp.statusCode, equals(200));
    });
  });

  group('ReelsProviders Tests', () {
    test('initial state and toggleMute', () {
      final provider = ReelsProviders();
      expect(provider.reelsLoading, isTrue);
      expect(provider.isMuted, isFalse);
      expect(provider.getAllReelsList, isEmpty);
      expect(provider.isLikeList, isEmpty);

      provider.toggleMute();
      expect(provider.isMuted, isTrue);

      provider.toggleMute();
      expect(provider.isMuted, isFalse);
    });
  });

  group('NewsPostRepo Tests', () {
    test('getAllComments dispatches GET request', () async {
      final repo = NewsPostRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'comments': [
                    {
                      '_id': 'comm_1',
                      'post_id': 'post_100',
                      'comment': 'Informative news update',
                      'created_at': '2025-01-01T10:00:00Z',
                      'user': {
                        'name': 'Reader',
                        'profile_image': 'https://example.com/user.jpg'
                      }
                    }
                  ]
                },
              ),
            );
          },
        ),
      );

      final resp = await repo.getAllComments({'post_id': 'post_100'});
      expect(resp.statusCode, equals(200));
      expect(resp.data['comments'], isNotEmpty);
    });

    test('sendPostComments dispatches POST request', () async {
      final repo = NewsPostRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
          },
        ),
      );

      final resp = await repo.sendPostComments({'post_id': 'post_100', 'comment': 'Great post'});
      expect(resp.statusCode, equals(200));
    });
  });

  group('NewsPostsProvider Tests', () {
    test('initial state is correct', () {
      final provider = NewsPostsProvider();
      expect(provider.isLoadingComments, isFalse);
      expect(provider.sendCommentLoading, isFalse);
      expect(provider.getAllCommentsList, isEmpty);
    });
  });

  group('Reels playback stops on Live TV tap and tab switches', () {
    ReelsModel makeReel({
      String id = 'reel_1',
      String publisher = 'BIG TV',
      String publisherImage = '',
    }) =>
        ReelsModel(
          id: id,
          videoUrl: 'https://cdn.example.com/videos/$id.mp4',
          thumbnailUrl: '',
          title: 'Breaking News Reel $id',
          publisher: publisher,
          publisherImage: publisherImage,
          likes: 10,
          comments: 2,
          shares: 1,
          duration: '30s',
          createdAt: '2026-11-11T10:00:00Z',
          postName: 'Reel',
          reportedBy: '',
          links: const [],
          content: 'Sample reel summary',
          isBookmarked: 0,
        );

    Widget buildReelsHomeHarness({
      required _TestTabHomeProvider homeProvider,
      required ReelsProviders reelsProvider,
      required VideoPlayerController Function(String url) videoControllerBuilder,
      bool includeBottomNav = true,
    }) {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, _) => MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
            ChangeNotifierProvider<ReelsProviders>.value(value: reelsProvider),
            ChangeNotifierProvider<VideoProvider>(
              create: (_) => VideoProvider(),
            ),
            ChangeNotifierProvider<SettingsProvider>(
              create: (_) => SettingsProvider(),
            ),
            ChangeNotifierProvider<BookmarksProvider>(
              create: (_) => BookmarksProvider(),
            ),
            ChangeNotifierProvider<AuthenticationProvider>(
              create: (_) => AuthenticationProvider(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  PageView(
                    controller: homeProvider.homePageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      homeProvider.onItemTapped(index);
                      if (index != 2) {
                        reelsProvider.pauseAllReels();
                      }
                    },
                    children: [
                      const Center(child: Text('Search Tab')),
                      const Center(child: Text('News Tab')),
                      ReelPreviewScreen(
                        initialIndex: 0,
                        videoControllerBuilder: videoControllerBuilder,
                      ),
                      const Center(child: Text('More Tab')),
                    ],
                  ),
                  if (includeBottomNav)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Consumer<HomeProvider>(
                        builder: (context, hp, _) =>
                            HomeBottomNavigationBar(homeProvider: hp),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    test('pauseAllReels increments pauseEpoch and invokes listeners safely', () {
      final provider = ReelsProviders();
      int firstCalls = 0;
      int secondCalls = 0;

      late void Function() selfRemovingListener;
      selfRemovingListener = () {
        firstCalls++;
        provider.removePauseListener(selfRemovingListener);
      };
      void persistentListener() {
        secondCalls++;
      }

      provider.addPauseListener(selfRemovingListener);
      provider.addPauseListener(persistentListener);

      final initialEpoch = provider.pauseEpoch;
      provider.pauseAllReels();

      expect(provider.pauseEpoch, equals(initialEpoch + 1));
      expect(firstCalls, equals(1));
      expect(secondCalls, equals(1));

      provider.pauseAllReels();
      expect(provider.pauseEpoch, equals(initialEpoch + 2));
      expect(firstCalls, equals(1));
      expect(secondCalls, equals(2));

      provider.removePauseListener(persistentListener);
      provider.pauseAllReels();
      expect(secondCalls, equals(2));
    });

    testWidgets(
      'tapping Live TV immediately stops active Reel playback before stream loads',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2)
          ..liveTvCompleter = Completer<Map<String, dynamic>?>();
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel()];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(fakeController.playCalls, equals(1));
        expect(fakeController.value.isPlaying, isTrue);

        await tester.tap(find.byKey(const Key('bottom_nav_live_tv')));
        await tester.pump();

        // Must pause synchronously on tap even while Live TV stream is pending.
        expect(homeProvider.fetchLiveTvCalls, equals(1));
        expect(fakeController.pauseCalls, greaterThanOrEqualTo(1));
        expect(fakeController.value.isPlaying, isFalse);

        homeProvider.liveTvCompleter!.complete(null);
        await tester.pump();
        expect(fakeController.value.isPlaying, isFalse);
      },
    );

    testWidgets(
      'switching away from Reels tab pauses active Reel immediately',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2);
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel()];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(fakeController.value.isPlaying, isTrue);
        final int pausesBeforeReelsTap = fakeController.pauseCalls;

        // Tapping current Reels tab does not pause playback.
        await tester.tap(find.byKey(const Key('bottom_nav_tab_2')));
        await tester.pump();
        expect(fakeController.pauseCalls, equals(pausesBeforeReelsTap));
        expect(fakeController.value.isPlaying, isTrue);

        // Tapping News tab stops playback immediately.
        await tester.tap(find.byKey(const Key('bottom_nav_tab_1')));
        await tester.pump();
        expect(homeProvider.selectedIndex, equals(1));
        expect(fakeController.pauseCalls, greaterThan(pausesBeforeReelsTap));
        expect(fakeController.value.isPlaying, isFalse);
      },
    );

    testWidgets(
      'pushing another route over ReelPreviewScreen stops playback automatically',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2);
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel()];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
            includeBottomNav: false,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(fakeController.value.isPlaying, isTrue);

        final NavigatorState navigator =
            tester.state<NavigatorState>(find.byType(Navigator));
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Center(child: Text('Live TV'))),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Live TV'), findsOneWidget);
        expect(fakeController.pauseCalls, greaterThanOrEqualTo(1));
        expect(fakeController.value.isPlaying, isFalse);
      },
    );

    testWidgets(
      'in-flight reel initialization completing after Live TV tap stays paused',
      (tester) async {
        final initCompleter = Completer<void>();
        final fakeController = _FakeVideoPlayerController(
          onInitialize: () => initCompleter.future,
        );
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2);
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel()];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
          ),
        );
        await tester.pump();

        // Tap Live TV while video initialization is still in flight.
        await tester.tap(find.byKey(const Key('bottom_nav_live_tv')));
        await tester.pump();

        // Initialization now finishes later in background.
        initCompleter.complete();
        await tester.pump();
        await tester.pump();

        expect(fakeController.playCalls, equals(0));
        expect(fakeController.pauseCalls, greaterThanOrEqualTo(1));
        expect(fakeController.value.isPlaying, isFalse);
      },
    );

    testWidgets(
      'double tapping on reel shows centered like popup, likes reel without pausing, and stays liked on repeat double tap',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2);
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel(id: 'reel_like_pop')];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
            includeBottomNav: false,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(fakeController.value.isPlaying, isTrue);
        expect(reelsProvider.isReelLiked('reel_like_pop'), isFalse);
        expect(
          find.byKey(const Key('reel_double_tap_like_popup')),
          findsNothing,
        );

        final gestureFinder = find.byKey(const Key('reel_card_gesture_area'));
        expect(gestureFinder, findsOneWidget);
        final Offset cardCenter = tester.getCenter(find.byType(ReelsCardView));

        // Simulate a real double tap (gap between 40ms min and 300ms timeout).
        await tester.tapAt(cardCenter);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tapAt(cardCenter);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));

        final popupFinder = find.byKey(const Key('reel_double_tap_like_popup'));
        expect(popupFinder, findsOneWidget);
        final Offset popupCenter = tester.getCenter(popupFinder);
        expect((popupCenter.dx - cardCenter.dx).abs(), lessThanOrEqualTo(1.0));
        expect((popupCenter.dy - cardCenter.dy).abs(), lessThanOrEqualTo(1.0));

        // Reel must become liked and continue playing without pausing.
        expect(reelsProvider.isReelLiked('reel_like_pop'), isTrue);
        expect(fakeController.pauseCalls, equals(0));
        expect(fakeController.value.isPlaying, isTrue);

        // Wait for animation to finish and dismiss the popup.
        await tester.pumpAndSettle();
        expect(popupFinder, findsNothing);

        // Repeat double tap while already liked still pops the icon and keeps it liked.
        await tester.tapAt(cardCenter);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tapAt(cardCenter);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));

        expect(popupFinder, findsOneWidget);
        expect(reelsProvider.isReelLiked('reel_like_pop'), isTrue);
        expect(fakeController.value.isPlaying, isTrue);

        await tester.pumpAndSettle();
        expect(popupFinder, findsNothing);

        // Single tap still toggles play/pause cleanly.
        await tester.tapAt(cardCenter);
        await tester.pump(const Duration(milliseconds: 350));
        expect(fakeController.pauseCalls, equals(1));
        expect(fakeController.value.isPlaying, isFalse);

        // Let the 650ms play/pause feedback timer finish cleanly.
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'tapping News tab in bottom nav triggers getAllPost and resets to first post',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final newsPageController = PageController(initialPage: 2);

        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2)
          ..pageController = newsPageController
          ..getAllPostList = [
            {'id': 1, 'title': 'First'},
            {'id': 2, 'title': 'Second'},
            {'id': 3, 'title': 'Third'},
          ];
        homeProvider.setCurrentPageIndex(2);
        homeProvider.aiTagDataLoaded(true);
        homeProvider.setSelectedTagId(42);

        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel()];

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, _) => MultiProvider(
              providers: [
                ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
                ChangeNotifierProvider<ReelsProviders>.value(value: reelsProvider),
                ChangeNotifierProvider<VideoProvider>(
                  create: (_) => VideoProvider(),
                ),
                ChangeNotifierProvider<SettingsProvider>(
                  create: (_) => SettingsProvider(),
                ),
                ChangeNotifierProvider<BookmarksProvider>(
                  create: (_) => BookmarksProvider(),
                ),
                ChangeNotifierProvider<AuthenticationProvider>(
                  create: (_) => AuthenticationProvider(),
                ),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: Stack(
                    children: [
                      PageView(
                        controller: homeProvider.homePageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const Center(child: Text('Search Tab')),
                          Consumer<HomeProvider>(
                            builder: (_, hp, __) => PageView(
                              controller: hp.pageController,
                              children: const [
                                Center(child: Text('News Post 1')),
                                Center(child: Text('News Post 2')),
                                Center(child: Text('News Post 3')),
                              ],
                            ),
                          ),
                          ReelPreviewScreen(
                            initialIndex: 0,
                            videoControllerBuilder: (_) => fakeController,
                          ),
                          const Center(child: Text('More Tab')),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Consumer<HomeProvider>(
                          builder: (context, hp, _) =>
                              HomeBottomNavigationBar(homeProvider: hp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        await tester.tap(find.byKey(const Key('bottom_nav_tab_1')));
        await tester.pump();
        await tester.pump();

        expect(homeProvider.selectedIndex, equals(1));
        expect(homeProvider.getAllPostCalls, equals(1));
        expect(homeProvider.isAiTagDataLoaded, isFalse);
        expect(homeProvider.selectedTagId, isNull);
        expect(homeProvider.currentPageIndex, equals(0));
        expect(homeProvider.pageController?.page?.round(), equals(0));
        expect(find.text('News Post 1'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping BigTV publisher logo in ReelPreviewScreen does not redirect',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2);
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [
            makeReel(
              publisher: 'BIGTV',
              publisherImage: 'https://example.com/bigtv_logo.png',
            ),
          ];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
            includeBottomNav: false,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('BIGTV'), findsOneWidget);
        final logoFinder = find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.child is ClipRRect &&
              (w.child as ClipRRect).child.toString().contains('CachedNetworkImage'),
        );
        expect(logoFinder, findsOneWidget);

        await tester.tap(logoFinder);
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Videos'), findsNothing);
        expect(find.text('BIGTV'), findsOneWidget);
      },
    );

    testWidgets(
      'Reels video fills full screen from top down to bottom nav with BoxFit.cover',
      (tester) async {
        final fakeController = _FakeVideoPlayerController();
        final homeProvider = _TestTabHomeProvider()
          ..selectedIndex = 2
          ..homePageController = PageController(initialPage: 2);
        final reelsProvider = ReelsProviders()
          ..reelsLoading = false
          ..getAllReelsList = [makeReel()];

        await tester.pumpWidget(
          buildReelsHomeHarness(
            homeProvider: homeProvider,
            reelsProvider: reelsProvider,
            videoControllerBuilder: (_) => fakeController,
            includeBottomNav: true,
          ),
        );
        await tester.pump();
        await tester.pump();

        final Rect cardRect = tester.getRect(find.byType(ReelsCardView));
        final Rect videoAreaRect =
            tester.getRect(find.byKey(const Key('reel_card_gesture_area')));
        final Rect navRect =
            tester.getRect(find.byType(HomeBottomNavigationBar));

        expect(videoAreaRect.top, equals(cardRect.top));
        expect(videoAreaRect.top, equals(0.0));
        expect(videoAreaRect.bottom, closeTo(navRect.top, 0.5));

        final fittedBox = tester.widget<FittedBox>(
          find.descendant(
            of: find.byKey(const Key('reel_card_gesture_area')),
            matching: find.byType(FittedBox),
          ),
        );
        expect(fittedBox.fit, equals(BoxFit.cover));
      },
    );

    testWidgets(
      'ReelsScreen empty state shows white No data Found on black background in light and dark mode',
      (tester) async {
        for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
          final reelsProvider = _StubEmptyReelsProviders()
            ..reelsLoading = false
            ..getAllReelsList = [];

          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(360, 690),
              builder: (context, _) => MultiProvider(
                providers: [
                  ChangeNotifierProvider<ReelsProviders>.value(
                    value: reelsProvider,
                  ),
                ],
                child: MaterialApp(
                  theme: theme,
                  home: const Scaffold(body: ReelsScreen()),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump();

          final container = tester.widget<Container>(
            find.byKey(const Key('reels_empty_state')),
          );
          expect(container.color, equals(Colors.black));

          final noDataText = tester.widget<Text>(find.text('No data Found'));
          expect(noDataText.style?.color, equals(Colors.white));
        }
      },
    );

    testWidgets(
      'AppNoData adapts text color to light and dark theme by default',
      (tester) async {
        Future<Color?> pumpAndReadColor(ThemeData theme) async {
          await tester.pumpWidget(
            ScreenUtilInit(
              key: ValueKey<Brightness>(theme.brightness),
              designSize: const Size(360, 690),
              builder: (context, _) => MaterialApp(
                theme: theme,
                home: const Scaffold(body: AppNoData()),
              ),
            ),
          );
          await tester.pump();
          final text = tester.widget<Text>(find.text('No data Found'));
          return text.style?.color;
        }

        expect(
          await pumpAndReadColor(AppTheme.lightTheme),
          equals(AppColorTokens.lightTextPrimary),
        );
        expect(
          await pumpAndReadColor(AppTheme.darkTheme),
          equals(AppColorTokens.darkTextPrimary),
        );
      },
    );
  });
}

class _StubEmptyReelsProviders extends ReelsProviders {
  @override
  Future getAllReels({String postId = "0"}) async {}
}
