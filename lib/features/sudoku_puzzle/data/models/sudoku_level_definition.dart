import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';

class SudokuLevelDefinition {
  final int levelNumber;
  final ZipDifficulty difficulty;
  final List<List<int>> initialGrid;
  final List<List<int>> solutionGrid;

  const SudokuLevelDefinition({
    required this.levelNumber,
    required this.difficulty,
    required this.initialGrid,
    required this.solutionGrid,
  });

  int get size => initialGrid.length;

  bool isGiven(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= initialGrid[0].length) {
      return false;
    }
    return initialGrid[row][col] != 0;
  }

  int get givensCount {
    int count = 0;
    for (final row in initialGrid) {
      for (final cell in row) {
        if (cell != 0) count++;
      }
    }
    return count;
  }
}
