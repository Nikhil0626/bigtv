import 'dart:developer';

import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class PollRepo extends BaseService {
  Future submitPolls(body) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: BaseUrls.submitPolls,
      body: body,
      method: RequestType.post,
    );
    log(response.toString());
    return response;
  }

  Future getPollResults(dynamic postId, {dynamic userId}) async {
    Map<String, dynamic>? queryParams;
    if (userId != null &&
        userId.toString().isNotEmpty &&
        userId.toString() != "0") {
      queryParams = {'user_id': userId};
    }
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: "${BaseUrls.getAllPolls}/$postId/results",
      queryParameters: queryParams,
      method: RequestType.get,
    );
    return response;
  }

  Future getAllPollComments(id) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: "${BaseUrls.getAllPolls}/$id",
      method: RequestType.get,
    );
    log(response.toString());
    return response;
  }
}
