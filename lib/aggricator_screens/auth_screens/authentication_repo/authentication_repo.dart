import 'dart:developer';

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class AuthenticationRepo extends BaseService {
  Future sendOtp( body) async {
    Response response = await makeRequest( baseUrl: BaseUrls.baseUrlAwsDev,url: BaseUrls.sendOtpPy, method: RequestType.post, body: body,);
    return response;
  }

  Future sendIOSRef( body) async {
    Response response = await makeRequest( baseUrl: BaseUrls.baseUrlAwsDev,url: BaseUrls.deviceInfoIOS, method: RequestType.post, body: body,);
    return response;
  }

  Future validateOtp(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.validateOtpPy, method: RequestType.post, body: body);

    return response;
  }

  Future getAllCategories(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.getAllCategories, method: RequestType.get, queryParameters: body);
    log(response.data.toString());
    return response;
  }

  Future sendSelectCategories(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.getAllCategories, method: RequestType.post, body: body);
    log(response.data.toString());
    return response;
  }

  Future getAllLocations(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.getAllLocation, method: RequestType.get, queryParameters: body);
    log(response.data.toString());
    return response;
  }

  Future sendSelectLocations(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.getAllLocation, method: RequestType.post, body: body);
    log(response.data.toString());
    return response;
  }

  Future getStateLocation(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.getStateLocation, method: RequestType.get, queryParameters: body);
    log(response.data.toString());
    return response;
  }
//
// Future updateProfile(Map<String,dynamic> body) async {
//     Response response = await makeRequest(url: BaseUrls.updateProfile,method: RequestType.put,
//       body: body, baseUrl: BaseUrls.
//
//   );
//   }

}
