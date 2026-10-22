import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import 'drawn_patch.dart';
import 'patch_clue.dart';

class PatchesLevelDefinition {
  final int levelNumber;
  final ZipDifficulty difficulty;
  final int rows;
  final int cols;
  final List<PatchClue> clues;
  final List<DrawnPatch> solutionPatches;

  const PatchesLevelDefinition({
    required this.levelNumber,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.clues,
    required this.solutionPatches,
  });

  int get totalCells => rows * cols;

  PatchClue? getClueAt(GridPoint pt) {
    for (final clue in clues) {
      if (clue.point == pt) return clue;
    }
    return null;
  }

  PatchClue? getClueById(String id) {
    for (final clue in clues) {
      if (clue.id == id) return clue;
    }
    return null;
  }

  PatchesLevelDefinition copyWith({
    int? levelNumber,
    ZipDifficulty? difficulty,
    int? rows,
    int? cols,
    List<PatchClue>? clues,
    List<DrawnPatch>? solutionPatches,
  }) {
    return PatchesLevelDefinition(
      levelNumber: levelNumber ?? this.levelNumber,
      difficulty: difficulty ?? this.difficulty,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      clues: clues ?? this.clues,
      solutionPatches: solutionPatches ?? this.solutionPatches,
    );
  }
}
