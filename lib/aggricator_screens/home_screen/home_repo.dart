import 'package:chotanews/services/base_service.dart';
import 'package:dio/dio.dart';

import '../../services/base_urls.dart';
import '../../utils/app_enums.dart';

class HomeRepo extends BaseService{
  Future getSinglePost(queryParams) async{
    Response response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: "${BaseUrls.getPostById}/$queryParams",method: RequestType.get);
    return response;
  }

  Future getAllPosts(queryParams) async{
    Response  response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: BaseUrls.getAllPost,method: RequestType.get,queryParameters: queryParams);
    return response;
  }
}