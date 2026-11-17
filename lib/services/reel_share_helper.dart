class ReelShareHelper {
  static const String baseUrl = 'https://app.bigtv24x7.com';

  /// Generates the canonical deep link URL for a reel using app.bigtv24x7.com.
  static String getReelShareUrl(dynamic reelId) {
    final id = reelId?.toString().trim() ?? '';
    if (id.isNotEmpty && id != '0' && id.toLowerCase() != 'null') {
      return '$baseUrl/reels?reelId=$id';
    }
    return '$baseUrl/reels';
  }

  /// Generates formatted share text with reel title and canonical app deep link.
  static String getShareText({
    required String title,
    dynamic reelId,
  }) {
    final cleanTitle = title.trim();
    final shareUrl = getReelShareUrl(reelId);
    if (cleanTitle.isEmpty) {
      return shareUrl;
    }
    return "$cleanTitle\n\n$shareUrl";
  }
}

