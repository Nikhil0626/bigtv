import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/zip_puzzle/data/mappers/zip_level_definition_mapper.dart';
import 'package:chotanews/features/zip_puzzle/data/models/daily_puzzle_models.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/puzzle_games_api_client.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/daily_puzzle_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily Puzzle Models Tests', () {
    test('ActiveGameItem parses JSON accurately', () {
      final json = {
        'id': '16ff42eb-f4b6-4ddf-a5bc-69cb91ce0a44',
        'slug': 'zip_puzzle',
        'name': 'Zip Puzzle',
        'gameType': 'zip',
        'timezone': 'Asia/Kolkata',
        'description': 'Daily zip game',
        'isActive': true,
      };

      final item = ActiveGameItem.fromJson(json);
      expect(item.id, '16ff42eb-f4b6-4ddf-a5bc-69cb91ce0a44');
      expect(item.slug, 'zip_puzzle');
      expect(item.name, 'Zip Puzzle');
      expect(item.gameType, 'zip');
      expect(item.timezone, 'Asia/Kolkata');
      expect(item.isActive, isTrue);
    });

    test('DailyGameData parses and maps to playable LevelDefinition', () {
      final json = {
        'gameId': 'zip_puzzle',
        'gameName': 'Zip Puzzle',
        'gameType': 'zip',
        'puzzleDate': '2026-10-22',
        'timezone': 'Asia/Kolkata',
        'levelId': 'zip_001',
        'levelNumber': 1,
        'title': 'First Steps',
        'difficulty': 'easy',
        'schemaVersion': 1,
        'contentVersion': 1,
        'content': {
          'grid': {'rows': 4, 'columns': 4},
          'checkpoints': [
            {'col': 0, 'row': 0, 'number': 1},
            {'col': 3, 'row': 0, 'number': 2},
            {'col': 3, 'row': 3, 'number': 3},
            {'col': 0, 'row': 3, 'number': 4},
          ],
          'walls': [
            {
              'from': {'col': 1, 'row': 0},
              'to': {'col': 1, 'row': 1},
            }
          ],
          'solutionPath': [
            {'col': 0, 'row': 0},
            {'col': 1, 'row': 0},
            {'col': 2, 'row': 0},
            {'col': 3, 'row': 0},
            {'col': 3, 'row': 1},
            {'col': 2, 'row': 1},
            {'col': 1, 'row': 1},
            {'col': 0, 'row': 1},
            {'col': 0, 'row': 2},
            {'col': 1, 'row': 2},
            {'col': 2, 'row': 2},
            {'col': 3, 'row': 2},
            {'col': 3, 'row': 3},
            {'col': 2, 'row': 3},
            {'col': 1, 'row': 3},
            {'col': 0, 'row': 3},
          ]
        }
      };

      final dailyData = DailyGameData.fromJson(json);
      expect(dailyData.gameId, 'zip_puzzle');
      expect(dailyData.puzzleDate, '2026-10-22');
      expect(dailyData.difficulty, 'easy');

      final apiModel = dailyData.toApiModel();
      final levelDef = ZipLevelDefinitionMapper.mapApiLevelToDefinition(apiModel);
      expect(levelDef.rows, 4);
      expect(levelDef.cols, 4);
      expect(levelDef.checkpointCount, 4);
      expect(levelDef.solutionPath.length, 16);
      expect(levelDef.walls.length, 1);
    });

    test('DailySubmissionResult parses rank, streak and revive status', () {
      final json = {
        'gameId': 'zip_puzzle',
        'levelId': 'zip_001',
        'levelNumber': 1,
        'playerId': 'user_abc123',
        'durationMs': 28400,
        'bestDurationMs': 28400,
        'score': 100,
        'isNewBest': true,
        'rank': 1,
        'streak': {
          'currentStreak': 5,
          'longestStreak': 12,
          'streakMaintained': true,
          'freeMonthlyReviveApplied': true,
        }
      };

      final sub = DailySubmissionResult.fromJson(json);
      expect(sub.gameId, 'zip_puzzle');
      expect(sub.durationMs, 28400);
      expect(sub.rank, 1);
      expect(sub.streak.currentStreak, 5);
      expect(sub.streak.longestStreak, 12);
      expect(sub.streak.freeMonthlyReviveApplied, isTrue);
    });

    test('DailyLeaderboardResponse parses entries and formattedTime', () {
      final json = {
        'gameId': 'zip_puzzle',
        'levelId': 'zip_001',
        'currentUser': {
          'rank': 1,
          'playerId': 'user_abc123',
          'displayName': 'Pravasa',
          'avatarUrl': null,
          'bestDurationMs': 28400,
          'score': 100,
          'completedAt': '2026-10-22T08:59:49.752Z',
        },
        'entries': [
          {
            'rank': 1,
            'playerId': 'user_abc123',
            'displayName': 'Pravasa',
            'bestDurationMs': 28400,
            'score': 100,
          },
          {
            'rank': 2,
            'playerId': 'player_alex',
            'displayName': 'Alex',
            'bestDurationMs': 65200,
            'score': 100,
          }
        ],
        'page': 1,
        'limit': 50,
        'total': 2,
        'totalPages': 1,
      };

      final lb = DailyLeaderboardResponse.fromJson(json);
      expect(lb.currentUser?.rank, 1);
      expect(lb.currentUser?.formattedTime, '28.4s');
      expect(lb.entries.length, 2);
      expect(lb.entries[1].formattedTime, '1:05.2s');
    });

    test('StreakCalendarResponse parses 7 days rolling calendar and gap days', () {
      final json = {
        'playerId': 'user_abc123',
        'gameId': 'zip_puzzle',
        'currentStreak': 5,
        'longestStreak': 12,
        'lastActivityDate': '2026-10-22',
        'monthlyFreeReviveAvailable': true,
        'autoApproveRemaining': 2,
        'gapDays': 2,
        'canRequestRecovery': true,
        'last7Days': [
          {'date': '2026-10-16', 'dayName': 'Fri', 'completed': true, 'isToday': false},
          {'date': '2026-10-17', 'dayName': 'Sat', 'completed': true, 'isToday': false},
          {'date': '2026-10-18', 'dayName': 'Sun', 'completed': true, 'isToday': false},
          {'date': '2026-10-19', 'dayName': 'Mon', 'completed': true, 'isToday': false},
          {'date': '2026-10-20', 'dayName': 'Tue', 'completed': false, 'isToday': false},
          {'date': '2026-10-21', 'dayName': 'Wed', 'completed': false, 'isToday': false},
          {'date': '2026-10-22', 'dayName': 'Thu', 'completed': true, 'isToday': true},
        ]
      };

      final streak = StreakCalendarResponse.fromJson(json);
      expect(streak.currentStreak, 5);
      expect(streak.gapDays, 2);
      expect(streak.canRequestRecovery, isTrue);
      expect(streak.monthlyFreeReviveAvailable, isTrue);
      expect(streak.last7Days.length, 7);
      expect(streak.last7Days.last.isToday, isTrue);
    });

    test('StreakRecoveryResponse parses AUTO_APPROVED and PENDING', () {
      final approvedJson = {
        'success': true,
        'status': 'AUTO_APPROVED',
        'message': 'Restored',
        'restoredStreak': 15,
        'autoApproveRemaining': 1,
      };
      final approved = StreakRecoveryResponse.fromJson(approvedJson);
      expect(approved.isAutoApproved, isTrue);
      expect(approved.restoredStreak, 15);
      expect(approved.autoApproveRemaining, 1);

      final pendingJson = {
        'success': true,
        'status': 'PENDING',
        'message': 'Review required',
        'requestId': 'req_123',
      };
      final pending = StreakRecoveryResponse.fromJson(pendingJson);
      expect(pending.isPending, isTrue);
      expect(pending.requestId, 'req_123');
    });
  });

  group('PuzzleGamesApiClient with Mock Client Tests', () {
    test('Successful API responses parse correctly', () async {
      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.endsWith('/games')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'items': [
                  {
                    'id': 'zip_1',
                    'slug': 'zip_puzzle',
                    'name': 'Zip Puzzle',
                    'gameType': 'zip',
                    'timezone': 'Asia/Kolkata',
                    'description': 'Daily zip',
                    'isActive': true,
                  }
                ]
              }
            }),
            200,
          );
        } else if (path.endsWith('/today')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'gameId': 'zip_puzzle',
                'gameName': 'Zip Puzzle',
                'gameType': 'zip',
                'puzzleDate': '2026-10-22',
                'timezone': 'Asia/Kolkata',
                'levelId': 'zip_001',
                'levelNumber': 1,
                'title': 'Mock Today',
                'difficulty': 'easy',
                'schemaVersion': 1,
                'contentVersion': 1,
                'content': {
                  'grid': {'rows': 3, 'columns': 3},
                  'checkpoints': [
                    {'col': 0, 'row': 0, 'number': 1},
                    {'col': 2, 'row': 2, 'number': 2},
                  ],
                  'walls': [],
                  'solutionPath': [
                    {'col': 0, 'row': 0},
                    {'col': 1, 'row': 0},
                    {'col': 2, 'row': 0},
                    {'col': 2, 'row': 1},
                    {'col': 1, 'row': 1},
                    {'col': 0, 'row': 1},
                    {'col': 0, 'row': 2},
                    {'col': 1, 'row': 2},
                    {'col': 2, 'row': 2},
                  ]
                }
              }
            }),
            200,
          );
        } else if (path.endsWith('/submit')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'gameId': 'zip_puzzle',
                'levelId': 'zip_001',
                'levelNumber': 1,
                'playerId': 'player_123',
                'durationMs': 15000,
                'bestDurationMs': 15000,
                'score': 100,
                'isNewBest': true,
                'rank': 1,
                'streak': {
                  'currentStreak': 4,
                  'longestStreak': 10,
                  'streakMaintained': true,
                  'freeMonthlyReviveApplied': false,
                }
              }
            }),
            201,
          );
        }

        return http.Response('Not Found', 404);
      });

      final apiClient = PuzzleGamesApiClient(
        baseUrl: 'http://mocked/api/v1',
        client: mockClient,
      );

      final games = await apiClient.getActiveGames();
      expect(games.length, 1);
      expect(games.first.slug, 'zip_puzzle');

      final today = await apiClient.getTodayGame('zip_puzzle');
      expect(today.title, 'Mock Today');

      final subResult = await apiClient.submitTodayCompletion(
        gameId: 'zip_puzzle',
        playerId: 'player_123',
        durationMs: 15000,
      );
      expect(subResult.rank, 1);
      expect(subResult.streak.currentStreak, 4);
    });

    test('Throws on network failure without static game injection', () async {
      final failingClient = MockClient((request) async {
        throw Exception('Network unreachable');
      });

      final apiClient = PuzzleGamesApiClient(
        baseUrl: 'http://mocked/api/v1',
        client: failingClient,
      );

      expect(() => apiClient.getActiveGames(), throwsA(isA<Exception>()));
    });
  });

  group('DailyPuzzleProvider State Management Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'loginId': 'test_player_456',
        'zip_puzzle_v1_player_name': 'Test Hero',
      });
    });

    test('Provider init resolves player ID and loads data', () async {
      final provider = DailyPuzzleProvider();
      await provider.init();

      expect(provider.playerId, 'test_player_456');
      expect(provider.displayName, 'Test Hero');
      expect(provider.todayPuzzle, isNotNull);
      expect(provider.todayLevelDefinition, isNotNull);
      expect(provider.streakCalendar, isNotNull);
    });

    test('submitDailyCompletion updates lastSubmissionResult', () async {
      final provider = DailyPuzzleProvider();
      await provider.init();

      final result = await provider.submitDailyCompletion(
        durationMs: 25000,
        moves: 16,
      );

      expect(result, isNotNull);
      expect(provider.lastSubmissionResult, isNotNull);
      expect(provider.isTodayCompleted, isTrue);
    });
  });
}
