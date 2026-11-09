
import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';


class HomeRepo extends BaseService{
  Future getSinglePost(body,queryParams) async{
    Response response = await makeRequest(baseUrl:BaseUrls.baseUrlAwsDev,url: "${BaseUrls.getPostById}/$queryParams",method: RequestType.get,queryParameters: body);
    if (response.statusCode == 200 && response.data != null && response.data['status'] == 'success') {
      return response;
    }
    // Fallback to production if post is not found on dev
    try {
      Response prodResponse = await makeRequest(
        baseUrl: "https://api.chotanews.com",
        url: "${BaseUrls.getPostById}/$queryParams",
        method: RequestType.get,
        queryParameters: body,
      );
      if (prodResponse.statusCode == 200 && prodResponse.data != null) {
        return prodResponse;
      }
    } catch (_) {}
    return response;
  }

  Future getAllPosts(queryParams) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.getAllPost, method: RequestType.post, body: queryParams);
    final data = response.data;
    final posts = data is Map ? (data['posts'] ?? data['data']) : data;
    if (response.statusCode == 200 && posts is List && posts.isNotEmpty) {
      return response;
    }

    // Fallback to production if dev returns no posts or fails
    try {
      Response prodResponse = await makeRequest(
        baseUrl: "https://api.chotanews.com",
        url: BaseUrls.getAllPost,
        method: RequestType.post,
        body: queryParams,
      );
      if (prodResponse.statusCode == 200 && prodResponse.data != null) {
        final prodData = prodResponse.data;
        final prodPosts = prodData is Map ? (prodData['posts'] ?? prodData['data']) : prodData;
        if (prodPosts is List && prodPosts.isNotEmpty) {
          return prodResponse;
        }
      }
    } catch (_) {}

    return response;
  }

  Future getMoreFollowTags({Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await makeRequest(
        baseUrl: BaseUrls.baseUrlAwsDev,
        url: BaseUrls.getMoreFollow,
        method: RequestType.get,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return response;
        }
      }
    } catch (_) {}

    try {
      Response prodResponse = await makeRequest(
        baseUrl: "https://api.chotanews.com",
        url: BaseUrls.getMoreFollow,
        method: RequestType.get,
        queryParameters: queryParams,
      );
      if (prodResponse.statusCode == 200 && prodResponse.data != null) {
        final data = prodResponse.data;
        if (data is List && data.isNotEmpty) {
          return prodResponse;
        }
      }
    } catch (_) {}

    return Response(
      requestOptions: RequestOptions(path: BaseUrls.getMoreFollow),
      statusCode: 200,
      data: [],
    );
  }
  Future getAllAiTags(Map<String, dynamic> body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: BaseUrls.videoTags,
      method: RequestType.get,
      queryParameters: body,
      headers: {'accept': '*/*'},
    );
    return response;
  }

  Future getAiTags() async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.aiTags, method: RequestType.get);
    return response;
  }

  Future getTagVideos(String slug, {Map<String, dynamic>? queryParameters}) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: "/api/v1/video-tags/$slug/videos",
      method: RequestType.get,
      queryParameters: queryParameters,
      headers: {'accept': '*/*'},
    );
    return response;
  }

  Future updateTagVideoView(String slug, String videoId) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: "/api/v1/video-tags/$slug/videos/$videoId/view",
      method: RequestType.put,
    );
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

  Future getEpapers(Map<String, dynamic> queryParams) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: "/epapers",
      method: RequestType.get,
      queryParameters: queryParams,
    );
    if (response.statusCode == 200 &&
        response.data is List &&
        (response.data as List).isNotEmpty) {
      return response;
    }
    try {
      Response prodResponse = await makeRequest(
        baseUrl: "https://api.chotanews.com",
        url: "/epapers",
        method: RequestType.get,
        queryParameters: queryParams,
      );
      if (prodResponse.statusCode == 200 &&
          prodResponse.data is List &&
          (prodResponse.data as List).isNotEmpty) {
        return prodResponse;
      }
    } catch (_) {}
    return response;
  }

  Future postDeviceDetails(Map<String, dynamic> body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: BaseUrls.deviceDetails,
      method: RequestType.post,
      body: body
    );
    return response;
  }

  Future getAppConfig() async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.newServerBaseUrl,
      url: BaseUrls.appConfig,
      method: RequestType.get,
    );
    return response;
  }
}