import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class VideosRepo extends BaseService {
  Future getAllVideos(Map<String, dynamic> queryParameters) async {
    Response response = await makeRequest(
        url: BaseUrls.getAllVideos,
        method: RequestType.get,
        queryParameters: queryParameters);
    return response;
  }
  Future getAllMenuItem() async {
    Response response = await makeRequest(
        url: BaseUrls.appMenu,
        method: RequestType.get,);
    return response;
  }
}
