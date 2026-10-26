import 'package:flutter/material.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import '../../data/models/patches_level_definition.dart';
import '../../data/models/patches_level_progress.dart';
import '../../data/repositories/patches_catalog.dart';
import '../../data/repositories/patches_puzzle_repository.dart';

class PatchesCatalogProvider extends ChangeNotifier {
  final PatchesPuzzleRepository _repository;

  Map<int, PatchesLevelProgress> _progressMap = {};
  ZipDifficulty? _selectedDifficultyFilter;
  bool _isLoading = true;

  PatchesCatalogProvider({PatchesPuzzleRepository? repository})
      : _repository = repository ?? PatchesPuzzleRepository() {
    loadProgress();
  }

  bool get isLoading => _isLoading;
  ZipDifficulty? get selectedDifficultyFilter => _selectedDifficultyFilter;
  Map<int, PatchesLevelProgress> get progressMap => _progressMap;

  List<PatchesLevelDefinition> get allLevels => PatchesCatalog.allLevels;

  List<PatchesLevelDefinition> get filteredLevels {
    if (_selectedDifficultyFilter == null) {
      return allLevels;
    }
    return allLevels
        .where((l) => l.difficulty == _selectedDifficultyFilter)
        .toList();
  }

  PatchesLevelProgress getProgress(int levelNumber) {
    return _progressMap[levelNumber] ??
        PatchesLevelProgress(
          levelNumber: levelNumber,
          isUnlocked: levelNumber == 1,
        );
  }

  int get solvedCount {
    return _progressMap.values.where((p) => p.isCompleted).length;
  }

  int get highestUnlockedLevel {
    int maxUnlocked = 1;
    for (final p in _progressMap.values) {
      if (p.isUnlocked && p.levelNumber > maxUnlocked) {
        maxUnlocked = p.levelNumber;
      }
    }
    return maxUnlocked;
  }

  double get progressFraction =>
      (solvedCount / PatchesCatalog.totalLevels).clamp(0.0, 1.0);

  void setFilter(ZipDifficulty? difficulty) {
    if (_selectedDifficultyFilter != difficulty) {
      _selectedDifficultyFilter = difficulty;
      notifyListeners();
    }
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();
    _progressMap = await _repository.getAllLevelProgress();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _progressMap = await _repository.getAllLevelProgress();
    notifyListeners();
  }
}
