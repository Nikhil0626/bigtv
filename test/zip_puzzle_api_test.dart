import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chotanews/features/zip_puzzle/data/mappers/zip_level_definition_mapper.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import 'package:chotanews/features/zip_puzzle/data/models/zip_level_api_model.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_level_api_repository.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_puzzle_repository.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/zip_catalog_provider.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/zip_game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> createValidLevelJson({
    int levelNumber = 1,
    String levelId = 'zip_001',
    String difficulty = 'easy',
    int schemaVersion = 1,
  }) {
    return {
      'gameId': 'zip_puzzle',
      'gameType': 'zip',
      'levelId': levelId,
      'levelNumber': levelNumber,
      'title': 'Test Level $levelNumber',
      'schemaVersion': schemaVersion,
      'difficulty': difficulty,
      'content': {
        'grid': {'rows': 2, 'columns': 2},
        'checkpoints': [
          {'number': 1, 'row': 0, 'col': 0},
          {'number': 2, 'row': 1, 'col': 0},
        ],
        'walls': [
          {
            'from': {'row': 0, 'col': 0},
            'to': {'row': 1, 'col': 0},
          }
        ],
        'solutionPath': [
          {'row': 0, 'col': 0},
          {'row': 0, 'col': 1},
          {'row': 1, 'col': 1},
          {'row': 1, 'col': 0},
        ],
      },
    };
  }

  group('ZipLevelApiModel & DTO Tests', () {
    test('parses valid level JSON correctly', () {
      final json = createValidLevelJson();
      final model = ZipLevelApiModel.fromJson(json);

      expect(model.gameId, 'zip_puzzle');
      expect(model.gameType, 'zip');
      expect(model.levelId, 'zip_001');
      expect(model.levelNumber, 1);
      expect(model.title, 'Test Level 1');
      expect(model.schemaVersion, 1);
      expect(model.difficulty, 'easy');
      expect(model.content, isNotNull);
    });

    test('parses catalogue response with total and items', () {
      final json = {
        'schemaVersion': 1,
        'total': 1,
        'page': 1,
        'pageSize': 100,
        'items': [createValidLevelJson()],
      };
      final catalogue = ZipLevelCatalogueResponse.fromJson(json);

      expect(catalogue.schemaVersion, 1);
      expect(catalogue.total, 1);
      expect(catalogue.items.length, 1);
      expect(catalogue.items.first.levelId, 'zip_001');
    });

    test('throws FormatException on malformed catalogue response', () {
      expect(
        () => ZipLevelCatalogueResponse.fromJson(
            {'schemaVersion': 1, 'items': 'not-a-list'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ZipLevelDefinitionMapper Tests', () {
    test('maps valid API model to LevelDefinition successfully', () {
      final model = ZipLevelApiModel.fromJson(createValidLevelJson());
      final def = ZipLevelDefinitionMapper.mapApiLevelToDefinition(model);

      expect(def.levelNumber, 1);
      expect(def.levelId, 'zip_001');
      expect(def.title, 'Test Level 1');
      expect(def.rows, 2);
      expect(def.cols, 2);
      expect(def.totalRequiredCells, 4);
      expect(def.difficulty, ZipDifficulty.easy);
      expect(def.checkpoints.length, 2);
      expect(def.checkpoints[const GridPoint(0, 0)], 1);
      expect(def.checkpoints[const GridPoint(1, 0)], 2);
      expect(def.solutionPath.length, 4);
      expect(def.walls.length, 1);
      expect(def.hasWall(const GridPoint(0, 0), const GridPoint(1, 0)), isTrue);
    });

    test('rejects unsupported schema version', () {
      final json = createValidLevelJson(schemaVersion: 2);
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<UnsupportedLevelSchemaException>()),
      );
    });

    test('rejects non-sequential checkpoint numbers', () {
      final json = createValidLevelJson();
      (json['content'] as Map)['checkpoints'] = [
        {'number': 1, 'row': 0, 'col': 0},
        {'number': 3, 'row': 1, 'col': 0}, // Skips 2
      ];
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<ZipLevelValidationException>()),
      );
    });

    test('rejects out of bounds checkpoint coordinates', () {
      final json = createValidLevelJson();
      (json['content'] as Map)['checkpoints'] = [
        {'number': 1, 'row': 5, 'col': 0}, // Outside 2x2 grid
      ];
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<ZipLevelValidationException>()),
      );
    });

    test('rejects diagonal solution moves', () {
      final json = createValidLevelJson();
      (json['content'] as Map)['walls'] = [];
      (json['content'] as Map)['solutionPath'] = [
        {'row': 0, 'col': 0},
        {'row': 1, 'col': 1}, // Diagonal from (0,0)
        {'row': 0, 'col': 1},
        {'row': 1, 'col': 0},
      ];
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<ZipLevelValidationException>()),
      );
    });

    test('rejects solution crossing wall', () {
      final json = createValidLevelJson();
      // Wall between (0,0) and (0,1)
      (json['content'] as Map)['walls'] = [
        {
          'from': {'row': 0, 'col': 0},
          'to': {'row': 0, 'col': 1},
        }
      ];
      (json['content'] as Map)['solutionPath'] = [
        {'row': 0, 'col': 0},
        {'row': 0, 'col': 1}, // Crosses wall!
        {'row': 1, 'col': 1},
        {'row': 1, 'col': 0},
      ];
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<ZipLevelValidationException>()),
      );
    });

    test('rejects solution with duplicate cells', () {
      final json = createValidLevelJson();
      (json['content'] as Map)['walls'] = [];
      (json['content'] as Map)['solutionPath'] = [
        {'row': 0, 'col': 0},
        {'row': 0, 'col': 1},
        {'row': 0, 'col': 0}, // Duplicate cell!
        {'row': 1, 'col': 0},
      ];
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<ZipLevelValidationException>()),
      );
    });

    test(
        'rejects level where final checkpoint is not at the end of the solution path',
        () {
      final json = createValidLevelJson();
      // Checkpoints at (0,0) and (1,1), but solution ends at (1,0)
      (json['content'] as Map)['checkpoints'] = [
        {'number': 1, 'row': 0, 'col': 0},
        {'number': 2, 'row': 1, 'col': 1}, // Not at end of path (1,0)
      ];
      final model = ZipLevelApiModel.fromJson(json);

      expect(
        () => ZipLevelDefinitionMapper.mapApiLevelToDefinition(model),
        throwsA(isA<ZipLevelValidationException>().having(
          (e) => e.message,
          'message',
          contains('must be at the end of the solution path'),
        )),
      );
    });
  });

  group('ZipLevelApiRepository Tests', () {
    test('getCatalogue successfully parses catalogue', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/v1/games/zip_puzzle/levels') {
          return http.Response(
            jsonEncode({
              'schemaVersion': 1,
              'total': 1,
              'items': [createValidLevelJson()],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final repo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );

      final catalogue = await repo.getCatalogue();
      expect(catalogue.items.length, 1);
      expect(catalogue.items.first.levelId, 'zip_001');
    });

    test('getLevelById successfully parses single level', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/v1/games/zip_puzzle/levels/zip_001') {
          return http.Response(
            jsonEncode({'item': createValidLevelJson()}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final repo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );

      final level = await repo.getLevelById('zip_001');
      expect(level.levelId, 'zip_001');
      expect(level.levelNumber, 1);
    });

    test('loads dummy levels from MD when useDummyData is true', () async {
      final repo = ZipLevelApiRepository(useDummyData: true);
      final catalogue = await repo.getCatalogue();

      expect(catalogue.items.isNotEmpty, isTrue);
      final firstLevel = catalogue.items.first;
      expect(firstLevel.levelId, 'zip_001');
      expect(firstLevel.title, 'First Steps');
      expect(firstLevel.difficulty, 'easy');
      expect(firstLevel.content, isNotNull);

      final detail = await repo.getLevelById('zip_001');
      expect(detail.title, 'First Steps');
      expect(detail.levelNumber, 1);
    });

    test('handles 404 level not found error safely', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'code': 'LEVEL_NOT_FOUND', 'message': 'Level not found.'}
          }),
          404,
        );
      });

      final repo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );

      expect(
        () => repo.getLevelById('zip_999'),
        throwsA(isA<ZipLevelApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('handles 500 server error safely', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final repo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );

      expect(
        () => repo.getCatalogue(),
        throwsA(isA<ZipLevelApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('handles timeout error gracefully', () async {
      final client = MockClient((request) async {
        throw TimeoutException('Request timed out');
      });

      final repo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );

      expect(
        () => repo.getCatalogue(),
        throwsA(isA<ZipLevelApiException>()
            .having((e) => e.message, 'message', contains('took too long'))),
      );
    });
  });

  group('ZipCatalogProvider Integration Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('loads catalogue and combines with local progress', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'schemaVersion': 1,
            'total': 2,
            'items': [
              createValidLevelJson(
                  levelNumber: 1, levelId: 'zip_001', difficulty: 'easy'),
              createValidLevelJson(
                  levelNumber: 2, levelId: 'zip_002', difficulty: 'hard'),
            ],
          }),
          200,
        );
      });

      final apiRepo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );
      final localRepo = ZipPuzzleRepository(prefs: prefs);

      final provider = ZipCatalogProvider(
        apiRepository: apiRepo,
        repository: localRepo,
      );

      // Wait for initial load
      await provider.loadCatalogAndProgress();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.totalLevels, 2);
      expect(provider.isUnlocked(1), isTrue);
      expect(provider.isUnlocked(2), isFalse);

      // Filter by difficulty
      provider.setFilter(ZipDifficulty.easy);
      expect(provider.filteredLevels.length, 1);
      expect(provider.filteredLevels.first.levelNumber, 1);

      provider.setFilter(null);
      expect(provider.filteredLevels.length, 2);

      // Navigation helpers
      final lvl1 = provider.getLevelByNumber(1);
      expect(lvl1, isNotNull);
      final next = provider.getNextLevel(lvl1!);
      expect(next?.levelNumber, 2);
    });

    test(
        'on API error, provider exposes error state and does not fallback to hardcoded levels',
        () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 503);
      });

      final apiRepo = ZipLevelApiRepository(
        baseUrl: 'https://api.test.com',
        client: client,
        useDummyData: false,
      );
      final localRepo = ZipPuzzleRepository(prefs: prefs);

      final provider = ZipCatalogProvider(
        apiRepository: apiRepo,
        repository: localRepo,
      );

      await provider.loadCatalogAndProgress();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.totalLevels, 0);
      expect(provider.allLevels, isEmpty);
    });

    test('ZipCatalogProvider loads dummy levels from MD seamlessly', () async {
      final localRepo = ZipPuzzleRepository(prefs: prefs);
      final provider = ZipCatalogProvider(
        apiRepository: ZipLevelApiRepository(useDummyData: true),
        repository: localRepo,
      );

      await provider.loadCatalogAndProgress();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.totalLevels, greaterThanOrEqualTo(1));
      expect(provider.allLevels.first.title, 'First Steps');
      expect(provider.allLevels.first.rows, 4);
      expect(provider.allLevels.first.cols, 4);
      expect(provider.isUnlocked(1), isTrue);
    });
  });

  group('ZipGameProvider Regression with Mapped LevelDefinition', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test(
        'gameplay correctly starts, handles moves, walls, undo, and completion',
        () async {
      final model = ZipLevelApiModel.fromJson(createValidLevelJson());
      final def = ZipLevelDefinitionMapper.mapApiLevelToDefinition(model);
      final localRepo = ZipPuzzleRepository(prefs: prefs);

      final game = ZipGameProvider(
        level: def,
        repository: localRepo,
      );

      expect(game.currentPath, isEmpty);
      expect(game.hasStarted, isFalse);

      // Invalid start (not on checkpoint 1)
      game.startPath(const GridPoint(0, 1));
      expect(game.currentPath, isEmpty);
      expect(game.feedbackMessage, isNotNull);

      // Start on checkpoint 1 (0,0)
      game.startPath(const GridPoint(0, 0));
      expect(game.hasStarted, isTrue);
      expect(game.filledCells, 1);

      // Try move across wall (from 0,0 to 1,0 is blocked by wall)
      game.moveTo(const GridPoint(1, 0));
      expect(game.filledCells, 1);
      expect(game.feedbackMessage, 'Blocked by wall');

      // Valid move to (0,1)
      game.moveTo(const GridPoint(0, 1));
      expect(game.filledCells, 2);

      // Undo
      game.undo();
      expect(game.filledCells, 1);

      // Play through solution path: (0,0) -> (0,1) -> (1,1) -> (1,0)
      game.moveTo(const GridPoint(0, 1));
      game.moveTo(const GridPoint(1, 1));
      game.moveTo(const GridPoint(1, 0));

      expect(game.filledCells, 4);
      expect(game.isCompleted, isTrue);
    });
  });
}
