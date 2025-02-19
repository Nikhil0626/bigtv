import 'dart:developer';

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DistrictSelectionRepo extends BaseService{
  Future getAllDistricts() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("loginId");
    Response response = await makeRequest(url:"${BaseUrls.getAllDistricts}/$userId/locations",method: RequestType.get );
    return response ;
  }



  Future updateDistrictsList( body) async {
    Response response = await makeRequest(url: BaseUrls.updateDistricts,method: RequestType.post,body: body);
    return response;
  }
}