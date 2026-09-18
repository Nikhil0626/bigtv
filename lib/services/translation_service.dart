import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

/// A singleton service that handles Telugu <-> English translation
/// using GoogleTranslator package with Groq, OpenAI, MyMemory, and ML Kit fallbacks.
class TranslationService extends ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _googleTranslator = GoogleTranslator();

  OnDeviceTranslator? _translator;
  bool _modelDownloaded = false;
  bool _isDownloading = false;
  bool _initFailed = false;
  Completer<void>? _initCompleter;

  final Map<String, String> _cache = {};

  bool get isReady => true;
  bool get isDownloading => _isDownloading;

  /// Synchronously returns cached translation if available.
  String? getCached(String text, {String to = 'en'}) {
    if (text.trim().isEmpty) return text;
    final key = '${to}_$text';
    return _cache[key];
  }

  /// Ensures the model is downloaded and the translator is ready.
  Future<void> init() async {
    if (_modelDownloaded) return;
    if (_isDownloading && _initCompleter != null) {
      log('[TranslationService] Download already in progress, awaiting completer...');
      await _initCompleter!.future;
      return;
    }

    _isDownloading = true;
    _initCompleter = Completer<void>();
    if (_initFailed) {
      log('[TranslationService] Retrying after previous failure...');
      _initFailed = false;
    }

    log('[TranslationService] Starting model download...');

    try {
      final modelManager = OnDeviceTranslatorModelManager();

      // Telugu model
      bool teDownloaded = await modelManager.isModelDownloaded(TranslateLanguage.telugu.bcpCode);
      log('[TranslationService] Telugu model already downloaded: $teDownloaded');
      if (!teDownloaded) {
        log('[TranslationService] Downloading Telugu model...');
        await modelManager.downloadModel(TranslateLanguage.telugu.bcpCode);
        log('[TranslationService] Telugu model downloaded successfully.');
      }

      // English model
      bool enDownloaded = await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
      log('[TranslationService] English model already downloaded: $enDownloaded');
      if (!enDownloaded) {
        log('[TranslationService] Downloading English model...');
        await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
        log('[TranslationService] English model downloaded successfully.');
      }

      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.telugu,
        targetLanguage: TranslateLanguage.english,
      );

      _modelDownloaded = true;
      _initFailed = false;
      log('[TranslationService] Translator ready.');
      notifyListeners();
    } catch (e, st) {
      _initFailed = true;
      log('[TranslationService] ERROR during init: $e', stackTrace: st);
    } finally {
      _isDownloading = false;
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
      _initCompleter = null;
    }
  }

  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String _openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  /// Tries Groq LLaMA-3.3-70b API for fast, fluent, news-grade translation.
  Future<String?> _translateWithGroq(String text) async {
    if (_groqApiKey.isEmpty) return null;
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional news translator. Translate the given text (Telugu or Malayalam) into fluent, natural English suitable for news articles. Return ONLY the translated English text with no additional explanations, notes, or quotes.',
            },
            {
              'role': 'user',
              'content': text,
            }
          ],
          'temperature': 0.2,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          final String translated = data['choices'][0]['message']['content']?.toString().trim() ?? '';
          if (translated.isNotEmpty && translated != text) {
            return translated;
          }
        }
      } else {
        log('[TranslationService] Groq API HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      log('[TranslationService] Groq translation failed: $e');
    }
    return null;
  }

  /// Tries OpenAI ChatGPT API (gpt-4o-mini) for fluent, news-grade translation.
  Future<String?> _translateWithOpenAI(String text) async {
    if (_openAiApiKey.isEmpty) return null;
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a news translator. Translate the given Telugu text into fluent, concise English suitable for news articles. Return ONLY the translated English text with no additional explanations or quotes.',
            },
            {
              'role': 'user',
              'content': text,
            }
          ],
          'temperature': 0.3,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          final String translated = data['choices'][0]['message']['content']?.toString().trim() ?? '';
          if (translated.isNotEmpty && translated != text) {
            return translated;
          }
        }
      } else {
        log('[TranslationService] OpenAI API HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      log('[TranslationService] OpenAI translation failed: $e');
    }
    return null;
  }

  /// Tries online neural translation as second tier fallback.
  Future<String?> _translateOnline(String text) async {
    try {
      final uri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=te|en'
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['responseData'] != null) {
          final String translated = data['responseData']['translatedText']?.toString() ?? '';
          if (translated.isNotEmpty && translated != text && !translated.contains('MYMEMORY WARNING')) {
            return translated;
          }
        }
      }
    } catch (e) {
      log('[TranslationService] Online translation failed or timed out: $e');
    }
    return null;
  }

  /// Tries translator package (GoogleTranslator) for high-performance translation.
  Future<String?> _translateWithTranslatorPackage(String text, {String to = 'en'}) async {
    try {
      final translation = await _googleTranslator.translate(text, to: to);
      final String result = translation.text.trim();
      if (result.isNotEmpty && result != text) {
        return result;
      }
    } catch (e) {
      log('[TranslationService] GoogleTranslator package error: $e');
    }
    return null;
  }

  /// Translates [text] using translator package (GoogleTranslator) with Groq, OpenAI, MyMemory, and ML Kit fallbacks.
  Future<String> translate(String text, {String to = 'en'}) async {
    if (text.trim().isEmpty) return text;
    final cacheKey = '${to}_$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Tier 1: Try `translator` package (GoogleTranslator)
    final translatorResult = await _translateWithTranslatorPackage(text, to: to);
    if (translatorResult != null && translatorResult.isNotEmpty) {
      _cache[cacheKey] = translatorResult;
      notifyListeners();
      return translatorResult;
    }

    // Tier 2: Try Groq API (LLaMA-3.3-70b-versatile)
    final groqResult = await _translateWithGroq(text);
    if (groqResult != null && groqResult.isNotEmpty) {
      _cache[cacheKey] = groqResult;
      notifyListeners();
      return groqResult;
    }

    // Tier 3: Try OpenAI ChatGPT API (gpt-4o-mini)
    final openAiResult = await _translateWithOpenAI(text);
    if (openAiResult != null && openAiResult.isNotEmpty) {
      _cache[cacheKey] = openAiResult;
      notifyListeners();
      return openAiResult;
    }

    // Tier 4: Try High-Quality Online Neural Machine Translation
    final onlineResult = await _translateOnline(text);
    if (onlineResult != null && onlineResult.isNotEmpty) {
      _cache[cacheKey] = onlineResult;
      notifyListeners();
      return onlineResult;
    }

    // Tier 5: Fallback to Google ML Kit On-Device Translation
    if (!_modelDownloaded) {
      log('[TranslationService] translate() calling ML Kit fallback: initializing model...');
      await init();
    }

    if (!_modelDownloaded || _translator == null) {
      log('[TranslationService] translateText skipped: model not downloaded or translator null.');
      return text;
    }

    try {
      final result = await _translator!.translateText(text);
      _cache[cacheKey] = result;
      notifyListeners();
      return result;
    } catch (e) {
      log('[TranslationService] translateText error: $e');
      return text;
    }
  }

  /// Pre-translates title, content, and bullet points of [article] asynchronously.
  /// First checks if pre-computed [translations] (e.g. english/en) are provided by server,
  /// caching them directly into [_cache] for instant zero-latency rendering.
  Future<void> preloadArticle(dynamic article) async {
    if (article == null || article is! Map) return;

    final Map<String, dynamic>? translations = article['translations'] is Map
        ? Map<String, dynamic>.from(article['translations'])
        : null;

    Map<String, dynamic>? englishMap;
    if (translations != null) {
      for (var key in translations.keys) {
        final k = key.toString().toLowerCase();
        if (k == 'english' || k == 'en') {
          if (translations[key] is Map) {
            englishMap = Map<String, dynamic>.from(translations[key]);
            break;
          }
        }
      }
    }

    if (englishMap != null && englishMap.isNotEmpty) {
      bool addedAny = false;

      // 1. Title
      final String origTitle = article['title']?.toString() ?? "";
      final String enTitle = englishMap['title']?.toString() ?? "";
      if (origTitle.isNotEmpty && enTitle.isNotEmpty) {
        _cache['en_$origTitle'] = enTitle;
        addedAny = true;
      }

      // 2. Notification Title
      final String origNotif = article['notificationtitle']?.toString() ?? article['notificationTitle']?.toString() ?? "";
      final String enNotif = englishMap['notificationtitle']?.toString() ?? englishMap['notificationTitle']?.toString() ?? "";
      if (origNotif.isNotEmpty && enNotif.isNotEmpty) {
        _cache['en_$origNotif'] = enNotif;
        addedAny = true;
      }

      // 3. Image Title
      final String origImg = article['imagetitel']?.toString() ?? article['imagetitle']?.toString() ?? article['imageTitle']?.toString() ?? "";
      final String enImg = englishMap['imagetitel']?.toString() ?? englishMap['imagetitle']?.toString() ?? englishMap['imageTitle']?.toString() ?? "";
      if (origImg.isNotEmpty && enImg.isNotEmpty) {
        _cache['en_$origImg'] = enImg;
        addedAny = true;
      }

      // 4. Content
      final String origContent = article['content']?.toString() ?? "";
      final String enContent = englishMap['content']?.toString() ?? "";
      if (origContent.isNotEmpty && enContent.isNotEmpty) {
        _cache['en_$origContent'] = enContent;
        addedAny = true;

        List<String> origWords = origContent.split(RegExp(r'\s+'));
        List<String> enWords = enContent.split(RegExp(r'\s+'));
        if (origWords.length > 55) {
          String displayOrigContent = origWords.take(55).join(' ') + "...";
          String displayEnContent = enWords.length > 55
              ? enWords.take(55).join(' ') + "..."
              : enContent;
          _cache['en_$displayOrigContent'] = displayEnContent;
        }
      }

      // 5. Bullet Points
      final origBullets = article['bulletPoints'] ?? article['bullet_points'];
      final enBullets = englishMap['bulletPoints'] ?? englishMap['bullet_points'];
      if (origBullets is List && enBullets is List) {
        for (int i = 0; i < origBullets.length; i++) {
          final String origB = origBullets[i]?.toString() ?? "";
          if (origB.isNotEmpty && i < enBullets.length) {
            final String enB = enBullets[i]?.toString() ?? "";
            if (enB.isNotEmpty) {
              _cache['en_$origB'] = enB;
              addedAny = true;
            }
          }
        }
      }

      if (addedAny) {
        notifyListeners();
        return;
      }
    }

    // Fallback to online/MLKit translation if no pre-computed server translation exists
    final String title = article['title']?.toString() ?? "";
    if (title.isNotEmpty && !_cache.containsKey('en_$title')) {
      translate(title);
    }

    final String content = article['content']?.toString() ?? "";
    if (content.isNotEmpty) {
      if (!_cache.containsKey('en_$content')) {
        translate(content);
      }
      List<String> words = content.split(RegExp(r'\s+'));
      if (words.length > 55) {
        String displayContent = words.take(55).join(' ') + "...";
        if (!_cache.containsKey('en_$displayContent')) {
          translate(displayContent);
        }
      }
    }

    if (article['bulletPoints'] is List) {
      for (var item in article['bulletPoints']) {
        final str = item?.toString() ?? "";
        if (str.isNotEmpty && !_cache.containsKey('en_$str')) {
          translate(str);
        }
      }
    }
  }

  /// Preloads translations for all articles in a list.
  void preloadAllArticles(List<dynamic> articles) {
    if (articles.isEmpty) return;
    for (var article in articles) {
      preloadArticle(article);
    }
  }

  /// Preloads translations for a list of articles starting from [currentIndex] up to [ahead] items.
  void preloadArticles(List<dynamic> articles, int currentIndex, {int ahead = 5}) {
    if (articles.isEmpty) return;
    final int start = currentIndex < 0 ? 0 : currentIndex;
    final int end = (start + ahead) < articles.length ? (start + ahead) : articles.length - 1;
    for (int i = start; i <= end; i++) {
      preloadArticle(articles[i]);
    }
  }

  @override
  void dispose() {
    _translator?.close();
    _translator = null;
    _modelDownloaded = false;
    _initFailed = false;
    super.dispose();
  }
}

