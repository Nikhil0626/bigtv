import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'package:chotanews/features/home/data/repositories/home_repo.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';

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
  });
}
