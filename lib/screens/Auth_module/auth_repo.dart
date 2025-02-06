

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepo extends BaseService{


  Future loginWithGoogle( body) async {
    Response response = await makeRequest(url: BaseUrls.userInfo,method: RequestType.post,body: body);
    return response;
  }

  Future addDeviceDetails( body) async {
    Response response = await makeRequest(url: BaseUrls.addDevice,method: RequestType.post,body: body);
    return response;
  }
  Future sendOtp(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAws,url: BaseUrls.sendOtp,method: RequestType.post,body: body);
    return response;
  } Future validateOtp(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAws,url: BaseUrls.validateOtp,method: RequestType.post,body: body);
    return response;
  }

}