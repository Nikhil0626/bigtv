import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/services/video_position_service.dart';

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
  });
}
