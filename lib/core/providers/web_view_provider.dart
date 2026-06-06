import 'package:flutter/material.dart';

class WebViewProvider with ChangeNotifier {
  int _loadingPercentage = 0;
  String? _pageTitle;

  int get loadingPercentage => _loadingPercentage;
  String? get pageTitle => _pageTitle;

  void updateLoadingPercentage(int percentage) {
    if (_loadingPercentage != percentage) {
      _loadingPercentage = percentage;
      notifyListeners();
    }
  }

  void updatePageTitle(String? title) {
    if (_pageTitle != title) {
      _pageTitle = title;
      notifyListeners();
    }
  }

  void reset() {
    _loadingPercentage = 0;
    _pageTitle = null;
    notifyListeners();
  }
}
