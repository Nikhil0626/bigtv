

import 'package:chotanews/services/base_service.dart';
import 'package:dio/dio.dart';

import '../../../services/base_urls.dart';
import '../../../utils/app_enums.dart';

class ReelsRepo  extends BaseService{

  Future getMainReels() async {
    Response response = await makeRequest(baseUrl: BaseUrls.ePaperBaseUrlAws,
      url: BaseUrls.getMainEPapers, method: RequestType.get,);
    return response;
  }
}