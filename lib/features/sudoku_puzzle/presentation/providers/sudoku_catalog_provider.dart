import 'package:flutter/foundation.dart';
import '../../data/models/sudoku_level_definition.dart';
import '../../data/models/sudoku_level_progress.dart';
import '../../data/repositories/sudoku_catalog.dart';
import '../../data/repositories/sudoku_puzzle_repository.dart';

class SudokuCatalogProvider extends ChangeNotifier {
  final SudokuPuzzleRepository _repository;
  bool _isLoading = true;
  Map<int, SudokuLevelProgress> _progressMap = {};

  SudokuCatalogProvider({SudokuPuzzleRepository? repository})
      : _repository = repository ?? SudokuPuzzleRepository() {
    loadCatalog();
  }

  bool get isLoading => _isLoading;
  List<SudokuLevelDefinition> get allLevels => SudokuCatalog.allLevels;
  Map<int, SudokuLevelProgress> get progressMap => _progressMap;

  int get totalCompleted =>
      _progressMap.values.where((p) => p.isCompleted).length;

  int get totalStars =>
      _progressMap.values.fold(0, (sum, p) => sum + p.stars);

  SudokuLevelProgress getProgress(int levelNumber) {
    return _progressMap[levelNumber] ??
        SudokuLevelProgress(
          levelNumber: levelNumber,
          isUnlocked: levelNumber == 1,
          isCompleted: false,
        );
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    notifyListeners();
    try {
      _progressMap = await _repository.getAllProgress();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadCatalog();
}
