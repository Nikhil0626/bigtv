

import 'package:chotanews/services/base_service.dart';
import 'package:dio/dio.dart';

import '../../../services/base_urls.dart';
import '../../../utils/app_enums.dart';

class EPaperRepo extends BaseService {

  Future getMainEPapers() async {
    Response response = await makeRequest(baseUrl: BaseUrls.ePaperBaseUrlAws,
        url: BaseUrls.getMainEPapers, method: RequestType.get,);
    return response;
  }


  Future getSingleEPapers(String paper, id) async {
    Map<String, dynamic> body = {
      "edition_id":id??""
    };
    Response response = await makeRequest(baseUrl: BaseUrls.ePaperBaseUrlAws,
      url: "${BaseUrls.getSingleEPapers}/$paper/today", method: RequestType.get,queryParameters: body);
    return response;
  }


}