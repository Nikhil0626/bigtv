
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class NewsPostRepo extends BaseService{

  Future getAllComments(body)async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,url: BaseUrls.getAllComments,method: RequestType.get,queryParameters: body);
   return response;
  }

  Future sendPostComments(body)async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,url: BaseUrls.getAllComments,method: RequestType.post,body: body);
    return response;
  }
}