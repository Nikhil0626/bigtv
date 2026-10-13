import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:chotanews/features/reels/data/repositories/reels_repository.dart';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:chotanews/features/home/data/repositories/news_post_repo.dart';
import 'package:chotanews/features/home/presentation/providers/news_posts_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'userId': 'user_test_123',
      'deviceId': 'device_test_456',
    });
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
}
