import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class HomeRepo extends BaseService{

  Future getAllNewsFeeds(queryParams) async{
    Response response = await makeRequest(url: BaseUrls.getNews,method: RequestType.get,queryParameters: queryParams);


    return response;
  }


  Future addCommentByPost(queryParams) async{
    Response response = await makeRequest(url: BaseUrls.addComment,method: RequestType.get,queryParameters: queryParams);
    return response;
  }


  Future getAllComments(queryParams) async{
    Response response = await makeRequest(url: BaseUrls.addComment,method: RequestType.get,queryParameters: queryParams);
    return response;
  }

  Future likeByPost(queryParams) async{
    Response response = await makeRequest(url: BaseUrls.likePost,method: RequestType.post,body: queryParams);
    return response;
  }
}