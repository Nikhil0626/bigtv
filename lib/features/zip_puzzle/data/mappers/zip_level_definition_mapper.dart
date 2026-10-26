import '../models/grid_point.dart';
import '../models/level_definition.dart';
import '../models/wall.dart';
import '../models/zip_level_api_model.dart';
import '../models/zip_level_content_dto.dart';

class UnsupportedLevelSchemaException implements Exception {
  final int schemaVersion;
  const UnsupportedLevelSchemaException(this.schemaVersion);

  @override
  String toString() =>
      'Unsupported level schemaVersion: $schemaVersion. Expected version 1.';
}

class ZipLevelValidationException implements Exception {
  final String message;
  const ZipLevelValidationException(this.message);

  @override
  String toString() => 'ZipLevelValidationException: $message';
}

class ZipLevelDefinitionMapper {
  static const int supportedSchemaVersion = 1;

  static LevelDefinition mapApiLevelToDefinition(ZipLevelApiModel remote) {
    if (remote.schemaVersion != supportedSchemaVersion) {
      throw UnsupportedLevelSchemaException(remote.schemaVersion);
    }

    if (remote.content == null) {
      // Create a lightweight summary LevelDefinition if content is not yet fetched
      final diff = _parseDifficulty(remote.difficulty, remote.levelNumber);
      return LevelDefinition(
        levelNumber: remote.levelNumber,
        levelId: remote.levelId,
        title: remote.title,
        difficulty: diff,
        checkpointCount: 0,
        rows: 0,
        cols: 0,
        checkpoints: const {},
        solutionPath: const [],
        totalRequiredCells: 0,
        walls: const {},
      );
    }

    final content = ZipLevelContentDto.fromJson(remote.content!);
    final rows = content.rows;
    final cols = content.columns;

    if (rows <= 0 || cols <= 0) {
      throw ZipLevelValidationException(
          'Grid dimensions must be positive, got ${rows}x$cols.');
    }

    bool inGrid(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

    // Checkpoints validation
    final sortedCheckpoints = List<ZipCheckpointDto>.from(content.checkpoints)
      ..sort((a, b) => a.number.compareTo(b.number));

    if (sortedCheckpoints.isEmpty) {
      throw const ZipLevelValidationException(
          'Level must have at least one checkpoint.');
    }

    final Map<GridPoint, int> checkpoints = {};
    for (int i = 0; i < sortedCheckpoints.length; i++) {
      final expectedNumber = i + 1;
      final cp = sortedCheckpoints[i];
      if (cp.number != expectedNumber) {
        throw ZipLevelValidationException(
          'Checkpoints must be consecutive numbers starting at 1. Expected $expectedNumber, got ${cp.number}.',
        );
      }
      if (!inGrid(cp.row, cp.col)) {
        throw ZipLevelValidationException(
          'Checkpoint ${cp.number} (${cp.row}, ${cp.col}) is outside grid bounds (${rows}x$cols).',
        );
      }
      final pt = GridPoint(cp.row, cp.col);
      if (checkpoints.containsKey(pt)) {
        throw ZipLevelValidationException(
          'Duplicate checkpoint coordinate at ($pt) for checkpoint ${cp.number}.',
        );
      }
      checkpoints[pt] = cp.number;
    }

    // Walls validation
    final Set<Wall> walls = {};
    for (final w in content.walls) {
      if (!inGrid(w.from.row, w.from.col) || !inGrid(w.to.row, w.to.col)) {
        throw const ZipLevelValidationException(
            'Wall endpoints must be within grid bounds.');
      }
      final p1 = GridPoint(w.from.row, w.from.col);
      final p2 = GridPoint(w.to.row, w.to.col);
      if (p1 == p2) {
        throw const ZipLevelValidationException(
            'Wall cannot connect a cell to itself.');
      }
      if (!p1.isAdjacent(p2)) {
        throw ZipLevelValidationException(
          'Wall must be between orthogonally adjacent cells: $p1 and $p2 are not adjacent.',
        );
      }
      walls.add(Wall(p1, p2));
    }

    // Solution path validation
    final totalCells = rows * cols;
    if (content.solutionPath.length != totalCells) {
      throw ZipLevelValidationException(
        'Solution path length (${content.solutionPath.length}) must equal total cells ($totalCells).',
      );
    }

    final List<GridPoint> solutionPath = [];
    final Set<GridPoint> visited = {};
    int nextExpectedCheckpoint = 1;

    for (int i = 0; i < content.solutionPath.length; i++) {
      final step = content.solutionPath[i];
      if (!inGrid(step.row, step.col)) {
        throw ZipLevelValidationException(
            'Solution step $i ($step) is outside grid bounds.');
      }
      final pt = GridPoint(step.row, step.col);
      if (!visited.add(pt)) {
        throw ZipLevelValidationException(
            'Solution path contains duplicate cell $pt at step $i.');
      }

      if (i > 0) {
        final prev = solutionPath[i - 1];
        if (!prev.isAdjacent(pt)) {
          throw ZipLevelValidationException(
            'Solution step $i ($pt) is not orthogonally adjacent to step ${i - 1} ($prev).',
          );
        }
        for (final wall in walls) {
          if (wall.blocks(prev, pt)) {
            throw ZipLevelValidationException(
              'Solution path crosses wall between $prev and $pt at step $i.',
            );
          }
        }
      }

      // Checkpoint sequence check
      final cpNum = checkpoints[pt];
      if (cpNum != null) {
        if (cpNum != nextExpectedCheckpoint) {
          throw ZipLevelValidationException(
            'Solution visits checkpoint $cpNum out of order at step $i. Expected checkpoint $nextExpectedCheckpoint.',
          );
        }
        nextExpectedCheckpoint++;
      }

      solutionPath.add(pt);
    }

    if (nextExpectedCheckpoint - 1 != checkpoints.length) {
      throw ZipLevelValidationException(
        'Solution did not visit all checkpoints. Expected ${checkpoints.length}, visited ${nextExpectedCheckpoint - 1}.',
      );
    }

    if (checkpoints[solutionPath.first] != 1) {
      throw const ZipLevelValidationException(
        'Solution path must start at checkpoint 1.',
      );
    }

    if (checkpoints[solutionPath.last] != checkpoints.length) {
      throw ZipLevelValidationException(
        'The final checkpoint (${checkpoints.length}) must be at the end of the solution path '
        'so that reaching the final digit leaves no untraced blocks.',
      );
    }

    final diff = _parseDifficulty(remote.difficulty, remote.levelNumber);

    return LevelDefinition(
      levelNumber: remote.levelNumber,
      levelId: remote.levelId,
      title: remote.title,
      difficulty: diff,
      checkpointCount: checkpoints.length,
      rows: rows,
      cols: cols,
      checkpoints: checkpoints,
      solutionPath: solutionPath,
      totalRequiredCells: totalCells,
      walls: walls,
      logoUrl: remote.logoUrl,
    );
  }

  static ZipDifficulty _parseDifficulty(String diffStr, int levelNumber) {
    try {
      return ZipDifficulty.fromString(diffStr);
    } catch (_) {
      return ZipDifficulty.fromLevelNumber(levelNumber);
    }
  }
}
