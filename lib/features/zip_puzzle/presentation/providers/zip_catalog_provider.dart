import 'package:flutter/foundation.dart';
import '../../data/mappers/zip_level_definition_mapper.dart';
import '../../data/models/level_definition.dart';
import '../../data/models/level_progress.dart';
import '../../data/models/zip_level_api_model.dart';
import '../../data/repositories/zip_level_api_repository.dart';
import '../../data/repositories/zip_puzzle_repository.dart';

class ZipCatalogProvider extends ChangeNotifier {
  final ZipPuzzleRepository _repository;
  final ZipLevelApiRepository _apiRepository;

  List<LevelDefinition> _levels = [];
  Map<int, LevelProgress> _progressMap = {};
  int _highestUnlockedLevel = 1;
  ZipDifficulty? _selectedDifficultyFilter;
  bool _isLoading = true;
  String? _errorMessage;

  ZipCatalogProvider({
    ZipPuzzleRepository? repository,
    ZipLevelApiRepository? apiRepository,
  })  : _repository = repository ?? ZipPuzzleRepository(),
        _apiRepository = apiRepository ?? ZipLevelApiRepository() {
    loadCatalogAndProgress();
  }

  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  int get highestUnlockedLevel => _highestUnlockedLevel;
  ZipDifficulty? get selectedDifficultyFilter => _selectedDifficultyFilter;
  int get totalLevels => _levels.length;

  List<LevelDefinition> get allLevels => List.unmodifiable(_levels);

  List<LevelDefinition> get filteredLevels {
    if (_selectedDifficultyFilter == null) {
      return List.unmodifiable(_levels);
    }
    return _levels
        .where((l) => l.difficulty == _selectedDifficultyFilter)
        .toList(growable: false);
  }

  int getLevelCount(ZipDifficulty difficulty) {
    return _levels.where((l) => l.difficulty == difficulty).length;
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

  Future<void> loadProgress() => loadCatalogAndProgress();

  Future<void> loadCatalogAndProgress() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<ZipLevelApiModel> allApiItems = [];
      int page = 1;
      const pageSize = 100;
      int? total;

      do {
        final response = await _apiRepository.getCatalogue(
          page: page,
          pageSize: pageSize,
        );
        allApiItems.addAll(response.items);
        total = response.total;
        page++;
      } while (total != null && allApiItems.length < total && page <= 10);

      _levels = allApiItems
          .map((item) => ZipLevelDefinitionMapper.mapApiLevelToDefinition(item))
          .toList();

      _highestUnlockedLevel = await _repository.getHighestUnlockedLevel();
      _progressMap = await _repository.getAllLevelProgress(
        totalLevels: _levels.length,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e is ZipLevelApiException
          ? e.message
          : 'Could not load puzzle levels. Check your connection and retry.';
      _levels = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadCatalogAndProgress();
  }

  Future<void> refreshProgressOnly() async {
    _highestUnlockedLevel = await _repository.getHighestUnlockedLevel();
    _progressMap = await _repository.getAllLevelProgress(
      totalLevels: _levels.length,
    );
    notifyListeners();
  }

  Future<LevelDefinition> getOrFetchLevel(LevelDefinition level) async {
    // If full content is already mapped, return it immediately
    if (level.solutionPath.isNotEmpty && level.rows > 0) {
      return level;
    }

    // Otherwise fetch detail by stable levelId
    final apiModel = await _apiRepository.getLevelById(level.id);
    final fullDefinition =
        ZipLevelDefinitionMapper.mapApiLevelToDefinition(apiModel);

    // Cache the full level in _levels list
    final idx = _levels.indexWhere(
        (l) => l.id == level.id || l.levelNumber == level.levelNumber);
    if (idx != -1) {
      _levels[idx] = fullDefinition;
    }

    return fullDefinition;
  }

  LevelDefinition? getNextLevel(LevelDefinition current) {
    if (_levels.isEmpty) return null;
    final idx = _levels.indexWhere(
        (l) => l.id == current.id || l.levelNumber == current.levelNumber);
    if (idx != -1 && idx + 1 < _levels.length) {
      return _levels[idx + 1];
    }
    // Fallback by levelNumber
    return getLevelByNumber(current.levelNumber + 1);
  }

  LevelDefinition? getLevelByNumber(int number) {
    try {
      return _levels.firstWhere((l) => l.levelNumber == number);
    } catch (_) {
      return null;
    }
  }
}
