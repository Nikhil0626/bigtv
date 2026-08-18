import 'dart:developer';

import 'package:chotanews/features/home/data/repositories/home_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EpaperProvider extends ChangeNotifier {
  List<dynamic> allEpapers = [];
  List<dynamic> epapers = [];
  bool isLoading = false;
  
  String? selectedEdition;
  DateTime? selectedDate;

  // Detail screen state
  int currentPage = 0;
  bool showOverlay = true;

  void setCurrentPage(int index) {
    currentPage = index;
    notifyListeners();
  }

  void toggleOverlay() {
    showOverlay = !showOverlay;
    notifyListeners();
  }

  void resetDetailState() {
    currentPage = 0;
    showOverlay = true;
  }

  Future<void> fetchEpapers() async {
    isLoading = true;
    notifyListeners();

    try {
      Response response = await HomeRepo().getEpapers({
        "skip": 0,
        "limit": 100,
      });

      if (response.statusCode == 200) {
        if (response.data is List) {
          allEpapers = response.data;
          applyFilters();
        } else {
          allEpapers = [];
          epapers = [];
        }
      }
    } on DioException catch (e, st) {
      log("fetchEpapers DioException: $e", stackTrace: st);
    } catch (e, st) {
      log("fetchEpapers Error: $e", stackTrace: st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<String> getAvailableEditions() {
    final editions = allEpapers
        .map((e) => e['editionName'] as String?)
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    editions.sort();
    return editions;
  }
  
  void setEditionFilter(String? edition) {
    selectedEdition = edition;
    applyFilters();
    notifyListeners();
  }
  
  void setDateFilter(DateTime? date) {
    selectedDate = date;
    applyFilters();
    notifyListeners();
  }
  
  void clearFilters() {
    selectedEdition = null;
    selectedDate = null;
    applyFilters();
    notifyListeners();
  }

  void applyFilters() {
    epapers = allEpapers.where((epaper) {
      bool matchesEdition = true;
      bool matchesDate = true;
      
      if (selectedEdition != null) {
        matchesEdition = epaper['editionName'] == selectedEdition;
      }
      
      if (selectedDate != null) {
        final publishDateStr = epaper['publishDate'] as String?;
        if (publishDateStr != null && publishDateStr.isNotEmpty) {
           final selectedDateStr = "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
           matchesDate = publishDateStr.startsWith(selectedDateStr);
        } else {
           matchesDate = false;
        }
      }
      
      return matchesEdition && matchesDate;
    }).toList();
  }
}
