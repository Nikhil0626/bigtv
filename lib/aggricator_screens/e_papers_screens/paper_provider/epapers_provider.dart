import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../paper_models/ePaper_main_model.dart';
import '../paper_models/single_paper_model.dart';
import '../paper_repo/epaper_repo.dart';

class EPapersProvider extends ChangeNotifier {
  bool isMainPapers = false;
  List<EPaperMainModel> getAllMainPapersList = [];
  List<SinglePaperModel> getSinglePapersList = [];

  Future getMainEPapers() async {
    isMainPapers = true;

    try {
      Response response = await EPaperRepo().getMainEPapers();
      if (response.statusCode == 200) {
        log(response.data.toString());
        List data = response.data;
        getAllMainPapersList = data.map((e) => EPaperMainModel.fromJson(e)).toList();
      }
    } on DioException catch (e, st) {
      getAllMainPapersList = [];
      log("main epaper dio error ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      getAllMainPapersList = [];
      log("main epaper error ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainPapers = false;
      notifyListeners();
    }
  }

  Future getSingleEPapers(String paper) async {
    isMainPapers = true;
    getSinglePapersList = [];
    try {
      Response response = await EPaperRepo().getSingleEPapers(paper);
      if (response.statusCode == 200) {
        log(response.data.toString());
        List data = response.data;
        getSinglePapersList = data.map((e) => SinglePaperModel.fromJson(e)).toList();
      }
    } on DioException catch (e, st) {
      getAllMainPapersList = [];
      log("Single paper dio error ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      getAllMainPapersList = [];
      log("Single paper error ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainPapers = false;
      notifyListeners();
    }
  }
}
