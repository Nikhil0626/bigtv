import 'package:flutter/foundation.dart';
import '../../data/models/level_definition.dart';
import '../../data/models/level_progress.dart';
import '../../data/repositories/zip_catalog.dart';
import '../../data/repositories/zip_puzzle_repository.dart';

class ZipCatalogProvider extends ChangeNotifier {
  final ZipPuzzleRepository _repository;

  Map<int, LevelProgress> _progressMap = {};
  int _highestUnlockedLevel = 1;
  ZipDifficulty? _selectedDifficultyFilter;
  bool _isLoading = true;

  ZipCatalogProvider({ZipPuzzleRepository? repository})
      : _repository = repository ?? ZipPuzzleRepository() {
    loadProgress();
  }

  bool get isLoading => _isLoading;
  int get highestUnlockedLevel => _highestUnlockedLevel;
  ZipDifficulty? get selectedDifficultyFilter => _selectedDifficultyFilter;
  int get totalLevels => ZipCatalog.totalLevels;

  List<LevelDefinition> get allLevels => ZipCatalog.allLevels;

  List<LevelDefinition> get filteredLevels {
    if (_selectedDifficultyFilter == null) {
      return ZipCatalog.allLevels;
    }
    return ZipCatalog.allLevels
        .where((l) => l.difficulty == _selectedDifficultyFilter)
        .toList();
  }

  int get completedCount {
    return _progressMap.values.where((p) => p.isCompleted).length;
  }

  double get progressFraction {
    if (totalLevels == 0) return 0.0;
    return (completedCount / totalLevels).clamp(0.0, 1.0);
  }

  LevelProgress getProgress(int level) {
    return _progressMap[level] ??
        LevelProgress(
          levelNumber: level,
          isUnlocked: level <= _highestUnlockedLevel,
        );
  }

  bool isUnlocked(int level) {
    return level <= _highestUnlockedLevel ||
        (_progressMap[level]?.isUnlocked ?? false);
  }

  bool isCompleted(int level) {
    return _progressMap[level]?.isCompleted ?? false;
  }

  void setFilter(ZipDifficulty? difficulty) {
    _selectedDifficultyFilter = difficulty;
    notifyListeners();
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    _highestUnlockedLevel = await _repository.getHighestUnlockedLevel();
    _progressMap = await _repository.getAllLevelProgress();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _highestUnlockedLevel = await _repository.getHighestUnlockedLevel();
    _progressMap = await _repository.getAllLevelProgress();
    notifyListeners();
  }
}
