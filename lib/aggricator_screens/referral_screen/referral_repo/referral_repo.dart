import 'package:chotanews/services/base_service.dart';
import 'package:dio/dio.dart';

import '../../../services/base_urls.dart';
import '../../../utils/app_enums.dart';

class ReferralRepo extends BaseService{
  Future getReferralStats(body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
        url: "${BaseUrls.getReferralStats}/$body", method: RequestType.get,);
    return response;
  }

  Future getAvailableRewards() async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
    url: BaseUrls.getAvailableRewards, method: RequestType.get,);
    return response;
  }

  Future getClaimedRewards(body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
      url: BaseUrls.getClaimedReward, method: RequestType.get,queryParameters: body);
    return response;
  }

  Future postClaimedRewards(body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
        url: BaseUrls.getClaimedReward, method: RequestType.post,body: body);
    return response;
  }
  Future getAllProvidersNames() async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,
        url: BaseUrls.serviceProviders, method: RequestType.get,);
    return response;
  }
 }