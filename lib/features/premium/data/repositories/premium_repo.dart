import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class PremiumRepo extends BaseService {
  Future<Response> getSeriesContent({String type = 'series'}) async {
    Response response = await makeRequest(
      baseUrl: BaseUrls.baseUrlAwsDev,
      url: BaseUrls.seriesContent,
      method: RequestType.get,
      queryParameters: {'type': type},
    );
    return response;
  }
}
