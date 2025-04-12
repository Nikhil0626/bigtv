import 'dart:developer';

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class SettingsRepo  extends BaseService{

  Future bookMarks(Map<String,dynamic>body) async {
    Response response = await makeRequest(url: BaseUrls.getAllBookMarks,baseUrl: BaseUrls.baseUrlAwsDev,queryParameters: body,method:RequestType.get);
    log(response.data.toString());
    return response;
  }

  Future saveBookMarks(Map<String,dynamic>body) async {
    Response response = await makeRequest(url: BaseUrls.getAllBookMarks,baseUrl: BaseUrls.baseUrlAwsDev,body: body,method:RequestType.post);
    log(response.data.toString());
    return response;
  }

  Future liked(Map<String,dynamic>body) async {
    Response response = await makeRequest(url: BaseUrls.like,baseUrl: BaseUrls.baseUrlAwsDev,body: body,method: RequestType.post);
    log(response.data.toString());
    return response;
  }
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