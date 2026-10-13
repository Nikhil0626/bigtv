import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/services/translation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TranslationService tests', () {
    test('TranslationService singleton instance', () {
      final service1 = TranslationService();
      final service2 = TranslationService();
      expect(identical(service1, service2), isTrue);
    });

    test('getCached returns null for uncached string', () {
      final service = TranslationService();
      expect(service.getCached('some_random_key_12345'), isNull);
    });

    test('getCached returns empty string for empty input', () {
      final service = TranslationService();
      expect(service.getCached(''), equals(''));
      expect(service.getCached('   '), equals('   '));
    });

    test('preloadArticle populates cache from precomputed translation', () async {
      final service = TranslationService();
      final article = {
        'title': 'నమస్తే',
        'translations': {
          'english': {
            'title': 'Hello',
          }
        }
      };

      await service.preloadArticle(article);
      expect(service.getCached('నమస్తే'), equals('Hello'));
    });

    test('preloadArticle handles null, empty and invalid formats without errors', () async {
      final service = TranslationService();
      await service.preloadArticle(null);
      await service.preloadArticle({});
      await service.preloadArticle({'invalid': 123});
      expect(service.isReady, isTrue);
      expect(service.isDownloading, isFalse);
    });

    test('preloadAllArticles and preloadArticles process collections safely', () {
      final service = TranslationService();
      service.preloadAllArticles([]);
      service.preloadArticles([], 0);

      final articles = [
        {'title': 'One', 'translations': {'en': {'title': 'Uno'}}},
        {'title': 'Two', 'translations': {'en': {'title': 'Dos'}}},
      ];
      service.preloadAllArticles(articles);
      expect(service.getCached('One'), equals('Uno'));
      expect(service.getCached('Two'), equals('Dos'));

      service.preloadArticles(articles, 0, ahead: 1);
    });

    test('init executes cleanly', () async {
      final service = TranslationService();
      await service.init();
      expect(service.isReady, isTrue);
    });
  });
}
