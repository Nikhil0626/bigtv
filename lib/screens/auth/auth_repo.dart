import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/base_service.dart';
import '../../services/base_urls.dart';
import '../../utils/app_enums.dart';

class AppRepo extends BaseService {
  Future login(body) async {
    final response = await makeRequest(
        baseUrl: BaseUrls.baseUrl,
        body: body,
        method: RequestType.post,
        url: BaseUrls.login);
    return response;
  }

  Future getEngageTweets(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,options: Options(headers: {
      "Accept":"application/json",
    }), method: RequestType.post,body: body, url: BaseUrls.home);
    return response;
  }

  Future sendOtpByEmail(body) async {
    final response = await makeRequest(
        baseUrl: BaseUrls.baseUrl,
        body: body,
        method: RequestType.post,
        url: BaseUrls.sendOtp);
    return response;
  }

  Future verifyOtp(body) async {
    final response = await makeRequest(
        baseUrl: BaseUrls.baseUrl,
        body: body,
        method: RequestType.post,
        url: BaseUrls.verifyOtp);
    return response;
  }


  Future changePassword(body) async {
    final response = await makeRequest(
        baseUrl: BaseUrls.baseUrl,
        body: body,
        method: RequestType.post,
        url: BaseUrls.changePassword);
    return response;
  }

  Future tweetGenerateByAi(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.tweetGenerate);
    return response;
  }

  Future getTwitterHandles() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        method: RequestType.get,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        url: BaseUrls.getTwitterHandles);
    return response;
  }

  Future deleteHandle(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        body: body,
        method: RequestType.post,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        url: BaseUrls.deleteHandle);
    return response;
  }

  Future editHandle(body, id) async {
    log(id);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    print("${BaseUrls.editHandle}$id");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        body: body,
        method: RequestType.post,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        url: "${BaseUrls.editHandle}$id");
    return response;
  }

  Future addHandle(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    print( accessToken.toString());
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        body: body,
        method: RequestType.post,
        url: BaseUrls.addHandle);
    login(response.data);
    return response;
  }

  Future deleteUser(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        body: body,
        method: RequestType.post,
        url: BaseUrls.deleteSettingUser);
    return response;
  }

  Future getTweetMetric() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
      token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        method: RequestType.get,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        url: BaseUrls.getTweetMetric);
    return response;
  }

  Future blockUser(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
         body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.blockUser);
    return response;
  }

  Future unbBlockUser(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
         body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.unbBlockUser);
    return response;
  }

  Future deleteTweet(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
         body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.deleteTweet);
    return response;
  }

  Future publishTweet(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
         body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.publishTweet);
    return response;
  }

  Future publish(body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
         body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.publish);
    return response;
  }

  Future getSettingsUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        method: RequestType.get,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        url: BaseUrls.getSettingsUser);
    return response;
  }

  Future getSettingsId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        method: RequestType.get,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        url: BaseUrls.getSettingsId);
    return response;
  }

  Future addUser(Map<String, dynamic> body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.addUser);
    return response;
  }

  Future updateWords(Map<String, dynamic> body) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        body: body,
        options: Options(headers: {
          "Accept":"application/json",
        }),
        method: RequestType.post,
        url: BaseUrls.updateWords);
    return response;
  }

  Future editUser(Map<String, dynamic> body, id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken =  preferences.getString("accessToken");
    final response = await makeRequest(
        token1:accessToken ,
        baseUrl: BaseUrls.baseUrl,
        body: body,
        options: Options(headers: {
          "accept":"application/json",
        }),
        method: RequestType.post,
        url: "${BaseUrls.editUser}/$id");
    return response;
  }
}
