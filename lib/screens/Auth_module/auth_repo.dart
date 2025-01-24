

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class AuthRepo extends BaseService{


  Future loginWithGoogle() async {
    Response response = await makeRequest(url: "",method: RequestType.post);
    return response;
  }

  Future loginWithApple() async {
    Response response = await makeRequest(url: "",method: RequestType.post);
    return response;

  }

}