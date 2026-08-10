import 'package:flutter/material.dart';

class AdLatencyData {
  DateTime? requestInitiated;
  DateTime? responseReceived;
  DateTime? adCreativeDownloaded;
  DateTime? adRendered;
}

class AdMobBannerProvider with ChangeNotifier {
  final Map<int, dynamic> ads = {};
  final Map<int, dynamic> adsBanner320x50 = {};
  final Map<int, bool> adsLoaded = {};
  final Map<int, bool> adsLoaded320x50 = {};
  final Map<int, AdLatencyData> adLatencyData = {};
  final Map<int, String> adErrors = {};
  final Map<int, String> adErrors320x50 = {};

  int currentPageIndex = 0;
  String? source = "";

  void changePageIndex(int val) {
    currentPageIndex = val;
    notifyListeners();
  }

  void adsDispose() {}
  void adsLoad() {}

  Future<void> loadAdMobNative(int index, dynamic mediumRectangle) async {}
  Future<void> loadAdManagerNative(int index, dynamic size) async {}
  Future<void> loadAdMobBanner(int index, dynamic size) async {}
  Future<void> loadAdManagerBanner(int index, dynamic size) async {}
  Future<void> loadAd320x50ManagerBanner(int index, dynamic size) async {}
}
