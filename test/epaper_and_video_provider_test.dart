import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:chotanews/features/home/data/repositories/home_repo.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';
import 'package:chotanews/features/home/presentation/widgets/main_screen_byts_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/fullscreen_video_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';

class _TestVideoController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  bool disposed = false;

  _TestVideoController()
      : super(
          const VideoPlayerValue(
            duration: Duration(seconds: 20),
            size: Size(1280, 720),
            isInitialized: false,
            isPlaying: false,
          ),
        );

  @override
  int get playerId => VideoPlayerController.kUninitializedPlayerId;

  @override
  VideoViewType get viewType => VideoViewType.textureView;

  @override
  Future<void> initialize() async {
    value = value.copyWith(isInitialized: true);
  }

  @override
  Future<void> play() async {
    if (!disposed) value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    if (!disposed) value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> setLooping(bool looping) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {
    disposed = true;
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InitCounterWidget extends StatefulWidget {
  final VoidCallback onInit;
  const _InitCounterWidget({required this.onInit});

  @override
  State<_InitCounterWidget> createState() => _InitCounterWidgetState();
}

class _InitCounterWidgetState extends State<_InitCounterWidget> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 100, width: 100);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeRepo Tests', () {
    test('getEpapers dispatches GET request and parses response', () async {
      final repo = HomeRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 'ep_1',
                    'editionName': 'Hyderabad',
                    'publishDate': '2025-01-10T00:00:00Z',
                    'pages': ['https://example.com/p1.jpg']
                  }
                ],
              ),
            );
          },
        ),
      );

      final resp = await repo.getEpapers({'skip': 0, 'limit': 10});
      expect(resp.statusCode, equals(200));
      expect(resp.data, isList);
      expect((resp.data as List).length, equals(1));
    });

    test('getAppConfig dispatches GET request', () async {
      final repo = HomeRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'version': '6.0.3', 'forceUpdate': false},
              ),
            );
          },
        ),
      );

      final resp = await repo.getAppConfig();
      expect(resp.statusCode, equals(200));
      expect(resp.data['version'], equals('6.0.3'));
    });
  });

  group('EpaperProvider Tests', () {
    test('page navigation, overlay toggle, and reset detail state', () {
      final provider = EpaperProvider();
      expect(provider.currentPage, equals(0));
      expect(provider.showOverlay, isTrue);

      provider.setCurrentPage(3);
      expect(provider.currentPage, equals(3));

      provider.toggleOverlay();
      expect(provider.showOverlay, isFalse);

      provider.toggleOverlay();
      expect(provider.showOverlay, isTrue);

      provider.resetDetailState();
      expect(provider.currentPage, equals(0));
      expect(provider.showOverlay, isTrue);
    });

    test('filters epapers by edition and date properly', () {
      final provider = EpaperProvider();

      provider.allEpapers = [
        {
          'id': '1',
          'editionName': 'Hyderabad',
          'publishDate': '2025-05-15T08:00:00.000Z',
        },
        {
          'id': '2',
          'editionName': 'Warangal',
          'publishDate': '2025-05-15T09:00:00.000Z',
        },
        {
          'id': '3',
          'editionName': 'Hyderabad',
          'publishDate': '2025-05-16T08:00:00.000Z',
        },
      ];

      final editions = provider.getAvailableEditions();
      expect(editions, containsAll(['Hyderabad', 'Warangal']));

      // Filter by Edition
      provider.setEditionFilter('Hyderabad');
      expect(provider.selectedEdition, equals('Hyderabad'));
      expect(provider.epapers.length, equals(2));

      // Filter by Date
      provider.setDateFilter(DateTime(2025, 5, 15));
      expect(provider.selectedDate, equals(DateTime(2025, 5, 15)));
      expect(provider.epapers.length, equals(1));
      expect(provider.epapers.first['id'], equals('1'));

      // Clear filters
      provider.clearFilters();
      expect(provider.selectedEdition, isNull);
      expect(provider.selectedDate, isNull);
      expect(provider.epapers.length, equals(3));
    });
  });

  group('VideoProvider Tests', () {
    test('initial values and safe lifecycle', () async {
      final provider = VideoProvider();
      expect(provider.controller, isNull);
      expect(provider.currentUrl, equals(''));
      expect(provider.isPlaying, isFalse);
      expect(provider.isMuted, isFalse);
      expect(provider.isLoading, isFalse);

      // Safe dispose without active controller
      await provider.disposeController();
      expect(provider.isPlaying, isFalse);
      expect(provider.isMuted, isFalse);
    });

    test('togglePlayPause and toggleMute safe guards when uninitialized', () {
      final provider = VideoProvider();
      // Should not throw even when controller is null
      provider.pauseVideo();
      provider.togglePlayPause(isPlay: true);
      provider.togglePlayPause(isPlay: false);
      provider.toggleMute();

      expect(provider.isPlaying, isFalse);
      expect(provider.isMuted, isFalse);
    });

    test('initializeVideo reuses existing initialized controller for same URL',
        () async {
      final created = <_TestVideoController>[];
      final provider = VideoProvider(
        controllerBuilder: (_) {
          final c = _TestVideoController();
          created.add(c);
          return c;
        },
      );

      await provider.initializeVideo('https://cdn.example.com/video1.mp4');
      expect(created.length, equals(1));
      final first = created.first;
      expect(first.disposed, isFalse);
      expect(provider.controller, same(first));

      // Re-initializing with the exact same URL must NOT dispose the active controller
      await provider.initializeVideo('https://cdn.example.com/video1.mp4');
      expect(created.length, equals(1));
      expect(first.disposed, isFalse);
      expect(provider.controller, same(first));

      // Switching to a different URL disposes the previous controller cleanly
      await provider.initializeVideo('https://cdn.example.com/video2.mp4');
      expect(created.length, equals(2));
      expect(first.disposed, isTrue);
      expect(provider.isControllerDisposed(first), isTrue);
      expect(provider.controller, same(created[1]));
    });

    testWidgets(
        'LandscapeFlexible preserves child State across portrait and landscape',
        (tester) async {
      int initCount = 0;

      Widget buildForSize(Size size) => MediaQuery(
            data: MediaQueryData(size: size),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    LandscapeFlexible(
                      child: _InitCounterWidget(onInit: () => initCount++),
                    ),
                  ],
                ),
              ),
            ),
          );

      await tester.pumpWidget(buildForSize(const Size(360, 800)));
      expect(initCount, equals(1));

      // Rotate to landscape: child must stay mounted without re-initializing
      await tester.pumpWidget(buildForSize(const Size(800, 360)));
      expect(initCount, equals(1));
    });

    testWidgets(
        'FullscreenVideoView handles controller disposal without crashing',
        (tester) async {
      final created = <_TestVideoController>[];
      final provider = VideoProvider(
        controllerBuilder: (_) {
          final c = _TestVideoController();
          created.add(c);
          return c;
        },
      );

      await provider.initializeVideo('https://cdn.example.com/video1.mp4');
      final controller = provider.controller!;

      await tester.pumpWidget(
        ChangeNotifierProvider<VideoProvider>.value(
          value: provider,
          child: MaterialApp(
            home: FullscreenVideoView(controller: controller),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Even if controller is disposed while fullscreen is open, no disposed-controller crash occurs
      await provider.disposeController();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
