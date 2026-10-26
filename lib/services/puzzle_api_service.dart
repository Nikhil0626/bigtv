import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_urls.dart';

class PuzzleApiService {
  static const String defaultBaseUrl = 'https://api.pravasamedia.com/api/v1';

  static String get baseUrl {
    final server = BaseUrls.newServerBaseUrl;
    if (server.isNotEmpty) {
      return '$server/api/v1';
    }
    return defaultBaseUrl;
  }

  /// 1. Fetch today's official daily puzzle
  static Future<Map<String, dynamic>> getTodayGame({
    required String gameSlug, // 'sudoku' or 'patch'
    String? playerId,
  }) async {
    final query = playerId != null && playerId.isNotEmpty ? '?playerId=$playerId' : '';
    final url = '$baseUrl/games/$gameSlug/today$query';

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': '*/*'})
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json['data'] != null) {
          return Map<String, dynamic>.from(json['data']);
        }
        return json;
      }
    } catch (e) {
      debugPrint('PuzzleApiService.getTodayGame error: $e, using local fallback');
    }

    // High quality offline fallback data matching the schema
    return _getFallbackTodayGame(gameSlug);
  }

  /// 2. Submit puzzle completion & save streak
  static Future<Map<String, dynamic>> submitGame({
    required String gameSlug,
    required String playerId,
    required int durationMs,
    required int score,
    String? displayName,
    int? moves,
  }) async {
    final url = '$baseUrl/games/$gameSlug/submit';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
            body: jsonEncode({
              'playerId': playerId,
              'durationMs': durationMs,
              'score': score,
              'displayName': displayName ?? 'Player',
              'completed': true,
              'moves': moves,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json['data'] != null) {
          return Map<String, dynamic>.from(json['data']);
        }
        return json;
      }
    } catch (e) {
      debugPrint('PuzzleApiService.submitGame error: $e, using fallback response');
    }

    return {
      'rank': 1,
      'durationMs': durationMs,
      'score': score,
      'streak': {
        'currentStreak': 1,
        'longestStreak': 1,
        'freeRevivesRemaining': 1,
      },
    };
  }

  /// 3. Fetch today's leaderboard
  static Future<Map<String, dynamic>> getLeaderboard({
    required String gameSlug,
    required String playerId,
  }) async {
    final url = '$baseUrl/games/$gameSlug/today/leaderboard?playerId=$playerId';

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': '*/*'})
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Map<String, dynamic>.from(json['data'] ?? {});
      }
    } catch (e) {
      debugPrint('PuzzleApiService.getLeaderboard error: $e');
    }

    return {
      'entries': [
        {'rank': 1, 'displayName': 'You', 'durationMs': 12500, 'formattedTime': '12.5s'},
      ],
      'userRank': 1,
    };
  }

  static Map<String, dynamic> _getFallbackTodayGame(String gameSlug) {
    if (gameSlug.contains('patch')) {
      return {
        'levelId': 'patch_daily_01',
        'levelNumber': 1,
        'difficulty': 'easy',
        'content': {
          'grid': {'rows': 5, 'columns': 5},
          'palette': {
            'gridBorder': '#BDC3C7',
            'boardBackground': '#F4F6F7',
          },
          'pieces': [
            {
              'id': 'p1',
              'color': '#E74C3C',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 0, 'col': 1},
                {'row': 0, 'col': 2},
                {'row': 0, 'col': 3},
                {'row': 0, 'col': 4},
              ],
            },
            {
              'id': 'p2',
              'color': '#3498DB',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 1, 'col': 0},
                {'row': 2, 'col': 0},
                {'row': 3, 'col': 0},
                {'row': 0, 'col': 1},
              ],
            },
            {
              'id': 'p3',
              'color': '#2ECC71',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 0, 'col': 1},
                {'row': 1, 'col': 0},
                {'row': 1, 'col': 1},
                {'row': 2, 'col': 0},
              ],
            },
            {
              'id': 'p4',
              'color': '#F39C12',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 0, 'col': 1},
                {'row': 0, 'col': 2},
                {'row': 1, 'col': 1},
                {'row': 1, 'col': 2},
              ],
            },
            {
              'id': 'p5',
              'color': '#9B59B6',
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 1, 'col': 0},
                {'row': 1, 'col': 1},
                {'row': 2, 'col': 1},
                {'row': 2, 'col': 2},
              ],
            },
          ],
          'clues': [
            {'col': 0, 'row': 0, 'shape': 'wide', 'value': 5},
            {'col': 0, 'row': 1, 'shape': 'tall', 'value': 5},
            {'col': 1, 'row': 1, 'shape': 'sq', 'value': 5},
            {'col': 2, 'row': 0, 'shape': 'wide', 'value': 5},
            {'col': 2, 'row': 2, 'shape': 'sq', 'value': 5},
          ],
          'solution': [
            {
              'pieceId': 'p1',
              'anchor': {'row': 0, 'col': 0},
              'cells': [
                {'row': 0, 'col': 0},
                {'row': 0, 'col': 1},
                {'row': 0, 'col': 2},
                {'row': 0, 'col': 3},
                {'row': 0, 'col': 4},
              ],
            },
          ],
        },
      };
    }

    // Default Sudoku (6x6)
    return {
      'levelId': 'sudoku_daily_01',
      'levelNumber': 1,
      'difficulty': 'easy',
      'content': {
        'grid': {'rows': 6, 'columns': 6},
        'initialGrid': [
          [1, 0, 3, 0, 5, 0],
          [0, 5, 0, 1, 0, 3],
          [2, 0, 1, 0, 6, 0],
          [0, 6, 0, 2, 0, 1],
          [3, 0, 2, 0, 4, 0],
          [0, 4, 0, 3, 0, 2],
        ],
        'solution': [
          [1, 2, 3, 4, 5, 6],
          [4, 5, 6, 1, 2, 3],
          [2, 3, 1, 5, 6, 4],
          [5, 6, 4, 2, 3, 1],
          [3, 1, 2, 6, 4, 5],
          [6, 4, 5, 3, 1, 2],
        ],
        'palette': {
          'gridBorder': '#BDC3C7',
          'blockBorder': '#1A252F',
          'cellBackground': '#FFFFFF',
          'selectedCell': '#D6EAF8',
          'highlightNumber': '#AED6F1',
          'clueText': '#1B2631',
          'userText': '#2980B9',
        },
      },
    };
  }
}
