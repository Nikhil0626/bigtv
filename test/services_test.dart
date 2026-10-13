import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/services/video_position_service.dart';
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Services Tests', () {
    test('BaseUrls contains required API endpoints and domain constants', () {
      expect(BaseUrls.newServerBaseUrl, isNotEmpty);
      expect(BaseUrls.baseUrlAwsDev, isNotEmpty);
      expect(BaseUrls.eventUrl, equals('/events'));
      expect(BaseUrls.getAllReels, equals('/reels'));
      expect(BaseUrls.getNews, equals('/allposts'));
      expect(BaseUrls.getReportersApi, equals('/api/v1/reporters'));
      expect(BaseUrls.aboutPage, contains('chotanews.com'));
      expect(BaseUrls.privacyPage, contains('chotanews.com'));
    });

    test('VideoPositionService saves, retrieves, and clears position', () async {
      SharedPreferences.setMockInitialValues({});

      final videoItem = {'id': 'vid_123', 'url': 'https://example.com/stream.mp4'};
      const duration = Duration(seconds: 45);

      await VideoPositionService.savePosition(videoItem, duration);

      final retrieved = await VideoPositionService.getSavedPosition(videoItem);
      expect(retrieved.inSeconds, equals(45));

      await VideoPositionService.clearPosition(videoItem);
      final cleared = await VideoPositionService.getSavedPosition(videoItem);
      expect(cleared, equals(Duration.zero));
    });

    test('VideoPositionService handles null and empty videoItem gracefully', () async {
      expect(await VideoPositionService.getSavedPosition(null), equals(Duration.zero));
      expect(await VideoPositionService.getSavedPosition({}), equals(Duration.zero));

      await VideoPositionService.savePosition(null, const Duration(seconds: 10));
      await VideoPositionService.clearPosition(null);
    });

    test('BaseService initializes dio interceptors and configuration', () {
      final service = BaseService();
      expect(service.dio, isNotNull);
      expect(service.dio.interceptors, isNotEmpty);
    });

    test('BaseService makeRequest dispatches with appropriate parameters', () async {
      final service = BaseService();

      // Intercept request and return mock response
      service.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {'status': 'ok', 'method': options.method},
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final getResp = await service.makeRequest(
        url: '/test-get',
        method: RequestType.get,
        token1: 'test_token',
        queryParameters: {'filter': 'active', 'limit': 10},
      );
      expect(getResp.statusCode, equals(200));

      final postResp = await service.makeRequest(
        url: '/test-post',
        method: RequestType.post,
        body: {'title': 'New Post'},
      );
      expect(postResp.statusCode, equals(200));

      final putResp = await service.makeRequest(
        url: '/test-put',
        method: RequestType.put,
        body: {'title': 'Updated Post'},
      );
      expect(putResp.statusCode, equals(200));

      final deleteResp = await service.makeRequest(
        url: '/test-delete',
        method: RequestType.delete,
        body: {'id': 123},
      );
      expect(deleteResp.statusCode, equals(200));
    });

    test('BaseService handles DioException gracefully', () async {
      final service = BaseService();
      service.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {'error': 'Not found'},
                ),
              ),
            );
          },
        ),
      );

      final resp = await service.makeRequest(
        url: '/not-found',
        method: RequestType.get,
      );
      expect(resp, isA<Response>());
      expect((resp as Response).statusCode, equals(404));
    });
  });
}
