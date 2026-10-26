import 'package:flutter/material.dart';
import 'grid_point.dart';
import 'wall.dart';

enum ZipDifficulty {
  easy,
  medium,
  hard,
  expert;

  String get displayName {
    switch (this) {
      case ZipDifficulty.easy:
        return 'Easy';
      case ZipDifficulty.medium:
        return 'Medium';
      case ZipDifficulty.hard:
        return 'Hard';
      case ZipDifficulty.expert:
        return 'Expert';
    }
  }

  Color get accentColor {
    switch (this) {
      case ZipDifficulty.easy:
        return const Color(0xFF10B981);
      case ZipDifficulty.medium:
        return const Color(0xFF3B82F6);
      case ZipDifficulty.hard:
        return const Color(0xFFF59E0B);
      case ZipDifficulty.expert:
        return const Color(0xFFEF4444);
    }
  }

  static ZipDifficulty fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'easy':
        return ZipDifficulty.easy;
      case 'medium':
        return ZipDifficulty.medium;
      case 'hard':
        return ZipDifficulty.hard;
      case 'expert':
        return ZipDifficulty.expert;
      default:
        throw FormatException('Unknown difficulty: "$val"');
    }
  }

  static ZipDifficulty fromLevelNumber(int level) {
    if (level <= 20) return ZipDifficulty.easy;
    if (level <= 50) return ZipDifficulty.medium;
    if (level <= 80) return ZipDifficulty.hard;
    return ZipDifficulty.expert;
  }
}

class LevelDefinition {
  final int levelNumber;
  final String? levelId;
  final String? title;
  final ZipDifficulty difficulty;
  final int checkpointCount;
  final int rows;
  final int cols;
  final Map<GridPoint, int> checkpoints;
  final List<GridPoint> solutionPath;
  final int totalRequiredCells;
  final Set<Wall> walls;
  final String? logoUrl;

  const LevelDefinition({
    required this.levelNumber,
    this.levelId,
    this.title,
    required this.difficulty,
    required this.checkpointCount,
    required this.rows,
    required this.cols,
    required this.checkpoints,
    required this.solutionPath,
    required this.totalRequiredCells,
    this.walls = const {},
    this.logoUrl,
  });

  String get id => levelId ?? 'zip_${levelNumber.toString().padLeft(3, '0')}';

  LevelDefinition copyWith({
    int? levelNumber,
    String? levelId,
    String? title,
    ZipDifficulty? difficulty,
    int? checkpointCount,
    int? rows,
    int? cols,
    Map<GridPoint, int>? checkpoints,
    List<GridPoint>? solutionPath,
    int? totalRequiredCells,
    Set<Wall>? walls,
    String? logoUrl,
  }) {
    return LevelDefinition(
      levelNumber: levelNumber ?? this.levelNumber,
      levelId: levelId ?? this.levelId,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      checkpointCount: checkpointCount ?? this.checkpointCount,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      checkpoints: checkpoints ?? this.checkpoints,
      solutionPath: solutionPath ?? this.solutionPath,
      totalRequiredCells: totalRequiredCells ?? this.totalRequiredCells,
      walls: walls ?? this.walls,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  int? getCheckpointNumber(GridPoint point) => checkpoints[point];

  bool isCheckpoint(GridPoint point) => checkpoints.containsKey(point);

  GridPoint? getCheckpointPoint(int number) {
    for (final entry in checkpoints.entries) {
      if (entry.value == number) return entry.key;
    }
    return null;
  }

  bool hasWall(GridPoint p1, GridPoint p2) {
    if (walls.isEmpty) return false;
    for (final wall in walls) {
      if (wall.blocks(p1, p2)) return true;
    }
    return false;
  }

  static const List<ZipColorTheme> palette = [
    ZipColorTheme(
      name: 'Forest Green',
      pathColor: Color(0xFF0F8A4B),
      cellTintColor: Color(0xFFD3EBE0),
    ),
    ZipColorTheme(
      name: 'Terracotta Orange',
      pathColor: Color(0xFFD96327),
      cellTintColor: Color(0xFFFBE4DA),
    ),
    ZipColorTheme(
      name: 'Royal Cobalt',
      pathColor: Color(0xFF1E60D4),
      cellTintColor: Color(0xFFDDE7FD),
    ),
    ZipColorTheme(
      name: 'Rich Violet',
      pathColor: Color(0xFF7C3AED),
      cellTintColor: Color(0xFFEDE9FE),
    ),
    ZipColorTheme(
      name: 'Ocean Teal',
      pathColor: Color(0xFF0D828A),
      cellTintColor: Color(0xFFD6EFF0),
    ),
    ZipColorTheme(
      name: 'Berry Crimson',
      pathColor: Color(0xFFD92D5B),
      cellTintColor: Color(0xFFFDE8EF),
    ),
    ZipColorTheme(
      name: 'Amber Gold',
      pathColor: Color(0xFFD97706),
      cellTintColor: Color(0xFFFEF3C7),
    ),
    ZipColorTheme(
      name: 'Electric Cyan',
      pathColor: Color(0xFF0284C7),
      cellTintColor: Color(0xFFE0F2FE),
    ),
    ZipColorTheme(
      name: 'Rose Coral',
      pathColor: Color(0xFFE11D48),
      cellTintColor: Color(0xFFFFE4E6),
    ),
    ZipColorTheme(
      name: 'Deep Indigo',
      pathColor: Color(0xFF4F46E5),
      cellTintColor: Color(0xFFE0E7FF),
    ),
    ZipColorTheme(
      name: 'Emerald Mint',
      pathColor: Color(0xFF059669),
      cellTintColor: Color(0xFFD1FAE5),
    ),
    ZipColorTheme(
      name: 'Plum Magenta',
      pathColor: Color(0xFF9333EA),
      cellTintColor: Color(0xFFF3E8FF),
    ),
  ];

  Color get pathColor => palette[(levelNumber - 1) % palette.length].pathColor;

  Color get cellTintColor =>
      palette[(levelNumber - 1) % palette.length].cellTintColor;
}

class ZipColorTheme {
  final String name;
  final Color pathColor;
  final Color cellTintColor;

  const ZipColorTheme({
    required this.name,
    required this.pathColor,
    required this.cellTintColor,
  });
}
