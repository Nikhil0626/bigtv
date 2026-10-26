import 'package:flutter/material.dart';

class PatchClueData {
  final int row;
  final int col;
  final String shape; // 'wide', 'sq', 'tall', 'any'
  final int value;

  const PatchClueData({
    required this.row,
    required this.col,
    required this.shape,
    required this.value,
  });

  factory PatchClueData.fromJson(Map<String, dynamic> json) {
    return PatchClueData(
      row: (json['row'] as num?)?.toInt() ?? 0,
      col: (json['col'] as num?)?.toInt() ?? 0,
      shape: (json['shape'] ?? 'any').toString(),
      value: (json['value'] as num?)?.toInt() ?? 0,
    );
  }
}

class PatchSolutionPiece {
  final String pieceId;
  final int width;
  final int height;
  final String shape;
  final PatchCoord anchor;
  final List<PatchCoord> cells;

  const PatchSolutionPiece({
    required this.pieceId,
    required this.width,
    required this.height,
    required this.shape,
    required this.anchor,
    required this.cells,
  });

  factory PatchSolutionPiece.fromJson(Map<String, dynamic> json) {
    final rawAnchor = json['anchor'] as Map<String, dynamic>? ?? {};
    final rawCells = json['cells'] as List? ?? [];
    return PatchSolutionPiece(
      pieceId: (json['pieceId'] ?? json['id'] ?? '').toString(),
      width: (json['w'] as num?)?.toInt() ?? 1,
      height: (json['h'] as num?)?.toInt() ?? 1,
      shape: (json['shape'] ?? '').toString(),
      anchor: PatchCoord(
        row: (rawAnchor['row'] as num?)?.toInt() ?? 0,
        col: (rawAnchor['col'] as num?)?.toInt() ?? 0,
      ),
      cells: rawCells
          .map((c) => PatchCoord(
                row: (c['row'] ?? c['r'] as num?)?.toInt() ?? 0,
                col: (c['col'] ?? c['c'] as num?)?.toInt() ?? 0,
              ))
          .toList(),
    );
  }
}

class PatchLevel {
  final String levelId;
  final int levelNumber;
  final String difficulty;
  final int rows;
  final int columns;
  final List<PatchPiece> pieces;
  final List<PatchClueData> clues;
  final List<PatchSolutionPiece> solution;
  final Color gridBorder;
  final Color boardBackground;

  PatchLevel({
    required this.levelId,
    required this.levelNumber,
    required this.difficulty,
    required this.rows,
    required this.columns,
    required this.pieces,
    this.clues = const [],
    this.solution = const [],
    required this.gridBorder,
    required this.boardBackground,
  });

  PatchClueData? getClueAt(int row, int col) {
    for (final clue in clues) {
      if (clue.row == row && clue.col == col) return clue;
    }
    return null;
  }

  factory PatchLevel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] is Map<String, dynamic>
        ? json['content'] as Map<String, dynamic>
        : (json['content'] != null ? Map<String, dynamic>.from(json['content']) : json);

    final grid = content['grid'] is Map<String, dynamic>
        ? content['grid'] as Map<String, dynamic>
        : (content['grid'] != null ? Map<String, dynamic>.from(content['grid']) : {'rows': 5, 'columns': 5});

    final palette = content['palette'] != null ? Map<String, dynamic>.from(content['palette']) : {};

    Color parseHex(String? hex, Color fallback) {
      if (hex == null || !hex.startsWith('#')) return fallback;
      try {
        final clean = hex.replaceFirst('#', '');
        if (clean.length == 6) {
          return Color(int.parse('0xFF$clean'));
        } else if (clean.length == 8) {
          return Color(int.parse('0x$clean'));
        }
      } catch (_) {}
      return fallback;
    }

    final rawPieces = content['pieces'] as List? ?? [];
    final rawClues = content['clues'] as List? ?? [];
    final rawSolution = content['solution'] as List? ?? [];

    return PatchLevel(
      levelId: json['levelId']?.toString() ?? 'patch_01',
      levelNumber: (json['levelNumber'] as num?)?.toInt() ?? 1,
      difficulty: json['difficulty']?.toString() ?? 'easy',
      rows: (grid['rows'] as num?)?.toInt() ?? 5,
      columns: (grid['columns'] as num?)?.toInt() ?? 5,
      pieces: rawPieces
          .map((p) => PatchPiece.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
      clues: rawClues
          .map((c) => PatchClueData.fromJson(Map<String, dynamic>.from(c)))
          .toList(),
      solution: rawSolution
          .map((s) => PatchSolutionPiece.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
      gridBorder: parseHex(palette['gridBorder']?.toString(), const Color(0xFFBDC3C7)),
      boardBackground: parseHex(palette['boardBackground']?.toString(), const Color(0xFFF4F6F7)),
    );
  }
}

class PatchPiece {
  final String id;
  final Color color;
  final List<PatchCoord> cells;
  final int width;
  final int height;

  PatchPiece({
    required this.id,
    required this.color,
    required this.cells,
    int? width,
    int? height,
  })  : width = width ?? _computeWidth(cells),
        height = height ?? _computeHeight(cells);

  static int _computeWidth(List<PatchCoord> cells) {
    if (cells.isEmpty) return 1;
    final maxC = cells.map((c) => c.col).reduce((a, b) => a > b ? a : b);
    return maxC + 1;
  }

  static int _computeHeight(List<PatchCoord> cells) {
    if (cells.isEmpty) return 1;
    final maxR = cells.map((c) => c.row).reduce((a, b) => a > b ? a : b);
    return maxR + 1;
  }

  factory PatchPiece.fromJson(Map<String, dynamic> json) {
    Color parseHex(String? hex) {
      if (hex == null || !hex.startsWith('#')) return const Color(0xFF3498DB);
      try {
        final clean = hex.replaceFirst('#', '');
        if (clean.length == 6) {
          return Color(int.parse('0xFF$clean'));
        } else if (clean.length == 8) {
          return Color(int.parse('0x$clean'));
        }
      } catch (_) {}
      return const Color(0xFF3498DB);
    }

    final rawCells = json['cells'] as List? ?? [];
    final cells = rawCells
        .map((c) => PatchCoord(
              row: (c['row'] ?? c['r'] as num?)?.toInt() ?? 0,
              col: (c['col'] ?? c['c'] as num?)?.toInt() ?? 0,
            ))
        .toList();

    return PatchPiece(
      id: json['id']?.toString() ?? 'p',
      color: parseHex(json['color']?.toString()),
      cells: cells,
      width: (json['w'] as num?)?.toInt(),
      height: (json['h'] as num?)?.toInt(),
    );
  }
}

class PatchCoord {
  final int row;
  final int col;
  PatchCoord({required this.row, required this.col});
}

class PlacedPatch {
  final String id;
  final int minRow;
  final int maxRow;
  final int minCol;
  final int maxCol;
  final Color color;
  final int clueValue;
  final int clueRow;
  final int clueCol;

  const PlacedPatch({
    required this.id,
    required this.minRow,
    required this.maxRow,
    required this.minCol,
    required this.maxCol,
    required this.color,
    required this.clueValue,
    required this.clueRow,
    required this.clueCol,
  });

  int get width => maxCol - minCol + 1;
  int get height => maxRow - minRow + 1;
  int get area => width * height;

  bool contains(int row, int col) {
    return row >= minRow && row <= maxRow && col >= minCol && col <= maxCol;
  }
}
