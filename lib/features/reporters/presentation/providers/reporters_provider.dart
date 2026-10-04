import 'package:flutter/material.dart';
import '../../data/models/reporter_model.dart';
import '../../data/repositories/reporter_repository.dart';

class ReportersProvider extends ChangeNotifier {
  final ReporterRepository _repository = ReporterRepository();

  List<ReporterModel> _allReporters = [];
  bool _isLoading = false;
  String _selectedStateFilter = 'All';
  String _searchQuery = '';

  List<ReporterModel> get allReporters => _allReporters;
  bool get isLoading => _isLoading;
  String get selectedStateFilter => _selectedStateFilter;
  String get searchQuery => _searchQuery;

  List<String> get availableFilters => ['All', 'Telangana', 'Andhra Pradesh'];

  List<ReporterModel> get filteredReporters {
    return _allReporters.where((reporter) {
      // Filter by state chip
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

      return matchesState && matchesQuery;
    }).toList();
  }

  ReportersProvider() {
    loadReporters();
  }

  Future<void> loadReporters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allReporters = await _repository.getReporters();
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
