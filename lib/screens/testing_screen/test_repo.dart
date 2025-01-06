

import 'dart:developer';

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class TestRepo extends BaseService{
  
  Future getHomePageNews() async{
    final Map<String, dynamic> queryParams = {
      'userid': 1,
      'postid': 0,
      'lpostid': 0,
      'includeHomePage': 1,
      'hasAds': true,
      'isByNotification': false,
      'deviceid': '993f0e149b5bed89',
      'platform': 'android',
      'homefeed': 1,
      'locationIds': 'undefined',
    };
    log(queryParams.toString());
    try{
      Response response = await makeRequest(url: BaseUrls.getNews,method: RequestType.get,queryParameters: queryParams);
      log(response.data.toString());
    }

  on DioException  catch(e,st){
      log(st.toString());
      log(e.toString());
    }  catch(e,st){
      log(st.toString());
      log(e.toString());
    }

  }
  
}