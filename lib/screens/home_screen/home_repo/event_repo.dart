import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../services/base_service.dart';
import '../../../services/base_urls.dart';
import '../../../utils/app_enums.dart';

class EventRepo extends BaseService {

  Future sendEvent(body) async {
    log("event body --- ${body}");
    Response response = await makeRequest(url: BaseUrls.eventUrl,
        baseUrl:BaseUrls.baseUrlAws,
        method: RequestType.post,
        body: body);
    log(response.data.toString());
    return response;
  }
}