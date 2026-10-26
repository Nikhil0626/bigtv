import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GameShareHelper {
  static const String baseUrl = 'https://app.bigtv24x7.com';

  /// Generates the canonical deep link URL for a game using app.bigtv24x7.com
  static String getGameShareUrl(String gameSlug) {
    final s = gameSlug.toLowerCase();
    if (s.contains('sudoku')) {
      return '$baseUrl/games?game=sudoku';
    } else if (s.contains('patch')) {
      return '$baseUrl/games?game=patch';
    } else {
      return '$baseUrl/games?game=zip';
    }
  }

  /// Shares game completion stats with a direct deep link to the game
  static Future<void> shareGame({
    required BuildContext context,
    required String gameSlug,
    required String gameTitle,
    String? formattedTime,
    int? rank,
    int? streak,
  }) async {
    final url = getGameShareUrl(gameSlug);

    final buffer = StringBuffer();
    buffer.writeln('🎮 I just solved today\'s $gameTitle on Big TV Games!');

    final stats = <String>[];
    if (formattedTime != null && formattedTime.isNotEmpty) {
      stats.add('⏱️ Time: $formattedTime');
    }
    if (rank != null && rank > 0) {
      stats.add('🏆 Rank: #$rank');
    }
    if (streak != null && streak > 0) {
      stats.add('🔥 Streak: $streak ${streak == 1 ? "day" : "days"}');
    }

    if (stats.isNotEmpty) {
      buffer.writeln(stats.join(' | '));
    }

    buffer.writeln();
    buffer.writeln('Can you beat my score? Play today\'s puzzle on the Big TV App:');
    buffer.write(url);

    final text = buffer.toString();

    try {
      if (Platform.isIOS) {
        final size = MediaQuery.of(context).size;
        await Share.share(
          text,
          subject: 'Play $gameTitle on Big TV',
          sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
        );
      } else {
        await Share.share(
          text,
          subject: 'Play $gameTitle on Big TV',
        );
      }
    } catch (e) {
      debugPrint('GameShareHelper.shareGame error: $e');
    }
  }
}
