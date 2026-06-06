
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';


class HomeRepo extends BaseService{
  Future getSinglePost(body,queryParams) async{

    Response response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: "${BaseUrls.getPostById}/$queryParams",method: RequestType.get,queryParameters: body);

    return response;
  }

  Future getAllPosts(queryParams) async{
    Response  response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: BaseUrls.getAllPost,method: RequestType.post,body: queryParams);

    return response;
  }
  Future getAllAiTags(Map<String, dynamic> body) async{
    Response  response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: BaseUrls.aiTags,method: RequestType.get,queryParameters: body);
    return response;
  }


  Future getAllAiTagsById(body) async{
    Response  response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: BaseUrls.aiTagsById,method: RequestType.get,queryParameters: body);
    return response;
  }

  Future surveyApi() async{
    Response  response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: BaseUrls.surveyApi,method: RequestType.get,);
    return response;
  }
  Future imageAdsSendData(body) async{
    Response  response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: BaseUrls.contestClick,method: RequestType.post,body:body );
    return response;
  }
}