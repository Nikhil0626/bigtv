import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class RatingRepo extends BaseService {

  Future postSubmitRating(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.postRating, method: RequestType.post, body: body);
    return response;
  }

  Future getReviews(body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: "${BaseUrls.getReviewsById}$body",
      method: RequestType.get,
    );
    return response;
  }

  Future postPolling(body) async {
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev, url: BaseUrls.postPoll, method: RequestType.post, body: body);
    return response;
  }

  Future getComments(body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: "${BaseUrls.getPollCommentsById}$body",
      method: RequestType.get,
    );
    return response;
  }

}
