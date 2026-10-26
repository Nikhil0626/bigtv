import 'package:flutter/material.dart';

class SudokuLevel {
  final String levelId;
  final int levelNumber;
  final String difficulty;
  final int rows;
  final int columns;
  final int boxRows;
  final int boxCols;
  final List<List<int>> initialGrid;
  final List<List<int>> solution;
  final SudokuPalette palette;

  SudokuLevel({
    required this.levelId,
    required this.levelNumber,
    required this.difficulty,
    required this.rows,
    required this.columns,
    required this.boxRows,
    required this.boxCols,
    required this.initialGrid,
    required this.solution,
    required this.palette,
  });

  factory SudokuLevel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] is Map<String, dynamic>
        ? json['content'] as Map<String, dynamic>
        : (json['content'] != null ? Map<String, dynamic>.from(json['content']) : json);

    final grid = content['grid'] is Map<String, dynamic>
        ? content['grid'] as Map<String, dynamic>
        : (content['grid'] != null ? Map<String, dynamic>.from(content['grid']) : {'rows': 6, 'columns': 6});

    final rows = (grid['rows'] as num?)?.toInt() ?? 6;
    final columns = (grid['columns'] as num?)?.toInt() ?? 6;

    // 6x6 uses 2x3 blocks, 9x9 uses 3x3 blocks, 4x4 uses 2x2 blocks
    final boxRows = rows == 6 ? 2 : (rows == 4 ? 2 : 3);
    final boxCols = rows == 6 ? 3 : (rows == 4 ? 2 : 3);

    final rawInitial = content['initialGrid'] as List? ?? [];
    final rawSolution = content['solution'] as List? ?? [];

    return SudokuLevel(
      levelId: json['levelId']?.toString() ?? 'sudoku_01',
      levelNumber: (json['levelNumber'] as num?)?.toInt() ?? 1,
      difficulty: json['difficulty']?.toString() ?? 'easy',
      rows: rows,
      columns: columns,
      boxRows: boxRows,
      boxCols: boxCols,
      initialGrid: rawInitial
          .map((row) => (row as List).map((c) => (c as num).toInt()).toList())
          .toList(),
      solution: rawSolution
          .map((row) => (row as List).map((c) => (c as num).toInt()).toList())
          .toList(),
      palette: SudokuPalette.fromJson(
        content['palette'] != null ? Map<String, dynamic>.from(content['palette']) : {},
      ),
    );
  }
}

class SudokuPalette {
  final Color gridBorder;
  final Color blockBorder;
  final Color cellBackground;
  final Color selectedCell;
  final Color highlightNumber;
  final Color clueText;
  final Color userText;

  SudokuPalette({
    required this.gridBorder,
    required this.blockBorder,
    required this.cellBackground,
    required this.selectedCell,
    required this.highlightNumber,
    required this.clueText,
    required this.userText,
  });

  factory SudokuPalette.fromJson(Map<String, dynamic> json) {
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

    return SudokuPalette(
      gridBorder: parseHex(json['gridBorder']?.toString(), const Color(0xFFBDC3C7)),
      blockBorder: parseHex(json['blockBorder']?.toString(), const Color(0xFF1A252F)),
      cellBackground: parseHex(json['cellBackground']?.toString(), Colors.white),
      selectedCell: parseHex(json['selectedCell']?.toString(), const Color(0xFFD6EAF8)),
      highlightNumber: parseHex(json['highlightNumber']?.toString(), const Color(0xFFAED6F1)),
      clueText: parseHex(json['clueText']?.toString(), const Color(0xFF1B2631)),
      userText: parseHex(json['userText']?.toString(), const Color(0xFF2980B9)),
    );
  }
}
