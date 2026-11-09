import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class RatingRepo extends BaseService {
  Future postSubmitRating(body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: BaseUrls.postRating,
      method: RequestType.post,
      body: body,
    );
    return response;
  }

  Future getReviews(dynamic postId, [Map<String, dynamic>? queryParams]) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: "${BaseUrls.getReviewsById}$postId",
      method: RequestType.get,
      queryParameters: queryParams,
    );
    return response;
  }
}
