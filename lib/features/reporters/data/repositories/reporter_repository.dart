import 'dart:developer';
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';
import '../models/reporter_model.dart';

class ReporterRepository extends BaseService {
  Future<List<ReporterModel>> getReporters() async {
    try {
      Response response = await makeRequest(
        baseUrl: BaseUrls.newServerBaseUrl,
        url: BaseUrls.getReportersApi,
        method: RequestType.get,
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic responseData = response.data;
        List rawList = [];

        if (responseData is Map && responseData['data'] is List) {
          rawList = responseData['data'] as List;
        } else if (responseData is List) {
          rawList = responseData;
        }

        log("Fetched ${rawList.length} reporters from pravasamedia API");
        return rawList
            .map((e) => ReporterModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e, st) {
      log('Error in ReporterRepository.getReporters: $e\n$st');
    }
    return [];
  }
}
