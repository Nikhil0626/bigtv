

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

}