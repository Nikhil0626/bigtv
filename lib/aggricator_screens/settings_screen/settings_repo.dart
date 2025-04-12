import 'dart:developer';

import 'package:chotanews/services/base_service.dart';
import 'package:dio/dio.dart';
import '../../../services/base_urls.dart';
import '../../utils/app_enums.dart';

class SettingsRepo extends BaseService{
  Future postFeedBack(body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
        url: BaseUrls.getFeedback, method: RequestType.post, queryParameters: body);
    return response;
  }

  Future getFeedBack(body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
        url: BaseUrls.getFeedback, method: RequestType.get, queryParameters: body);
    return response;
  }

}