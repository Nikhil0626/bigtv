
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../services/base_service.dart';
import '../../../services/base_urls.dart';
import '../../../utils/app_enums.dart';

class ContestRepo extends BaseService {


  Future<Response> getContestList(userId) async {
    Response response = await makeRequest(
        baseUrl: BaseUrls.baseUrlAwsDev,
        url: "${BaseUrls.adContestClick}$userId",
        method: RequestType.get
    );
    log(response.toString());
    return response;
  }
}