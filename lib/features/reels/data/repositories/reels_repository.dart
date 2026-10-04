

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';


class ReelsRepo  extends BaseService{

  Future getAllReels([Map<String, dynamic>? body]) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: BaseUrls.getReelsApi,
      method: RequestType.get,
      queryParameters: body,
      headers: {'accept': '*/*'},
    );
    return response;
  }

  Future getSingleReelData(Map<String, dynamic> body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: BaseUrls.getReelsApi,
      method: RequestType.get,
      queryParameters: body,
      headers: {'accept': '*/*'},
    );
    return response;
  }

  Future postLikes(Map body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.likePost,
      url: BaseUrls.likePost, method: RequestType.post,body: body);
    return response;
  }
}