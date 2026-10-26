import 'dart:developer';
import 'package:flutter/material.dart';
import '../../data/models/app_notification_model.dart';
import '../../data/repositories/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _repository = NotificationsRepository();

  List<AppNotificationModel> _notifications = [];
  List<AppNotificationModel> _filteredNotifications = [];

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _searchQuery = "";
  int _total = 0;
  static const int _pageSize = 20;

  List<AppNotificationModel> get notifications => _notifications;
  List<AppNotificationModel> get filteredNotifications => _filteredNotifications;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get total => _total;

  /// Fetch first page or refresh notifications
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      if (_notifications.isEmpty) {
        _isLoading = true;
      }
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getNotifications(
        skip: 0,
        take: _pageSize,
      );

      _notifications = response.items;
      _total = response.total;
      _hasMore = _notifications.length < _total;
      _applySearchFilter();
      _errorMessage = null;
    } catch (e, st) {
      log("NotificationsProvider.fetchNotifications error: $e", stackTrace: st);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Load next page when user scrolls near the bottom
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _repository.getNotifications(
        skip: _notifications.length,
        take: _pageSize,
      );

      if (response.items.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = _notifications.map((e) => e.id).toSet();
        final newItems =
            response.items.where((e) => !existingIds.contains(e.id)).toList();

        if (newItems.isEmpty) {
          _hasMore = false;
        } else {
          _notifications.addAll(newItems);
          _total = response.total;
          _hasMore = _notifications.length < _total;
        }
        _applySearchFilter();
      }
    } catch (e, st) {
      log("NotificationsProvider.loadMore error: $e", stackTrace: st);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Search across title and content
  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearchFilter();
    notifyListeners();
  }

  /// Clear active search query
  void clearSearch() {
    _searchQuery = "";
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredNotifications = List.from(_notifications);
    } else {
      _filteredNotifications = _notifications.where((n) {
        final title = n.title.toLowerCase();
        final content = n.content.toLowerCase();
        final brand = (n.brandName ?? '').toLowerCase();
        return title.contains(_searchQuery) ||
            content.contains(_searchQuery) ||
            brand.contains(_searchQuery);
      }).toList();
    }
  }
}
