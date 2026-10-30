import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/reporter_model.dart';
import '../../data/repositories/reporter_repository.dart';

class ReportersProvider extends ChangeNotifier {
  final ReporterRepository _repository = ReporterRepository();

  List<ReporterModel> _allReporters = [];
  bool _isLoading = false;
  String _selectedStateFilter = 'All';
  String _searchQuery = '';
  String _currentLanguage = 'te';

  List<ReporterModel> get allReporters => _allReporters;
  bool get isLoading => _isLoading;
  String get selectedStateFilter => _selectedStateFilter;
  String get searchQuery => _searchQuery;
  String get currentLanguage => _currentLanguage;

  List<String> get availableFilters {
    if (_currentLanguage == 'ml') {
      return const [];
    }
    return ['All', 'Telangana', 'Andhra Pradesh'];
  }

  List<ReporterModel> get filteredReporters {
    return _allReporters.where((reporter) {
      // Filter by state chip (only for Telugu, no districts/states for Malayalam)
      if (_currentLanguage != 'ml') {
        bool matchesState = _selectedStateFilter == 'All';
        if (!matchesState) {
          final filterLower = _selectedStateFilter.toLowerCase();
          final repStateLower = reporter.state.toLowerCase();

          if (repStateLower == filterLower) {
            matchesState = true;
          } else if (filterLower == 'andhra pradesh' && (repStateLower == 'ap' || repStateLower.contains('andhra'))) {
            matchesState = true;
          } else if (filterLower == 'telangana' && (repStateLower == 'ts' || repStateLower.contains('telangana'))) {
            matchesState = true;
          }
        }
        if (!matchesState) return false;
      }

      // Filter by search query (matches name, title, location, state, bureau, or media channel)
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          reporter.name.toLowerCase().contains(query) ||
          reporter.title.toLowerCase().contains(query) ||
          reporter.location.toLowerCase().contains(query) ||
          reporter.state.toLowerCase().contains(query) ||
          reporter.category.toLowerCase().contains(query) ||
          reporter.bureau.toLowerCase().contains(query) ||
          reporter.mediaChannelName.toLowerCase().contains(query);

      return matchesQuery;
    }).toList();
  }

  ReportersProvider() {
    loadReporters();
  }

  Future<void> loadReporters({String? languageCode, bool force = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lang = languageCode ?? prefs.getString("selectedLanguageCode") ?? "te";
    final targetLang = (lang == 'ml') ? 'ml' : 'te';

    if (!force && _allReporters.isNotEmpty && _currentLanguage == targetLang) {
      return;
    }

    _currentLanguage = targetLang;
    _isLoading = true;
    _selectedStateFilter = 'All';
    notifyListeners();

    final Map<String, dynamic> queryParams = {
      'language': targetLang,
      'lan': targetLang,
      'lang': targetLang,
    };

    try {
      final rawReporters = await _repository.getReporters(queryParams);
      _allReporters = rawReporters.where((reporter) {
        // If reporter has language metadata, verify it matches
        if (reporter.language.isNotEmpty) {
          return reporter.language == targetLang;
        }
        if (reporter.lan.isNotEmpty) {
          return reporter.lan == targetLang;
        }
        if (reporter.languages.isNotEmpty) {
          return reporter.languages.contains(targetLang);
        }
        // If no language metadata specified on reporter:
        // If targetLang is 'te', include legacy reporters
        return targetLang == 'te';
      }).toList();
    } catch (e) {
      debugPrint('Error loading reporters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStateFilter(String state) {
    if (_selectedStateFilter != state) {
      _selectedStateFilter = state;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
