import 'package:chotanews/aggricator_screens/rating_screen/rating_model.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds canonical deep links, localized share copy, and analytics events
/// when sharing Movie Review cards.
class MovieReviewShareHelper {
  static const String baseUrl = 'https://app.bigtv24x7.com';
  static const String _imageHost = 'https://migwp.chotanews.com';

  /// Generates the canonical deep link URL for a movie review using app.bigtv24x7.com.
  static String getMovieReviewShareUrl(dynamic postId) {
    final id = postId?.toString().trim() ?? '';
    if (id.isNotEmpty && id != '0' && id.toLowerCase() != 'null') {
      return '$baseUrl/moviereviews?postId=$id';
    }
    return '$baseUrl/moviereviews';
  }

  /// Resolves a relative or absolute poster image URL for sharing.
  static String resolveImageUrl(dynamic imageUrl) {
    final url = imageUrl?.toString().trim() ?? '';
    if (url.isEmpty || url.toLowerCase() == 'null') return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$_imageHost$url';
    return '$_imageHost/$url';
  }

  /// Generates localized share text for a movie review including rating and deep link.
  static String getShareText({
    required Map<String, dynamic> article,
    MovieReviewDetails? ratingDetails,
    String? langCode,
    bool? isTelugu,
  }) {
    final code = _normalizeLanguage(langCode: langCode, isTelugu: isTelugu);
    final postId = article['id'] ?? article['post_id'] ?? article['postId'];
    final shareUrl = getMovieReviewShareUrl(postId);

    final movieTitle = (article['movie_name'] ??
            article['movieName'] ??
            article['title'] ??
            '')
        .toString()
        .trim();

    String rating = (article['chotaMeter'] ??
            article['chotarating'] ??
            article['critic_rating'] ??
            article['criticRating'] ??
            '')
        .toString()
        .trim();

    if ((rating.isEmpty || rating == 'null') &&
        ratingDetails != null &&
        ratingDetails.criticRating != null &&
        ratingDetails.criticRating! > 0) {
      rating = '${ratingDetails.criticRating!.toStringAsFixed(1)}/5';
    } else if ((rating.isEmpty || rating == 'null') &&
        ratingDetails != null &&
        ratingDetails.overallRating > 0) {
      rating = '${ratingDetails.overallRating.toStringAsFixed(1)}/5';
    }

    final genre = (article['genre'] ?? article['genreTelugu'] ?? '')
        .toString()
        .trim();
    final certification =
        (article['certification'] ?? article['censor_rating'] ?? '')
            .toString()
            .trim();
    final synopsis =
        (article['description'] ?? article['content'] ?? '').toString().trim();

    final buffer = StringBuffer();
    if (code == 'ml') {
      buffer.writeln(
        '🎬 ${movieTitle.isNotEmpty ? movieTitle : 'BIG TV സിനിമ റിവ്യൂ'}',
      );
      if (rating.isNotEmpty && rating != 'null') {
        buffer.writeln('⭐ BIG TV റേറ്റിംഗ്: $rating');
      }
    } else if (code == 'en') {
      buffer.writeln(
        '🎬 ${movieTitle.isNotEmpty ? movieTitle : 'BIG TV Movie Review'}',
      );
      if (rating.isNotEmpty && rating != 'null') {
        buffer.writeln('⭐ BIG TV Rating: $rating');
      }
    } else {
      buffer.writeln(
        '🎬 ${movieTitle.isNotEmpty ? movieTitle : 'BIG TV సినిమా సమీక్ష'}',
      );
      if (rating.isNotEmpty && rating != 'null') {
        buffer.writeln('⭐ BIG TV రేటింగ్: $rating');
      }
    }

    final metaParts = <String>[
      if (genre.isNotEmpty && genre != 'null') genre,
      if (certification.isNotEmpty && certification != 'null') certification,
    ];
    if (metaParts.isNotEmpty) {
      buffer.writeln('🎭 ${metaParts.join(' • ')}');
    }

    if (synopsis.isNotEmpty && synopsis != 'null') {
      final compact = synopsis.replaceAll(RegExp(r'\s+'), ' ').trim();
      final snippet =
          compact.length > 140 ? '${compact.substring(0, 137)}...' : compact;
      buffer.writeln();
      buffer.writeln(snippet);
    }

    buffer.writeln();
    if (code == 'ml') {
      buffer.writeln('പൂർണ്ണ റിവ്യൂ വായിക്കാനും റേറ്റിംഗ് നൽകാനും:');
    } else if (code == 'en') {
      buffer.writeln('Read the full review & share your rating on BIG TV:');
    } else {
      buffer.writeln('పూర్తి సమీక్ష చదవండి & మీ రేటింగ్ ఇవ్వండి:');
    }
    buffer.write(shareUrl);

    return buffer.toString();
  }

  /// Shares a movie review card via WhatsApp or the system share sheet.
  static Future<void> shareMovieReview({
    required BuildContext context,
    required Map<String, dynamic> article,
    MovieReviewDetails? ratingDetails,
    ScreenshotController? screenshotController,
    bool isWhatsAppOnly = false,
    String? langCode,
    ContentShareDispatcher? dispatcher,
  }) async {
    final resolvedLang = await _resolveLanguage(context, langCode: langCode);
    if (!context.mounted) return;

    final postId = article['id'] ?? article['post_id'] ?? article['postId'];
    final shareUrl = getMovieReviewShareUrl(postId);
    final movieTitle = (article['movie_name'] ??
            article['movieName'] ??
            article['title'] ??
            'BIG TV Movie Review')
        .toString()
        .trim();
    final imageUrl =
        resolveImageUrl(article['image_url'] ?? article['imageUrl']);

    final shareText = getShareText(
      article: article,
      ratingDetails: ratingDetails,
      langCode: resolvedLang,
    );

    AnalyticsService.instance.track(
      AnalyticsEventName.movieReviewShare,
      properties: {
        'post_id': postId?.toString() ?? '',
        'movie_title': movieTitle,
        'share_target': isWhatsAppOnly ? 'whatsapp' : 'system_share',
        'share_url': shareUrl,
        'language': resolvedLang,
      },
    );

    final activeDispatcher = dispatcher ?? ContentShareDispatcher();
    await activeDispatcher.shareContent(
      context: context,
      shareText: shareText,
      subject: movieTitle.isNotEmpty
          ? '$movieTitle - BIG TV Movie Review'
          : 'BIG TV Movie Review',
      filePrefix: 'movie_review',
      screenshotController: screenshotController,
      fallbackImageUrl: imageUrl,
      isWhatsAppOnly: isWhatsAppOnly,
    );
  }

  static String _normalizeLanguage({String? langCode, bool? isTelugu}) {
    final code = (langCode ?? '').trim().toLowerCase();
    if (code.isNotEmpty) return code;
    if (isTelugu != null) return isTelugu ? 'te' : 'ml';
    return 'te';
  }

  static Future<String> _resolveLanguage(
    BuildContext context, {
    String? langCode,
  }) async {
    if (langCode != null && langCode.trim().isNotEmpty) {
      return langCode.trim().toLowerCase();
    }
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (homeProvider.langCode.trim().isNotEmpty) {
        return homeProvider.langCode.trim().toLowerCase();
      }
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getString('selectedLanguageCode') ??
              prefs.getString('selectedLanguage') ??
              'te')
          .trim()
          .toLowerCase();
    } catch (_) {
      return 'te';
    }
  }
}

